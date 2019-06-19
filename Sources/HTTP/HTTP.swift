//
//  HTTP.swift
//  HTTP
//
//  Created by bujiandi on 2018/9/30.
//

import Foundation

@_exported import Operator
@_exported import Protocolar
@_exported import Extend

public struct HTTP {
    
    // 网络请求状态
    public enum State : Int {
        case waiting
        case loading
        case success
        case failure
    }
    
    // 单个网络请求
    public struct Request {
        
        public let url:URL
        
        var _downloadTarget:DownloadTarget? = nil
        var _previewDownCache:((URL) -> Void)? = nil
        
        var _headers:[String:String] = [:]
        var _policy:URLRequest.CachePolicy = .reloadIgnoringLocalCacheData
        var _timeout:TimeInterval? = nil
        var _postEncode:(inout URLRequest) throws -> Data? = { _ in return nil }
        var _getEncode:(URL) -> String? = { _ in return nil }
        var _decode:(Queue, URLRequest, URLResponse?, Data?, Error?) -> Bool = {
            _, _, _, _, _ in true
        }

    }

    // 网络请求客户端
    open class Client {

        public var threadQueue:DispatchQueue = DispatchQueue(label: "com.fenfen.net.queue", attributes: .concurrent)

        var _concurrent:Int
        
        // 同时进行的任务数量
        public init(concurrentCount:Int = 1) {
            _concurrent = concurrentCount
        }
        
        deinit {
            var sessions:[URLSession]! = ongoingQueues.map { $0.0 }
            threadQueue.async(flags: .barrier) {
                sessions.forEach { $0.invalidateAndCancel() }
                sessions = nil
            }
        }
        
        /// 请求正在进行的组
        lazy var ongoingQueues:[(URLSession, Queue)] = {
            var list = [(URLSession, Queue)]()
            list.reserveCapacity(_concurrent)
            return list
        }()
        
        /// 队列中等待执行的组
        internal var queues:[Queue] = []
        
    }
    
    // 网络请求队列
    open class Queue {
        
        var _tempRequests:[Request] = []
        var _requests:[Request] = []
        var _index:Int = 0
        var _task:URLSessionTask? = nil
        var _finish:((Queue) -> Void)? = nil
        var _complete:((Error?) -> Void)? = nil
        var _retryCount:Int = 0
        
        var _queue:OperationQueue? = nil
        var _progress:Progress = Progress(totalUnitCount: 0)
        
        var _state:State = .waiting
        var _states:[WeakContainer<Storage<State>>] = []
        var _overlays:[WeakOverlay] = []
        weak var _retryOverlay:HTTPFailureRetryOverlay? = nil
        weak var _client:Client? = nil

        lazy var sessionDelegate = _Delegate(self)
        
        deinit {
            if let task = _task {
                task.cancel()
                let info = [NSURLErrorKey:"http queue is released"]
                let error = NSError(domain: NSURLErrorDomain, code: -999, userInfo: info)
                failureCancel(with: error)
            }
            if case .loading = _state {
                if Thread.isMainThread {
                    _overlays.forEach { $0.overlay?.stopNetOverlay() }
                    _states.forEach { $0.obj?.value = .failure }
                } else {
                    let overlays = _overlays
                    let states = _states
                    DispatchQueue.main.async {
                        overlays.forEach { $0.overlay?.stopNetOverlay() }
                        states.forEach { $0.obj?.value = .failure }
                    }
                }
                _state = .failure
            }
            print("组释放",_state)
        }
        
    }
    


    // SessionTaskDelegate
    class _Delegate: NSObject {
        
        weak var queue:Queue?
        var data:Data?
        var error:Error?
        
        init(_ queue:Queue) {
            self.queue = queue
        }
        
    }
    
}
