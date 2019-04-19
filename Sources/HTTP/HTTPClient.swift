//
//  HTTPGroup.swift
//  Basic
//
//  Created by 李招利 on 2018/9/30.
//

import Foundation

extension HTTP.Client {
    
    // 创建一个请求队列
    open func queueRequest(url:URL, _ initializer:(inout HTTP.Request) -> Void) -> HTTP.Queue {
        let queue = HTTP.Queue()
        queue.request(url: url, initializer)
        return queue
    }
    
    func send(queue:HTTP.Queue) {
        threadQueue.async(flags: .barrier) { [weak self] in
            guard let this = self else { return }
            this.queues.append(queue)
            this.resume()
        }
    }
}

// MARK: - 主要
extension HTTP.Client {
    
    func resume() {
        if Thread.current === threadQueue {
            _resume()
        } else {
            threadQueue.async(flags: .barrier) { [weak self] in self?._resume() }
        }
    }
    
    private func _resume() {
        while queues.count > 0, ongoingQueues.count < _concurrent {
            
            let queue = queues.removeFirst()
            
            // 跳过数量为空的组
            if queue.isEmpty { continue }
            
            let session = sessionFactory(queue)

            // 将有任务的组添加到请求队列
            ongoingQueues.append((session, queue))
            queue._task = nil
            queue._index = 0
            queue._finish = { [weak self] (queue) in self?.complete(queue: queue) }
            queue.startOverlays()
            queue.resume(session: session)
        }
    }
    
//    func restart(group:NetGroup) {
//        if let (task, request) = group.ongoingRequest {
//            request.cancel(task: task)
//            group.ongoingRequest = nil
//        }
//        for (session, ongoing) in ongoingQueues where ongoing === group {
//            group.resume(session: session)
//        }
//    }
    
    func complete(queue:HTTP.Queue) {
        // 为了确保线程安全, 所以在统一线程队列中
        threadQueue.async(flags: .barrier) { [weak self] in
            guard let this = self else { return }
            if let index = this.ongoingQueues.firstIndex(where: { $0.1 === queue }) {
                // 非默认shared URLSession 释放前如果不取消，会引发循环引用
                let (session, queue) = this.ongoingQueues.remove(at: index)
                queue.cancel()
                session.finishTasksAndInvalidate()
                this.resume()
            }
        }
    }
    
    func sessionFactory(_ queue:HTTP.Queue) -> URLSession {
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config, delegate: queue.sessionDelegate, delegateQueue: queue._queue ?? .main)
        
        return session
    }
    
}


// MARK: - 数量
extension HTTP.Client {
    
    public func cancelAll() {
        threadQueue.async(flags: .barrier) { [weak self] in
            guard let this = self else { return }
            let list = this.ongoingQueues
            this.ongoingQueues.removeAll(keepingCapacity: true)
            list.forEach { $0.1.cancel() }
        }
    }
    
    public func cancel(where block:(HTTP.Queue) -> Bool) {
        var needResume:Bool = false
        for (i, queue) in queues.enumerated().reversed() where block(queue) {
            queues.remove(at: i)
        }
        for (i, (session, queue)) in ongoingQueues.enumerated().reversed() where block(queue) {
            threadQueue.async(flags: .barrier) { [weak self] in
                self?.ongoingQueues.remove(at: i)
                queue.cancel()
                session.finishTasksAndInvalidate()
            }
            needResume = true
        }
        if needResume {
            threadQueue.async(flags: .barrier) { [weak self] in self?.resume() }
        }
    }
    
    /// 能同时进行的网络请求组数量 [>= 1]
    public var concurrentCount:Int {
        get { return _concurrent }
        set {
            // 如果设置的数量小于 1 则忽略
            if newValue < 1 { return }
            _concurrent = newValue
            // 移除多余正在进行的组，并取消组请求，重新加入队列顶部
            while ongoingQueues.count > newValue {
                let (_, last) = ongoingQueues.removeLast()
                last.cancel()
                queues.insert(last, at: 0)
            }
            ongoingQueues.reserveCapacity(newValue)
        }
    }
    
    /// 正在执行的组数量
    public var ongoingCount:Int {
        return ongoingQueues.count
    }
    
    /// 队列中 请求组数量
    public var count:Int {
        return queues.count + ongoingQueues.count
    }
    
    /// 队列中 所有组 总请求数量
    public var requestCount:Int {
        let list = queues + ongoingQueues.map { $0.1 }
        return list.reduce(0) { $0 + $1.count }
    }
    
    
}
