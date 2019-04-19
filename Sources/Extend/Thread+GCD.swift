//
//  Array+Utils.swift
//
//  Created by bujiandi on 14/10/4.
//

import Foundation

public struct DispatchHelper {
    
    public let queue:DispatchQueue
    
    public init(_ queue:DispatchQueue) {
        self.queue = queue
    }
    
    public func asyncMain(execute work: @escaping @convention(block) () -> Void) {
        DispatchQueue.main.async(execute: work)
    }
    
    public func syncMain(execute work: @escaping @convention(block) () -> Void) {
        DispatchQueue.main.sync(execute: work)
    }
}

extension DispatchQueue {
    
    public func asyncHelper(execute work: @escaping @convention(block) () -> Void) -> DispatchHelper {
        
        var helper:DispatchHelper? = DispatchHelper(self)
        async {
            work()
            helper = nil
        }
        return helper!
    }
    
    public static var userInteractive: DispatchQueue { return DispatchQueue.global(qos: .userInteractive) }
    public static var userInitiated: DispatchQueue { return DispatchQueue.global(qos: .userInitiated) }
    public static var utility: DispatchQueue { return DispatchQueue.global(qos: .utility) }
    public static var background: DispatchQueue { return DispatchQueue.global(qos: .background) }
    
    public func asyncAfter(delay: TimeInterval, execute closure: @escaping @convention(block) () -> Void) {
        asyncAfter(deadline: .now() + delay, execute: closure)
    }
    
}
