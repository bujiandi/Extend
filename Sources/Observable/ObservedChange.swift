//
//  ObservedChange.swift
//  Basic
//
//  Created by 慧趣小歪 on 2018/11/24.
//

public struct ObservedChange<Binder, Value> where Binder : AnyObject {
    
    public unowned let binder:Binder
    public let new:Value
    public let old:Value
    
    public init (_ binder:Binder, _ new:Value, _ old:Value) {
        self.binder = binder
        self.new = new
        self.old = old
    }
    
    public init (_ binder:Binder, _ new:Value) {
        self.binder = binder
        self.new = new
        self.old = new
    }
    
}


extension ObservedChange where Binder : Recoverable {
    
    public func recoverValue() {
        binder.recoverValue()
    }
    
}


extension ObservedChange where Binder : Listener<Value> {
    
    public func recoverValue() {
        binder._value = old
    }
    
    public func recoverValueAndNoticeChange() {
        binder.value = old
    }
    
}

extension ObservedChange where Binder : Store<Value> {
    
    public func recoverValue() {
        binder._value = old
    }
    
    public func recoverValueAndNoticeChange() {
        binder.value = old
    }
    
}
