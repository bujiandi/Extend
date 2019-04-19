//
//  HTTPRequest.swift
//  Basic
//
//  Created by 李招利 on 2018/9/30.
//

import Foundation

extension HTTP {
    
    // 创建一个请求队列
    public static func queueRequest(url:URL, _ initializer:(inout HTTP.Request) -> Void) -> HTTP.Queue {
        let queue = HTTP.Queue()
        queue.request(url: url, initializer)
        return queue
    }
    
}

extension HTTP.Request {
    
    init(url:URL) { self.url = url }

    public var policy:URLRequest.CachePolicy { return _policy }

    public var timeout:TimeInterval { return _timeout ?? HTTP.timeout }

    public mutating func header(key:String, forValue value:String) {
        _headers[key] = value
    }
    
    public mutating func post<E:HTTPPostEncoder>(encoder:E, params:E.Params?) {
        _postEncode = { try encoder.encode(params: params, request: &$0) }
    }

    public mutating func get<E:HTTPGetEncoder>(encoder:E, params:E.Params?) {
        _getEncode = { encoder.encode(params: params, url: $0) }
    }

    public mutating func response<D:HTTPResponeDecoder>(decoder:D, inQueue:OperationQueue = .main, onSuccess: @escaping (D.Result) throws -> Void) {
        _decode = { (queue, request, response, data, error) in
            // 如果不是HTTP响应
            guard let httpRes  = response as? HTTPURLResponse else {
                
                if (error as NSError?)?.code == -999 {
                    queue.failureCancel(with: HTTP.RequestError.canceled)
                } else {
                    queue.failureCancel(with: HTTP.RequestError.failureRequest(error!))
                }
                return false
            }
            
            let statusCode = httpRes.statusCode
            // 如果状态码异常
            guard (200..<300).contains(statusCode), let httpData = data else {
                let code = httpRes.statusCode
                let domain = (error as NSError?)?.domain ?? NSURLErrorDomain
                let text = domain == NSURLErrorDomain ? HTTPURLResponse.localizedString(forStatusCode: code) : domain
                queue.failureCancel(with: HTTP.RequestError.failStatusCode(code, text))
                return false
            }
            
            var result:D.Result! = nil
            do {
                result = try decoder.decode(request: request, response: httpRes, data: httpData)
            } catch {
                queue.failureCancel(with: error)
                return false
            }
            
            // 如果如果成功解析
            var decodeSuccess:Bool = true
            
            let callSuccess = {
                do {
                    try onSuccess(result)
                } catch {
                    queue.failureCancel(with: error)
                    decodeSuccess = false
                }
            }
            
            // 减少主线程性能消耗, 只将最后一步给主线程
            if OperationQueue.current === inQueue {
                callSuccess()
            } else {
                inQueue.addOperations([BlockOperation(block: callSuccess)], waitUntilFinished: true)
            }
            
            return decodeSuccess
        }
    }
    
    
    public func getURL() -> URL  {
        if let params = _getEncode(url), !params.isEmpty {
            return URL(string: "\(url.absoluteString)?\(params)")!
        } else {
            return url
        }
    }
    
    public func urlRequest() throws -> URLRequest {
        
        let finallyURL = getURL()
        
        var request = URLRequest(url: finallyURL, cachePolicy: policy, timeoutInterval: timeout)
        
        let data = try _postEncode(&request)
        
        if let body = data, !body.isEmpty {
            request.httpMethod = "POST"
            request.httpBody = body
            request.setValue("\(body.count)", forHTTPHeaderField: "Content-Length")
        } else {
            request.httpMethod = "GET"
        }
        
        // 如果有自定义 头信息
        for (key, value) in _headers where !key.isEmpty {
            // add 如果已存在则追加在结尾, 分号间隔
            request.addValue(value, forHTTPHeaderField: key)
        }
        // Accept-Encoding HTTP Header; see https://tools.ietf.org/html/rfc7230#section-4.2.3
        if _headers["Accept-Encoding"] == nil && (request.value(forHTTPHeaderField: "Accept-Encoding")?.isEmpty ?? true) {
            request.setValue("gzip;q=1.0, compress;q=0.5", forHTTPHeaderField: "Accept-Encoding")
        }
        
        // Accept-Language HTTP Header; see https://tools.ietf.org/html/rfc7231#section-5.3.5
        if _headers["Accept-Language"] == nil && (request.value(forHTTPHeaderField: "Accept-Language")?.isEmpty ?? true) {
            request.setValue(HTTP.acceptLanguage, forHTTPHeaderField: "Accept-Language")
        }
        
        if _headers["User-Agent"] == nil && (request.value(forHTTPHeaderField: "User-Agent")?.isEmpty ?? true) {
            request.setValue(HTTP.userAgent, forHTTPHeaderField: "User-Agent")
        }
        
        return request
        
    }
    

}
