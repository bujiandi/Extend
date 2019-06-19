//
//  HTTPQueue.swift
//  HTTP
//
//  Created by bujiandi on 2018/9/30.
//

import Foundation
import Extend

extension HTTP.Queue {
    
    // 创建一个请求队列
    public static func request(url:URL, _ initializer:(inout HTTP.Request) -> Void) -> HTTP.Queue {
        let queue = HTTP.Queue()
        queue.request(url: url, initializer)
        return queue
    }
    
    
    public final class RetryHandle : Resumable {
        
        var client:HTTP.Client
        var queue:HTTP.Queue
        
        internal init(client:HTTP.Client, queue:HTTP.Queue) {
            self.client = client
            self.queue = queue
        }
        
        public func resume() {
            queue.send(use: client)
        }
        
    }
    
}


extension HTTP.Queue {
    
    public func request(url:URL, _ initializer:(inout HTTP.Request) -> Void) {
        
        var request = HTTP.Request(url: url)
        initializer(&request)
        _requests.append(request)
        _progress.totalUnitCount = Int64(_requests.count)
        
    }
    
//    public func requestOnQueue
    
    public func send(use client:HTTP.Client) {
        client.send(queue: self)
    }
    
    public func onComplete(inThread queue:OperationQueue? = nil, _ complete: @escaping (Error?) -> Void) {
        _queue = queue
        _complete = complete
    }
    
    public func cancel() {
        // 如果是下载请求则准备断点续传
        if let task = _task as? URLSessionDownloadTask,
            let url = task.originalRequest?.url {
            
            let bookmarkPath = HTTP.bookmarkPathFor(key: url.absoluteString)
            let cacheDataPath = bookmarkPath.stringByAppending(pathComponent: "download.data")
            let cacheDataURL = URL(fileURLWithPath: cacheDataPath, isDirectory: false)

            // 取消请求, 将恢复下载数据写入文件 以备断点续传使用
            task.cancel { ((try? $0?.write(to: cacheDataURL)) as ()??) }
        } else {
            _task?.cancel()
        }
    }
    
    public var requests:[HTTP.Request] {  return _requests }
}

extension HTTP.Queue {
    
    public var progress:Progress { return _progress }
    //
    public var isEmpty:Bool { return _requests.isEmpty }

    public var count:Int { return _requests.count }
    
    public var retryCount:Int { return _retryCount }
    
    public var retryOverlay:HTTPFailureRetryOverlay? { return _retryOverlay }
    
    public var retryHandle:RetryHandle? {
        guard let client = _client else { return nil }
        return RetryHandle(client: client, queue: self)
    }

    // 正在执行的任务请求
    public var ongoingTask:(URLSessionTask, HTTP.Request)? {
        let index = _index - 1
        if let task = _task, index >= 0, index < _requests.count {
            return (task, _requests[index])
        }
        return nil
    }
}


extension HTTP.Queue {
    
    func finish(_ session:URLSession, _ urlRequest:URLRequest, _ response:URLResponse?, _ data:Data?, _ error:Error?) {
        guard let (_, request) = ongoingTask else { return }
        
        _task = nil
        if request._decode(self, urlRequest, response, data, error) {
            resume(session: session)
        } else {
            _index = 0
        }
    }
    
    func resume(session:URLSession) {
        if _task != nil { return }
        if _index >= _requests.count {
            _finish?(self)
            _complete?(nil)
            return
        }
        
        let request = _requests[_index]
        _index += 1
        
        var urlRequest:URLRequest! = nil
        do {
            urlRequest = try request.urlRequest()
        } catch let error {
            return failureCancel(with: error)
        }
        
        if let downloadTarget = request._downloadTarget {
            
            let getURL = urlRequest.url!.absoluteString
            
            // 用url绝对地址生成key 获得书签路径
            let bookmarkPath = HTTP.bookmarkPathFor(key: getURL)
            let cacheDataPath = bookmarkPath.stringByAppending(pathComponent: "download.data")
            
            let fileManager = FileManager.default
            
            // 文件不存在或不是目录 则创建
            var isDir:ObjCBool = false
            if !fileManager.fileExists(atPath: bookmarkPath, isDirectory: &isDir) || !isDir.boolValue
            {
                try! fileManager.createDirectory(atPath: bookmarkPath, withIntermediateDirectories: true, attributes: nil)
            }
            
            // 如果需要返回缓存预览路径
            let bookmarkFile = bookmarkPath.stringByAppending(pathComponent: "download.mark")
            var isStale:Bool = false
            
                // 如果需要返回缓存预览
            if  let previewCache = request._previewDownCache,
                // 并且缓存书签路径存在
                fileManager.fileExists(atPath: bookmarkFile, isDirectory: &isDir),
                // 并且缓存数据不是目录
                !isDir.boolValue,
                // 拿到缓存书签数据
                let data = try? Data(contentsOf: URL(fileURLWithPath: bookmarkFile)),
                // 并且书签不为空
                !data.isEmpty,
                // 拿到书签指向的文件路径
                let fileURL = try? URL(resolvingBookmarkData: data, bookmarkDataIsStale: &isStale),
                // 拿到文件属性
                let fileAttr = try? fileManager.attributesOfItem(atPath: fileURL.relativePath),
                // 拿到文件尺寸
                let fileSize = fileAttr[.size] as? Int64,
                // 文件大小不为空
                fileSize > 0
            {
                // 如果指定了下载路径, 并且与书签指向路径不一致, 则移动文件
                if case .toFixedURL(let url) = downloadTarget, url != fileURL {
                    do {
                        try fileManager.moveItem(at: fileURL, to: url)
                        previewCache(url)
                    } catch {
                        previewCache(fileURL)
                    }
                } else {
                    previewCache(fileURL)
                }
            }
            
            // 如果续传文件存在 则 从断点续传 下载 否则 开始新的下载
            if fileManager.fileExists(atPath: cacheDataPath, isDirectory: &isDir) && !isDir.boolValue {
                let data = try! Data(contentsOf: URL(fileURLWithPath: cacheDataPath, isDirectory: false))
                
//                let datas = NSMutableData()
//                var totalSize:Int64 = 0
//                data.append(totalSize)
                
//                data.copyBytes(to: &totalSize, from: (data.endIndex - 8)...)
                
                try? fileManager.removeItem(atPath: cacheDataPath)
                
                sessionDelegate.willDownload(request: request, totalSize: 0, localSize: Int64(data.count)) { [weak self] in
                    guard let this = self else { return }
                    switch $0 {
                    case .cancel:
                        this.failureCancel(with: HTTP.RequestError.canceled)
                    default:
                        this._task = session.downloadTask(withResumeData: data)
                        this._task!.resume()
                    }
                }
            } else {
                _task = session.dataTask(with: urlRequest)
                _task!.resume()
            }
        } else {
            _task = session.dataTask(with: urlRequest)
            _task!.resume()
        }
        
    }
    
    func failureCancel(with error:Error) {
        _finish?(self)
        _complete?(error)
    }
    
}

// MARK: - Overlay
extension HTTP.Queue {
    
    func startOverlays() {
        
        _states = _states.filter {
            guard let state = $0.obj else { return false }
            state.value = .loading
            return true
        }

        // compactMap return $0
        _overlays = _overlays.filter {
            guard let overlay = $0.overlay else { return false }
            DispatchQueue.main.async { overlay.startNetOverlay() }
            return true
        }
        _state = .loading
    }
    
    func setOverlaysProgress(_ request:Progress) {
        let current = progress.totalUnitCount == 0 ? 0 : 1 / Double(progress.totalUnitCount) * request.fractionCompleted
        let percent = progress.fractionCompleted + current
        
        _overlays = _overlays.filter {
            guard let overlay = $0.overlay else { return false }
            overlay.progressPercentChanged(percent)
            return true
        }
    }
    
    public func syncStates(from queue:HTTP.Queue) {
        _states = queue._states.filter { $0.obj != nil }
    }

    public func syncOverlays(form queue:HTTP.Queue) {
        _overlays = queue._overlays.filter { $0.overlay != nil }
    }
    
    public func failure(showRetryOn overlay:HTTPFailureRetryOverlay) {
        _retryOverlay = overlay
    }
    
    public func change(state:Storage<HTTP.State>) {
        
        _states.append(WeakContainer<Storage<HTTP.State>>(state))
        state.value = _state
    }
    
    public func overlay(_ view:HTTPOverlay){
        
        _overlays.append(HTTP.WeakOverlay(view))// <- HTTP.WeakOverlay(view)
        if case .loading = _state { view.startNetOverlay() }
        
    }

}
