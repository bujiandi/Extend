//
//  ObservedChange.swift
//  Basic
//
//  Created by bujiandi on 2018/11/24.
//

import Protocolar

public struct ObservedChange<Binder, Value> where Binder : AnyObject {
    
    public unowned let binder:Binder
    public let new:Value
    public let old:Value
    
    public init(_ binder:Binder, _ new:Value, _ old:Value) {
        self.binder = binder
        self.new = new
        self.old = old
    }
    
    public init(_ binder:Binder, _ new:Value) {
        self.binder = binder
        self.new = new
        self.old = new
    }
    
}

extension ObservedChange : Recoverable where Binder : Recoverable {
    
    public func recover() {
        binder.recover()
    }
    
}

extension ObservedChange where Binder : Store<Value> {
    
    public func recover() {
        binder._value = old
    }
    
    public func recoverAndNotifyChanged() {
        binder.value = old
    }
    
}

