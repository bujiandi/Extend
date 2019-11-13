//
//  StoreBindable.swift
//  Basic
//
//  Created by bujiandi on 2018/11/24.
//

//import Protocolar
import Foundation
//import Adapter

extension NSObject: Bindable {}

extension Adapter where Self: AnyObject {
    
    @discardableResult
    @inlinable public func bind<View: Bindable, Value>(_ view:View,_ store:Storage<Value>) -> Storage<Value>.Notice<Value> where View == Self.View, Self.Data == Value {
        return view.bind(self, store)
    }
}

extension Bindable {
    
    @discardableResult
    public func bind<Data>(_ store:Storage<Data>, onChange: @escaping (Observed<Self, Data>) -> Void) -> Storage<Data>.Notice<Data> {
        return store.addObserver(self) { [weak self] in
            if let this = self {
                onChange(Observed(valueFrom: $0.old, to: $0.new, notify: this))
            }
        }
    }
    
    /// 绑定keyPath的可选属性和监听枚举数据
    @discardableResult
    public func bind<A: Adapter & AnyObject, Value>(_ adapter:A,_ store:Storage<Value>) -> Storage<Value>.Notice<Value> where A.View == Self, A.Data == Value {
        return store.addObserver(self) { [weak self, weak adapter] in
            guard let self = self else { return }
            adapter?.update(self, by: $0.new)
        }
    }
    
    /// 绑定keyPath的可选属性和监听枚举数据
    @discardableResult
    public func bind<Data, Value>(_ keyPath:WritableKeyPath<Self, Data?>,_ store:Storage<Value>) -> Storage<Value>.Notice<Value> where Value : RawRepresentable, Value.RawValue == Data {
        return store.addObserver(self) { [weak self] in
            self?[keyPath: keyPath] = $0.new.rawValue
        }
    }
    
    /// 绑定keyPath的可选属性和监听枚举数据
    @discardableResult
    public func bind<Data, Value>(_ keyPath:WritableKeyPath<Self, Data>,_ store:Storage<Value>) -> Storage<Value>.Notice<Value> where Value : RawRepresentable, Value.RawValue == Data {
        return store.addObserver(self) { [weak self] in
            self?[keyPath: keyPath] = $0.new.rawValue
        }
    }
    
    /// 绑定keyPath的可选属性和监听数据
    @discardableResult
    public func bind<Data>(_ keyPath:WritableKeyPath<Self, Data?>,_ store:Storage<Data>) -> Storage<Data>.Notice<Data> {
        return store.addObserver(self) { [weak self] in
            self?[keyPath: keyPath] = $0.new
        }
    }
    
    /// 绑定keyPath的属性和监听数据
    @discardableResult
    public func bind<Data>(_ keyPath:WritableKeyPath<Self, Data>,_ store:Storage<Data>) -> Storage<Data>.Notice<Data> {
        return store.addObserver(self) { [weak self] in
            self?[keyPath: keyPath] = $0.new
        }
    }
    
    /// 绑定keyPath的属性和监听数据 并确定数据 和 可选属性值的关系
    @discardableResult
    public func bind<Data, Value>(_ keyPath:WritableKeyPath<Self, Value?>,_ storage:Storage<Data>, onChanged: @escaping (Data) -> Value? ) -> Storage<Data>.Notice<Data> {
        return storage.addObserver(self) { [weak self] in
            self?[keyPath: keyPath] = onChanged($0.new)
        }
    }
    
    /// 绑定keyPath的属性和监听数据 并确定数据 和 属性值的关系
    @discardableResult
    public func bind<Data, Value>(_ keyPath:WritableKeyPath<Self, Value>,_ store:Storage<Data>, onChanged: @escaping (Data) -> Value ) -> Storage<Data>.Notice<Data> {
        return store.addObserver(self) { [weak self] in
            self?[keyPath: keyPath] = onChanged($0.new)
        }
    }
    
}
