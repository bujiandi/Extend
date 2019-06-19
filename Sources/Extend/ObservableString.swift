//
//  ObservableString.swift
//  
//
//  Created by bujiandi on 2019/6/19.
//

import Operator
import Foundation

@inlinable public func <-<O>(lhs:BindingProperty<O,String?>, rhs:@autoclosure () -> ObservableString) {
    let setProperty:(String) -> Void = lhs.setProperty
    let txt = rhs()
    for comment in txt.comments {
        if case .observable(let delegate) = comment {
            delegate.notify(lhs.obj) { setProperty(txt.description) }
        }
    }
}

@inlinable public func <-<O>(lhs:BindingProperty<O,String>, rhs: @autoclosure () -> ObservableString) {
    let setProperty:(String) -> Void = lhs.setProperty
    let txt = rhs()
    for comment in txt.comments {
        if case .observable(let delegate) = comment {
            delegate.notify(lhs.obj) { setProperty(txt.description) }
        }
    }
}

public struct ObservableString: ExpressibleByStringInterpolation, ExpressibleByStringLiteral, CustomStringConvertible {
    
    public struct Delegate: CustomStringConvertible {
        
        let getValue:() -> String
        
        public let notify:(AnyObject, @escaping () -> Void) -> Void
        public var description: String { return getValue() }
        
        public init(_ storage:Observable<String?>, `default` defaultValue: String) {
            notify = { (target, callback) in
                storage.notify(target) { _ in callback() }
            }
            getValue = { storage.value ?? defaultValue }
        }
        
        public init(_ storage:Observable<String>) {
            notify = { (target, callback) in
                storage.notify(target) { _ in callback() }
            }
            getValue = { storage.value }
        }
        
        public init<V>(_ storage:Observable<V?>, `default` defaultValue: V) where V : CustomStringConvertible {
            notify = { (target, callback) in
                storage.notify(target) { _ in callback() }
            }
            getValue = { storage.value?.description ?? defaultValue.description }
        }
        
        public init<V>(_ storage:Observable<V>) where V : CustomStringConvertible {
            notify = { (target, callback) in
                storage.notify(target) { _ in callback() }
            }
            getValue = { storage.value.description }
        }
        
        public init<V>(_ storage:Observable<V?>, `default` defaultValue: V) {
            notify = { (target, callback) in
                storage.notify(target) { _ in callback() }
            }
            getValue = { String(describing: storage.value ?? defaultValue)  }
        }
        
        public init<V>(_ storage:Observable<V>) {
            notify = { (target, callback) in
                storage.notify(target) { _ in callback() }
            }
            getValue = { String(describing: storage.value) }
        }
    }
    
    public enum StringComment {
        case text(String)
        case observable(Delegate)
    }
    
    public struct StringInterpolation: StringInterpolationProtocol {
        
        public var comments:[StringComment] = []
        
        /// 分配足够的空间来容纳双倍文字的文本
        public init(literalCapacity: Int, interpolationCount: Int) {
            comments.reserveCapacity(interpolationCount)
        }
        
        /// 增加普通拼接文本
        public mutating func appendLiteral(_ literal: String) {
            comments.append(.text(literal))
        }
        
        /// 加入可改变的字符串
        public mutating func appendInterpolation(_ storage: Observable<String>) {
            comments.append(.observable(Delegate(storage)))
        }
        
        /// 加入可改变的字符串
        public mutating func appendInterpolation(_ storage: Observable<String?>, `default` value:String = "") {
            comments.append(.observable(Delegate(storage, default: value)))
        }
        
        /// 加入可改变的日期
        public mutating func appendInterpolation(_ storage: Observable<Date>) {
            comments.append(.observable(Delegate(storage)))
        }
        
        /// 加入可改变的日期
        public mutating func appendInterpolation(_ storage: Observable<Date?>, `default` value:Date = Date()) {
            comments.append(.observable(Delegate(storage, default: value)))
        }
        
        /// 加入可改变的值
        public mutating func appendInterpolation<V>(_ storage: Observable<V>) where V : CustomStringConvertible {
            comments.append(.observable(Delegate(storage)))
        }
        
        /// 加入可改变的值
        public mutating func appendInterpolation<V>(_ storage: Observable<V?>, `default` value:V) where V : CustomStringConvertible {
            comments.append(.observable(Delegate(storage, default: value)))
        }
        
        /// 加入可改变的值
        public mutating func appendInterpolation<V>(_ storage: Observable<V>) {
            comments.append(.observable(Delegate(storage)))
        }
        
        /// 加入可改变的值
        public mutating func appendInterpolation<V>(_ storage: Observable<V?>, `default` value:V) {
            comments.append(.observable(Delegate(storage, default: value)))
        }
    }
    
    public let comments:[StringComment]
    public init(stringInterpolation: StringInterpolation) {
        comments = stringInterpolation.comments
    }
    
    public init(stringLiteral value: StringLiteralType) {
        comments = [.text(value)]
    }
    
    public var description: String {
        return comments.joined(separator: "") {
            switch $0 {
            case .text(let value):          return value
            case .observable(let delegate): return delegate.description
            }
        }
    }
}
