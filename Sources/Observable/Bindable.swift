//
//  Bindable.swift
//  Basic
//
//  Created by 慧趣小歪 on 2018/11/24.
//

public protocol Bindable: class { }

extension Bindable {
    
    @discardableResult
    public func bind<Data>(_ listener:Listener<Data>, onChange: @escaping (ObservedChange<Self, Data>) -> Void) -> Listener<Data>.Notice<Data> {
        return listener.addNotice(target: self) { [weak self] in
            if let this = self {
                onChange(ObservedChange(this, $0.new, $0.old))
            }
        }
    }
    
    /// 绑定keyPath的可选属性和监听枚举数据
    @discardableResult
    public func bind<Data, Value>(_ keyPath:WritableKeyPath<Self, Data?>,_ listener:Listener<Value>) -> Listener<Value>.Notice<Value> where Value : RawRepresentable, Value.RawValue == Data {
        return listener.addNotice(target: self) { [weak self] in
            self?[keyPath: keyPath] = $0.new.rawValue
        }
    }
    
    /// 绑定keyPath的可选属性和监听枚举数据
    @discardableResult
    public func bind<Data, Value>(_ keyPath:WritableKeyPath<Self, Data>,_ listener:Listener<Value>) -> Listener<Value>.Notice<Value> where Value : RawRepresentable, Value.RawValue == Data {
        return listener.addNotice(target: self) { [weak self] in
            self?[keyPath: keyPath] = $0.new.rawValue
        }
    }
    
    /// 绑定keyPath的可选属性和监听数据
    @discardableResult
    public func bind<Data>(_ keyPath:WritableKeyPath<Self, Data?>,_ listener:Listener<Data>) -> Listener<Data>.Notice<Data> {
        return listener.addNotice(target: self) { [weak self] in
            self?[keyPath: keyPath] = $0.new
        }
    }
    
    /// 绑定keyPath的属性和监听数据
    @discardableResult
    public func bind<Data>(_ keyPath:WritableKeyPath<Self, Data>,_ listener:Listener<Data>) -> Listener<Data>.Notice<Data> {
        return listener.addNotice(target: self) { [weak self] in
            self?[keyPath: keyPath] = $0.new
        }
    }
    
    /// 绑定keyPath的属性和监听数据 并确定数据 和 可选属性值的关系
    @discardableResult
    public func bind<Data, Value>(_ keyPath:WritableKeyPath<Self, Value?>,_ listener:Listener<Data>, onChanged: @escaping (Data) -> Value ) -> Listener<Data>.Notice<Data> {
        return listener.addNotice(target: self) { [weak self] in
            self?[keyPath: keyPath] = onChanged($0.new)
        }
    }
    
    /// 绑定keyPath的属性和监听数据 并确定数据 和 属性值的关系
    @discardableResult
    public func bind<Data, Value>(_ keyPath:WritableKeyPath<Self, Value>,_ listener:Listener<Data>, onChanged: @escaping (Data) -> Value ) -> Listener<Data>.Notice<Data> {
        return listener.addNotice(target: self) { [weak self] in
            self?[keyPath: keyPath] = onChanged($0.new)
        }
    }
    
}
