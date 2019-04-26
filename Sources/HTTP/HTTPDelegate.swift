//
//  HTTPDelegate.swift
//  Basic
//
//  Created by 李招利 on 2018/10/8.
//
import Foundation
import Extend

// MARK: 即将下载
extension HTTP._Delegate {
    
    func willDownload(request:HTTP.Request, totalSize:Int64, localSize:Int64, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        
        guard let queue = self.queue,
            let (_, request) = queue.ongoingTask else {
            return
        }
        
        HTTP._willDownload(queue, request, totalSize, localSize, completionHandler)
    }

}

// MARK: - (通用)URLSessionTaskDelegate
extension HTTP._Delegate : URLSessionTaskDelegate {
    
    /// 无论成功失败都会走这里, 用来做完成回调
    @available(iOS 7.0, *)
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        let data = self.data
        self.data = nil
        if  let netError = error as NSError?,
            netError.code == -999,
            task.taskDescription == kDownloadIgnoreCancel {
            print("需要忽略取消异常回调")
        } else {
            queue?.finish(session, task.originalRequest!, task.response, data, error)
        }
    }

    /// 网络请求302重定向
    @available(iOS 7.0, *)
    func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
        completionHandler(request)
    }
    
    /// 用来信任自定义的不安全HTTPS证书
    @available(iOS 7.0, *)
    func urlSession(_ session: URLSession, task: URLSessionTask, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
            let serverTrust = challenge.protectionSpace.serverTrust {
            // 信任任何证书
            completionHandler(.useCredential, URLCredential(trust: serverTrust))
        } else {
            // 使用默认方法
            completionHandler(.performDefaultHandling, nil)
        }
        
    }
    
    
//    @available(iOS 7.0, *)
//    func urlSession(_ session: URLSession, task: URLSessionTask, needNewBodyStream completionHandler: @escaping (InputStream?) -> Void) {
//
//    }
//
    
    /// request 发送进度
    @available(iOS 7.0, *)
    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        
    }
    
    
    /// 完成标准
    @available(macOS 10.12, *)
    @available(iOS 10.0, *)
    func urlSession(_ session: URLSession, task: URLSessionTask, didFinishCollecting metrics: URLSessionTaskMetrics) {
        
    }
    
    /// 延迟加载
    @available(macOS 10.13, *)
    @available(iOS 11.0, *)
    func urlSession(_ session: URLSession, task: URLSessionTask, willBeginDelayedRequest request: URLRequest, completionHandler: @escaping (URLSession.DelayedRequestDisposition, URLRequest?) -> Void) {
        completionHandler(.continueLoading, request)
    }
    
    /// 等待网络连接
    @available(iOS 11.0, *)
    func urlSession(_ session: URLSession, taskIsWaitingForConnectivity task: URLSessionTask) {
        
    }
    
}

// MARK: - (数据)URLSessionDataDelegate
extension HTTP._Delegate : URLSessionDataDelegate {
    
    @available(iOS 7.0, *)
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        if self.data == nil {
            self.data = data
        } else {
            self.data?.append(data)
        }
        
    }
    
    /// 收到HTTP响应
    @available(iOS 7.0, *)
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        
        guard let queue = self.queue else { return completionHandler(.cancel) }
        
        guard let (_, request) = queue.ongoingTask else { return completionHandler(.cancel) }
        
        // 如果不是HTTP请求则取消
        guard let httpResponse = response as? HTTPURLResponse else {
            // 允许未知的响应状态继续
            return completionHandler(.allow)
//            let info = ["message":"未知的请求响应:\(response.classNameForCoder)"]
//            let error = NSError(domain: NSURLErrorDomain, code: -3001, userInfo: info)
//            data = nil
//            queue.finish(session, dataTask.originalRequest!, response, nil, error)
//            return completionHandler(.cancel)
        }
        
        // 得到服务器时间, 更新本地时间戳偏移
        let dateText = httpResponse.allHeaderFields["Date"] as? String ?? "Thu, 01 Jan 1970 00:00:00 GMT"
        let format = DateFormatter()
        format.locale = Locale(identifier: "en_US")
        format.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z"
        
        let date = format.date(from: dateText) ?? Date(timeIntervalSince1970: 0)
        HTTP.timeOffset = date.timeIntervalSince1970 - Date().timeIntervalSince1970
        
        // 非下载请求则 允许继续访问
        if request._downloadTarget == nil { return completionHandler(.allow) }
        
        // 如果不是下载的响应状态
        if httpResponse.statusCode != 200 && httpResponse.statusCode != 206 {
            let info = ["message":"非下载网络状态:\(httpResponse.statusCode)"]
            let error = NSError(domain: NSURLErrorDomain, code: httpResponse.statusCode, userInfo: info)
            data = nil
            queue.finish(session, dataTask.originalRequest!, response, nil, error)
            dataTask.taskDescription = kDownloadIgnoreCancel
            return completionHandler(.cancel)
        }
        
        
        // 如果未强制下载路径， 则优先使用 服务器返回的文件名
//            let downloadURL = request.localURLWith(fileName: response.suggestedFilename)
        
        // 输出下载路径
//            print("Content-Disposition:",downloadURL);
        
        let totalSize = Int64(httpResponse.allHeaderFields["Content-Length"] as? String ?? "0") ?? 0
        
        // 如果是断点续传则直接开始下载
        if httpResponse.statusCode != 200 {
            // TODO : 检测网络状态, 成功直接开始下载
            return willDownload(request: request, totalSize: totalSize, localSize: 0, completionHandler: completionHandler)
        }
        
        let bookmarkFile = HTTP.bookmarkFileFor(key: request.url.absoluteString)
        
        let fileManager = FileManager.default
        var isDir:ObjCBool = false
        
        // 如果从未下载过则直接开始
        if !fileManager.fileExists(atPath: bookmarkFile, isDirectory: &isDir) || isDir.boolValue {
            // TODO : 检测网络状态, 成功直接开始下载
            return willDownload(request: request, totalSize: totalSize, localSize: 0, completionHandler: completionHandler)
        }
        
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: bookmarkFile)), data.count > 0 else {
            // TODO : 书签数据无效, 直接开始下载
            return willDownload(request: request, totalSize: totalSize, localSize: 0, completionHandler: completionHandler)
        }
        
        var isStale:Bool = false
        guard let fileURL = try? URL(resolvingBookmarkData: data, bookmarkDataIsStale: &isStale) else {
            // TODO : 书签无效, 直接开始下载
            return willDownload(request: request, totalSize: totalSize, localSize: 0, completionHandler: completionHandler)
        }
        
        
        let filePath = fileURL.relativePath
        if !fileManager.fileExists(atPath: filePath, isDirectory: &isDir) || isDir.boolValue {
            // TODO : 书签指向真实文件不存在, 删除书签, 直接开始下载
            try? fileManager.removeItem(atPath: bookmarkFile)
            return willDownload(request: request, totalSize: totalSize, localSize: 0, completionHandler: completionHandler)
        }
        
        guard let fileAttr = try? fileManager.attributesOfItem(atPath: filePath) else {
            // TODO : 无法确定书签指向文件的大小, 直接开始下载
            return willDownload(request: request, totalSize: totalSize, localSize: 0, completionHandler: completionHandler)
        }
        let localSize = fileAttr[.size] as? Int64 ?? 0
        
        if localSize != totalSize {
            // TODO : 已下载的文件大小和服务器端文件大小不一致 则重新下载
            return willDownload(request: request, totalSize: totalSize, localSize: 0, completionHandler: completionHandler)
        }
//        request.onProgress(totalSize: totalSize, localSize: localSize)
//        request.callProgress(totalSize: totalSize, localSize: localSize)
        // 如果大小一致则取消下载 返回成功
        // 调用成功回调
//        request._localURL = fileURL //downloadURL
        self.data = data
        urlSession(session, task: dataTask, didCompleteWithError: nil)
        dataTask.taskDescription = kDownloadIgnoreCancel
        completionHandler(.cancel)

    }
    
    /// 将要缓存数据
    @available(iOS 7.0, *)
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, willCacheResponse proposedResponse: CachedURLResponse, completionHandler: @escaping (CachedURLResponse?) -> Void) {
        // 保存缓存的响应结果
        completionHandler(proposedResponse)
    }
    
    
    @available(iOS 7.0, *)
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didBecome downloadTask: URLSessionDownloadTask) {
        queue?._task = downloadTask
    }
    
    @available(macOS 10.11, *)
    @available(iOS 9.0, *)
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didBecome streamTask: URLSessionStreamTask) {
        queue?._task = streamTask
    }

    
}

// MARK: - (下载)URLSessionDownloadDelegate
extension HTTP._Delegate : URLSessionDownloadDelegate {
    
    /// 下载完成
    @available(iOS 7.0, *)
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        
        guard let queue = self.queue else { return }
        
        guard let (_, request) = queue.ongoingTask else { return }
        
        guard let target = request._downloadTarget else { return }

        // 获得下载请求
        
        guard let url = downloadTask.originalRequest?.url else { return }
        
        let bookmarkPath = HTTP.bookmarkPathFor(key: url.absoluteString)
        let bookmarkFile = bookmarkPath.stringByAppending(pathComponent: "download.mark")
        
        var downloadURL:URL! = nil
        if case .toFixedURL(let url) = target {
            downloadURL = url
        } else {
            let fileName = downloadTask.response?.suggestedFilename ?? url.lastPathComponent
            let filePath = bookmarkPath.stringByAppending(pathComponent: fileName)
            downloadURL = URL(fileURLWithPath: filePath, isDirectory: false)
        }
        
        let fileManager = FileManager.default
        
        var isDir:ObjCBool = false
        
        // 如果下载路径不存在则创建
        let parentPath = downloadURL.deletingLastPathComponent().relativePath
        if !fileManager.fileExists(atPath: parentPath, isDirectory: &isDir) || !isDir.boolValue {
            try? fileManager.createDirectory(atPath: parentPath, withIntermediateDirectories: true, attributes: nil)
        }
        
        // 删除旧的 已下载文件或书签 如果有的话.
        try? fileManager.removeItem(atPath: bookmarkFile)
        try? fileManager.removeItem(at: downloadURL)
        
        // 将新下载完成的文件移动到 文件路径
        try? fileManager.moveItem(at: location, to: downloadURL)
        
        // 保存书签数据
        if let data = try? downloadURL.bookmarkData() {
            try? data.write(to: URL(fileURLWithPath: bookmarkFile, isDirectory: false))
            self.data = data
        }
//        request._localURL = downloadURL
    }
    
    
    @available(iOS 7.0, *)
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
    }
    
    
    @available(iOS 7.0, *)
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {
        
    }

    
}

private let kDownloadIgnoreCancel = "download.ignore.cancel"
