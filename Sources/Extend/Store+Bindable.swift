//
//  StoreBindable.swift
//  Basic
//
//  Created by bujiandi on 2018/11/24.
//

import Protocolar
import Foundation
import Adapter

extension NSObject: Bindable {}

extension Bindable {
    
    @discardableResult
    public func bind<Data>(_ store:Store<Data>, onChange: @escaping (ObservedChange<Self, Data>) -> Void) -> Store<Data>.Notice<Data> {
        return store.addObserver(self) { [weak self] in
            if let this = self {
                onChange(ObservedChange(this, $0.new, $0.old))
            }
        }
    }
    
    /// 绑定keyPath的可选属性和监听枚举数据
    @discardableResult
    public func bind<A: Adapter, Value>(_ adapter:A,_ store:Store<Value>) -> Store<Value>.Notice<Value> where A.View == Self, A.Data == Value {
        return store.addObserver(self) { [weak self] in
            guard let self = self else { return }
            adapter.update(self, by: $0.new)
        }
    }
    
    /// 绑定keyPath的可选属性和监听枚举数据
    @discardableResult
    public func bind<Data, Value>(_ keyPath:WritableKeyPath<Self, Data?>,_ store:Store<Value>) -> Store<Value>.Notice<Value> where Value : RawRepresentable, Value.RawValue == Data {
        return store.addObserver(self) { [weak self] in
            self?[keyPath: keyPath] = $0.new.rawValue
        }
    }
    
    /// 绑定keyPath的可选属性和监听枚举数据
    @discardableResult
    public func bind<Data, Value>(_ keyPath:WritableKeyPath<Self, Data>,_ store:Store<Value>) -> Store<Value>.Notice<Value> where Value : RawRepresentable, Value.RawValue == Data {
        return store.addObserver(self) { [weak self] in
            self?[keyPath: keyPath] = $0.new.rawValue
        }
    }
    
    /// 绑定keyPath的可选属性和监听数据
    @discardableResult
    public func bind<Data>(_ keyPath:WritableKeyPath<Self, Data?>,_ store:Store<Data>) -> Store<Data>.Notice<Data> {
        return store.addObserver(self) { [weak self] in
            self?[keyPath: keyPath] = $0.new
        }
    }
    
    /// 绑定keyPath的属性和监听数据
    @discardableResult
    public func bind<Data>(_ keyPath:WritableKeyPath<Self, Data>,_ store:Store<Data>) -> Store<Data>.Notice<Data> {
        return store.addObserver(self) { [weak self] in
            self?[keyPath: keyPath] = $0.new
        }
    }
    
    /// 绑定keyPath的属性和监听数据 并确定数据 和 可选属性值的关系
    @discardableResult
    public func bind<Data, Value>(_ keyPath:WritableKeyPath<Self, Value?>,_ store:Store<Data>, onChanged: @escaping (Data) -> Value ) -> Store<Data>.Notice<Data> {
        return store.addObserver(self) { [weak self] in
            self?[keyPath: keyPath] = onChanged($0.new)
        }
    }
    
    /// 绑定keyPath的属性和监听数据 并确定数据 和 属性值的关系
    @discardableResult
    public func bind<Data, Value>(_ keyPath:WritableKeyPath<Self, Value>,_ store:Store<Data>, onChanged: @escaping (Data) -> Value ) -> Store<Data>.Notice<Data> {
        return store.addObserver(self) { [weak self] in
            self?[keyPath: keyPath] = onChanged($0.new)
        }
    }
    
}
