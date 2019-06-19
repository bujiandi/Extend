//
//  ObservedChange.swift
//  Basic
//
//  Created by bujiandi on 2018/11/24.
//

import Protocolar

public struct Observed<This, Value> where This : AnyObject {
    
    public let old:Value
    public let new:Value
    public  unowned let this:This
    
    public init(valueFrom oldValue:Value, to newValue:Value, tell target:This) {
        old = oldValue
        new = newValue
        this = target
    }
    
    public init(setValue newValue:Value, tell target:This) {
        old = newValue
        new = newValue
        this = target
    }
    
}

extension Observed : Recoverable where This : Recoverable {
    
    public func recover() {
        this.recover()
    }
    
}

extension Observed where This : Storage<Value> {
    
    public func recover() {
        this._value = old
    }
    
    public func recoverAndNotifyChanged() {
        this.value = old
    }
    
}

