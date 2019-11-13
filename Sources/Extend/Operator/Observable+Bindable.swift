//
//  Observable+Bindable.swift
//  
//
//  Created by bujiandi on 2019/6/19.
//

//import Operator
//import Protocolar
import Foundation
//import Adapter

public struct BindingProperty<Object: AnyObject, Value> {
    public let obj:Object
    public let setProperty:(Value) -> Void
    
    public init(_ target:Object, keyPath:WritableKeyPath<Object, Value>) {
        obj = target
        setProperty = { [weak target] in
            target?[keyPath: keyPath] = $0
        }
    }
    
    public init(_ target:Object, setValue: @escaping (Value) -> Void) {
        obj = target
        setProperty = setValue
    }
}

#if swift(>=5.1)

@dynamicMemberLookup public protocol BindedProperty: class {
    
    subscript<Subject>(dynamicMember keyPath: WritableKeyPath<Self, Subject>) -> BindingProperty<Self, Subject> { get }

}

extension BindedProperty {

    public subscript<Subject>(dynamicMember keyPath: WritableKeyPath<Self, Subject>) -> BindingProperty<Self, Subject> {
        return BindingProperty<Self, Subject>(self, keyPath: keyPath)
    }
}

#endif

extension Bindable {
    
    @inlinable public subscript<Subject>(keyPath: WritableKeyPath<Self, Subject>) -> BindingProperty<Self, Subject> {
        return BindingProperty<Self, Subject>(self, keyPath: keyPath)
    }
    
}

//@inlinable public func <=><O,V>(lhs:BindingProperty<O,V>, rhs:Observable<V>) {
//    let setProperty:(V) -> Void = lhs.setProperty
//    rhs.notify(lhs.obj) { setProperty($0.new) }
//}
//
//@inlinable public func <=><O,V>(lhs:BindingProperty<O,V?>, rhs:Observable<V>) {
//    let setProperty:(V?) -> Void = lhs.setProperty
//    rhs.notify(lhs.obj) { setProperty($0.new) }
//}

@inlinable public func <-<O,V>(lhs:BindingProperty<O,V>, rhs:Observable<V>) {
    let setProperty:(V) -> Void = lhs.setProperty
    rhs.notify(lhs.obj) { setProperty($0.new) }
}

@inlinable public func <-<O,V>(lhs:BindingProperty<O,V?>, rhs:Observable<V>) {
    let setProperty:(V?) -> Void = lhs.setProperty
    rhs.notify(lhs.obj) { setProperty($0.new) }
}

//@dynamicMemberLookup
//public protocol Bindable: class {
//
//    subscript<Subject>(dynamicMember keyPath: WritableKeyPath<Self, Subject>) -> BindingProperty<Self, Subject> { get }
//
//}
//extension Bindable {
//
//    /// Creates a new `Observable` focused on `Subject` using a key path.
//    @inlinable public subscript<Subject>(dynamicMember keyPath: WritableKeyPath<Self, Subject>) -> BindingProperty<Self, Subject> {
//        return BindingProperty<Self, Subject>(self, keyPath: keyPath)
//    }
//}



extension Adapter where Self: AnyObject {
    
    /// 适配器在`storage`发送变化时自动填充`view`
    /// - Parameter view: 需要填充的VIEW
    /// - Parameter storage: 需要关注的数据变化
    @inlinable public func bind<View: Bindable, Value>(_ view:View,_ storage:Observable<Value>) where View == Self.View, Self.Data == Value {
        return view.bind(self, storage)
    }
}

extension Bindable where Self: AnyObject {
    
    /// 绑定keyPath的可选属性 供 `<-` 运算符关联数据
    @inlinable public func bind<Subject>(_ keyPath:WritableKeyPath<Self, Subject?>) -> BindingProperty<Self, Subject?> {
        return BindingProperty<Self, Subject?>(self, keyPath: keyPath)
    }
    
    /// 绑定keyPath的属性 供 `<-` 运算符关联数据
    @inlinable public func bind<Subject>(_ keyPath:WritableKeyPath<Self, Subject>) -> BindingProperty<Self, Subject> {
        return BindingProperty<Self, Subject>(self, keyPath: keyPath)
    }
    
    /// 绑定数据变化
    @inlinable public func bind<Subject>(_ storage:Observable<Subject>, didChange callback: @escaping (Observed<Self, Subject>) -> Void) {
        storage.notify(self, didChange: callback)
    }
    
    /// 绑定keyPath的可选属性和监听枚举数据
    @inlinable public func bind<A: Adapter & AnyObject, Value>(_ adapter:A,_ storage:Observable<Value>) where A.View == Self, A.Data == Value {
        storage.notify(self) { [weak adapter] in
            adapter?.update($0.this, by: $0.new)
        }
    }
    
    /// 绑定keyPath的可选属性和监听枚举数据
    @inlinable public func bind<Subject, Value>(_ keyPath:WritableKeyPath<Self, Subject?>,_ storage:Observable<Value>) where Value : RawRepresentable, Value.RawValue == Subject {
        storage.notify(self) { [weak self] in
            self?[keyPath: keyPath] = $0.new.rawValue
        }
    }
    
    /// 绑定keyPath的可选属性和监听枚举数据
    @inlinable public func bind<Subject, Value>(_ keyPath:WritableKeyPath<Self, Subject>,_ storage:Observable<Value>) where Value : RawRepresentable, Value.RawValue == Subject {
        storage.notify(self) { [weak self] in
            self?[keyPath: keyPath] = $0.new.rawValue
        }
    }
    
    /// 绑定keyPath的可选属性和监听数据
    @inlinable public func bind<Subject>(_ keyPath:WritableKeyPath<Self, Subject?>,_ storage:Observable<Subject>) {
        storage.notify(self) { [weak self] in
            self?[keyPath: keyPath] = $0.new
        }
    }
    
    /// 绑定keyPath的属性和监听数据
    @inlinable public func bind<Subject>(_ keyPath:WritableKeyPath<Self, Subject>,_ storage:Observable<Subject>) {
        storage.notify(self) { [weak self] in
            self?[keyPath: keyPath] = $0.new
        }
    }
    
    /// 绑定keyPath的属性和监听数据 并确定数据 和 可选属性值的关系
    @inlinable public func bind<Subject, Value>(_ keyPath:WritableKeyPath<Self, Subject?>,_ storage:Observable<Value>, onChanged: @escaping (Value) -> Subject? ) {
        storage.notify(self) { [weak self] in
            self?[keyPath: keyPath] = onChanged($0.new)
        }
    }
    
    /// 绑定keyPath的属性和监听数据 并确定数据 和 属性值的关系
    @inlinable public func bind<Subject, Value>(_ keyPath:WritableKeyPath<Self, Subject>,_ storage:Observable<Value>, onChanged: @escaping (Value) -> Subject ) {
        storage.notify(self) { [weak self] in
            self?[keyPath: keyPath] = onChanged($0.new)
        }
    }
    
}
