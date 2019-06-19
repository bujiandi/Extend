//
//  Store.swift
//  Basic
//
//  Created by bujiandi on 2018/11/24.
//


import Operator
import Protocolar
#if canImport(Foundation)
import Foundation
#endif

//infix operator <=> : AssignmentPrecedence

/// 数据监听器
public final class Storage<T> {
    
//    @inlinable public static func <=><T>(lhs:Store<T>, rhs:Store<T>) {
//        bind(lhs, rhs)
//    }
//    
//    @inlinable public static func bind<T>(_ lhs:Store<T>, _ rhs:Store<T>) {
//        lhs.subscribe(rhs)
//    }
    
    public func subscribe(_ store:Storage<T>) {
        binders.append(WeakContainer(store))
        store.binders.append(WeakContainer(self))
        setValue(store.value)
    }
    
    private var observers : [Observer<T>] = []
    private var binders: [WeakContainer<Storage<T>>] = []
    
    public func notifyChanged() {
        setValue(_value)
        binders = binders.filter {
            $0.obj?.setValue(_value) ?? false
        }
    }
    
    private func _notifyChanged(_ oldValue:T,to newValue:T) {
        let filterObservers:() -> Void = { [unowned self] in
            
            self.observers = self.observers.filter {
                if $0.target == nil { return false }
                $0.notifyChanged(newValue, oldValue)
                return true
            }
        }
        
        #if canImport(Foundation)
        if Thread.current.isMainThread {
            filterObservers()
        } else {
            DispatchQueue.main.sync(execute: filterObservers)
        }
        #else
        filterObservers()
        #endif

    }
    
    @discardableResult
    private func setValue(_ newValue:T) -> Bool {
        let oldValue = _value
        _value = newValue
        
        _notifyChanged(oldValue, to: newValue)
        return true
    }
    
    internal var _value : T
    public var value : T {
        get { return _value }
        set {
            setValue(newValue)
            self.binders = self.binders.filter {
                $0.obj?.setValue(newValue) ?? false
            }
        }
        
    }
    
    public init(_ v : T) { _value = v }
    
    public func syncObservers(from store:Storage<T>) {
        observers = store.observers
    }
    
    public func clearObservers() {
        observers.removeAll()
    }
    
    public func removeObserver(by target: AnyObject){
        observers = observers.filter {
            $0.target !== target && $0.target != nil
        }
    }
    
    @discardableResult
    public func addObserver<This:AnyObject>(_ target: This, change: @escaping (Observed<Handler<This, T>, T>) -> Void) -> Notice<T> {
        let observer = Observer<T>(target) {
            [unowned target, unowned self] (new, old) in
            let handler = Handler(target, &self._value, old)
            change(Observed<Handler<This, T>, T>(valueFrom: old, to: new, tell:  handler))
        }
        observers.append(observer)
        return Notice<T>(self, observer)
    }
    
    @discardableResult
    public func addObserver(_ target: AnyObject, action: Selector, needRelease:Bool = false) -> Notice<T> {
        let observer = Observer<T>(target, action, needRelease)
        observers.append(observer)
        return Notice<T>(self, observer)
    }
    
}

extension Storage {
    
    fileprivate struct Observer<Value> {
        
        weak var target : AnyObject?
        var notifyChanged : Notice
        
        typealias Notice = (_ new:Value, _ old:Value) -> Void
        
        init(_ target: AnyObject, _ notice: @escaping Notice) {
            self.target = target
            self.notifyChanged = notice
        }
        
        init(_ target: AnyObject, _ action: Selector, _ needRelease:Bool = false) {
            self.target = target
            self.notifyChanged = { [weak target] in
                let r = target?.perform(action, with: $0, with: $1)
                if needRelease {
                    r?.release()
                }
            }
        }
        
    }
    
    public class Handler<This, Value>: Recoverable where This: AnyObject {
        public  let this:This
        private let point:UnsafeMutablePointer<Value>
        private let value:Value
        
        fileprivate init(_ target:This, _ new:UnsafeMutablePointer<Value>, _ old:Value) {
            this = target
            point = new
            value = old
        }
        
        public func recover() {
            point.pointee = value
        }
        
    }
    
    public struct Notice<T> {
        
        fileprivate let store : Storage<T>
        fileprivate let observer : Observer<T>
        
        fileprivate init(_ listener:Storage<T>, _ observer:Observer<T>) {
            self.store = listener
            self.observer = observer
        }
        
        public func notifyChanged() {
            let value = store.value
            observer.notifyChanged(value, value)
        }
        
    }
    
}

extension Storage {
    
    @inlinable public static postfix func & <T>(store:Storage<T>) -> T {
        return store.value
    }
    
}

extension Storage {
    
    @inlinable public static func <- (lhs: Storage<T>, rhs: T) {
        lhs.value = rhs
    }
    
    @inlinable public static func <-? (lhs: Storage<T>, rhs: T?) {
        if let value = rhs {
            lhs.value = value
        }
    }
}

extension Storage : CustomStringConvertible where T : CustomStringConvertible {
    @inlinable public var description: String { return value.description }
}


extension Storage : CustomDebugStringConvertible where T : CustomDebugStringConvertible {
    @inlinable public var debugDescription: String { return value.debugDescription }
}

extension Storage : Costable where T : Costable {
    
    @inlinable public var cost: Int { return value.cost }
    
}

extension Storage where T == String {
    
    @inlinable public func append(_ other: String) {
        value.append(other)
    }
    
    @inlinable public static func += (lhs: inout Storage<String>, rhs: String) {
        lhs.value += rhs
    }
    
    @inlinable public func lowercased() -> String {
        return value.lowercased()
    }
    
    @inlinable public func uppercased() -> String {
        return value.uppercased()
    }
    
    @inlinable public var isEmpty: Bool { return value.isEmpty }
    
    @inlinable public var length: Int { return value.length }
    
    @inlinable public func hasPrefix(_ prefix: String) -> Bool {
        return value.hasPrefix(prefix)
    }
    
    @inlinable public func hasSuffix(_ suffix: String) -> Bool {
        return value.hasSuffix(suffix)
    }
    
}


extension Storage where T == Bool {
    
    @inlinable public func toggle() {
        value.toggle()
    }
    
}

extension Storage : Comparable where T : Comparable {
    
    @inlinable public static func < (lhs: Storage<T>, rhs: Storage<T>) -> Bool {
        return lhs.value < rhs.value
    }
    
    @inlinable public static func <= (lhs: Storage<T>, rhs: Storage<T>) -> Bool {
        return lhs.value <= rhs.value
    }
    
    @inlinable public static func >= (lhs: Storage<T>, rhs: Storage<T>) -> Bool {
        return lhs.value >= rhs.value
    }
    
    @inlinable public static func > (lhs: Storage<T>, rhs: Storage<T>) -> Bool {
        return lhs.value > rhs.value
    }
    
}

extension Storage : Equatable where T : Equatable {
    
    @inlinable public static func == (lhs: Storage<T>, rhs: Storage<T>) -> Bool {
        return lhs.value == rhs.value
    }
    
}

extension Storage : Hashable where T : Hashable {
    
    public var hashValue: Int { return value.hashValue }
    
    public func hash(into hasher: inout Hasher) {
        value.hash(into: &hasher)
    }

}

extension Storage : Encodable where T : Encodable {
    
    @inlinable public func encode(to encoder: Encoder) throws {
        try value.encode(to: encoder)
    }

}

extension Storage : Decodable where T : Decodable {
    
    @inlinable public convenience init(from decoder: Decoder) throws {
        self.init(try T(from: decoder))
    }
    
}



extension Storage : RawRepresentable where T : RawRepresentable {
    
    public typealias RawValue = T.RawValue
    
    @inlinable public convenience init?(rawValue: T.RawValue) {
        if let value = T(rawValue: rawValue) {
            self.init(value)
        } else {
            return nil
        }
    }
    
    public var rawValue: T.RawValue { return value.rawValue }
}

extension Storage : ExpressibleByNilLiteral where T : ExpressibleByNilLiteral {
    
    @inlinable public convenience init(nilLiteral: ()) {
        self.init(nil)
    }
    
}

extension Storage : ExpressibleByFloatLiteral where T : ExpressibleByFloatLiteral {
    
    public typealias FloatLiteralType = T.FloatLiteralType
    
    @inlinable public convenience init(floatLiteral value: T.FloatLiteralType) {
        self.init(T(floatLiteral: value))
    }
}

extension Storage : ExpressibleByIntegerLiteral where T : ExpressibleByIntegerLiteral {
    
    public typealias IntegerLiteralType = T.IntegerLiteralType
    
    @inlinable public convenience init(integerLiteral value: T.IntegerLiteralType) {
        self.init(T(integerLiteral: value))
    }
}

extension Storage : ExpressibleByBooleanLiteral where T : ExpressibleByBooleanLiteral {
    
    public typealias BooleanLiteralType = T.BooleanLiteralType
    
    @inlinable public convenience init(booleanLiteral value: T.BooleanLiteralType) {
        self.init(T(booleanLiteral: value))
    }
}

extension Storage : ExpressibleByUnicodeScalarLiteral where T : ExpressibleByUnicodeScalarLiteral {
    
    public typealias UnicodeScalarLiteralType = T.UnicodeScalarLiteralType
    
    @inlinable public convenience init(unicodeScalarLiteral value: T.UnicodeScalarLiteralType) {
        self.init(T(unicodeScalarLiteral: value))
    }
    
}

extension Storage : ExpressibleByExtendedGraphemeClusterLiteral where T : ExpressibleByExtendedGraphemeClusterLiteral {
    
    public typealias ExtendedGraphemeClusterLiteralType = T.ExtendedGraphemeClusterLiteralType
    
    @inlinable public convenience init(extendedGraphemeClusterLiteral value: T.ExtendedGraphemeClusterLiteralType) {
        self.init(T(extendedGraphemeClusterLiteral: value))
    }
    
}
extension Storage : ExpressibleByStringLiteral where T : ExpressibleByStringLiteral {
    
    public typealias StringLiteralType = T.StringLiteralType
    
    @inlinable public convenience init(stringLiteral value: T.StringLiteralType) {
        self.init(T(stringLiteral: value))
    }
    
}

extension Storage : ExpressibleByArrayLiteral where T : ExpressibleByArrayLiteral, T : RangeReplaceableCollection, T.ArrayLiteralElement == T.Element {
    
    public typealias ArrayLiteralElement = T.ArrayLiteralElement
    
    /// Creates an instance initialized with the given elements.
    @inlinable public convenience init(arrayLiteral elements: T.ArrayLiteralElement...) {
        self.init(T(elements))
    }

}


extension Storage : RangeExpression where T : RangeExpression {
    
    public typealias Bound = T.Bound
    
    @inlinable public func relative<C>(to collection: C) -> Range<T.Bound> where C : Collection, T.Bound == C.Index {
        return value.relative(to: collection)
    }
    
    @inlinable public func contains(_ element: T.Bound) -> Bool {
        return value.contains(element)
    }

}

extension Storage : IteratorProtocol where T : IteratorProtocol {
    
    public func next() -> T.Element? {
        return value.next()
    }
    
}

extension Storage : Sequence where T : Sequence {
    
    public typealias Element = T.Element
    
    public typealias Iterator = T.Iterator
    
    @inlinable public func makeIterator() -> T.Iterator {
        return value.makeIterator()
    }
    
    @inlinable public var underestimatedCount: Int { return value.underestimatedCount }
    
    @inlinable public func map<U>(_ transform: (Element) throws -> U) rethrows -> [U] {
        return try value.map(transform)
    }
    
    @inlinable public func filter(_ isIncluded: (Element) throws -> Bool) rethrows -> [Element] {
        return try value.filter(isIncluded)
    }
    
    @inlinable public func forEach(_ body: (Element) throws -> Void) rethrows {
        try value.forEach(body)
    }
    
//    @inline(__always)
//    public func dropFirst(_ k: Int) -> T.SubSequence {
//        return value.dropFirst(k)
//    }
//
//    @inline(__always)
//    public func dropLast(_ k: Int) -> T.SubSequence {
//        return value.dropLast(k)
//    }
//
//    @inline(__always)
//    public func drop(while predicate: (Element) throws -> Bool) rethrows -> SubSequence {
//        return try value.drop(while: predicate)
//    }
//
//    @inline(__always)
//    public func prefix(_ maxLength: Int) -> T.SubSequence {
//        return value.prefix(maxLength)
//    }
//
//    @inline(__always)
//    public func prefix(while predicate: (Element) throws -> Bool) rethrows -> SubSequence {
//        return try value.prefix(while: predicate)
//    }
//
//    @inline(__always)
//    public func suffix(_ maxLength: Int) -> T.SubSequence {
//        return value.suffix(maxLength)
//    }
//
//    @inline(__always)
//    public func split(maxSplits: Int, omittingEmptySubsequences: Bool, whereSeparator isSeparator: (Element) throws -> Bool) rethrows -> [T.SubSequence] {
//        return try value.split(maxSplits: maxSplits, omittingEmptySubsequences: omittingEmptySubsequences, whereSeparator: isSeparator)
//    }
    
}


extension Storage : Collection where T : Collection {
    
    public typealias Index = T.Index
    
    @inlinable public var startIndex: T.Index { return value.startIndex }
    @inlinable public var endIndex: T.Index { return value.endIndex }

    @inlinable public subscript(position: T.Index) -> T.Element {
        return value[position]
    }
    @inlinable public subscript(bounds: Range<T.Index>) -> T.SubSequence {
        return value[bounds]
    }
    
    public typealias Indices = T.Indices
    
    @inlinable public var indices: T.Indices { return value.indices }

    @inlinable public func prefix(upTo end: T.Index) -> T.SubSequence {
        return value.prefix(upTo: end)
    }
    @inlinable public func suffix(from start: T.Index) -> T.SubSequence {
        return value.suffix(from: start)
    }
    @inlinable public func prefix(through position: T.Index) -> T.SubSequence {
        return value.prefix(through: position)
    }
    @inlinable public var isEmpty: Bool { return value.isEmpty }
    
    @inlinable public var count: Int { return value.count }
    
    @inlinable public var first: T.Element? { return value.first }
    
    @inlinable public func index(_ i: T.Index, offsetBy distance: Int) -> T.Index {
        return value.index(i, offsetBy: distance)
    }
    @inlinable public func index(_ i: T.Index, offsetBy distance: Int, limitedBy limit: T.Index) -> T.Index? {
        return value.index(i, offsetBy: distance, limitedBy: limit)
    }
    @inlinable public func distance(from start: T.Index, to end: T.Index) -> Int {
        return value.distance(from: start, to: end)
    }
    @inlinable public func index(after i: T.Index) -> T.Index {
        return value.index(after: i)
    }
    @inlinable public func formIndex(after i: inout T.Index) {
        return value.formIndex(after: &i)
    }
    
    @available(*, deprecated, message: "all index distances are now of type Int")
    public typealias IndexDistance = Int
    
}

extension Storage : MutableCollection where T : MutableCollection {
    
    @inlinable public subscript(position: T.Index) -> T.Element {
        get { return value[position] }
        set { value[position] = newValue }
    }
    
    @inlinable public subscript(bounds: Range<T.Index>) -> T.SubSequence {
        get { return value[bounds] }
        set { value[bounds] = newValue }
    }
    
    @inlinable public func partition(by belongsInSecondPartition: (T.Element) throws -> Bool) rethrows -> T.Index {
        return try value.partition(by: belongsInSecondPartition)
    }
    
    @inlinable public func swapAt(_ i: T.Index, _ j: T.Index) {
        return value.swapAt(i, j)
    }
}

extension Storage : RangeReplaceableCollection where T : RangeReplaceableCollection {
    
    @inlinable public convenience init() {
        self.init(T())
    }
    
    @inlinable public func replaceSubrange<C>(_ subrange: Range<T.Index>, with newElements: C) where C : Collection, T.Element == C.Element {
        value.replaceSubrange(subrange, with: newElements)
    }
    @inlinable public func reserveCapacity(_ n: Int) {
        value.reserveCapacity(n)
    }
    @inlinable public convenience init(repeating repeatedValue: T.Element, count: Int) {
        self.init(T(repeating: repeatedValue, count: count))
    }
    @inlinable public convenience init<S>(_ elements: S) where S : Sequence, T.Element == S.Element {
        self.init(T(elements))
    }
    @inlinable public func append(_ newElement: T.Element) {
        value.append(newElement)
    }
    @inlinable public func append<S>(contentsOf newElements: S) where S : Sequence, T.Element == S.Element {
        value.append(contentsOf: newElements)
    }
    @inlinable public func insert(_ newElement: T.Element, at i: T.Index) {
        value.insert(newElement, at: i)
    }
    @inlinable public func insert<S>(contentsOf newElements: S, at i: T.Index) where S : Collection, T.Element == S.Element {
        value.insert(contentsOf: newElements, at: i)
    }
    
    @discardableResult
    @inlinable public func remove(at i: T.Index) -> T.Element {
        return value.remove(at: i)
    }
    
    @inlinable public func removeSubrange(_ bounds: Range<T.Index>) {
        value.removeSubrange(bounds)
    }
    
    @inlinable public func removeFirst() -> T.Element {
        return value.removeFirst()
    }
    
    @inlinable public func removeFirst(_ k: Int) {
        value.removeFirst(k)
    }
    @inlinable public func removeAll(keepingCapacity keepCapacity: Bool) {
        value.removeAll(keepingCapacity: keepCapacity)
    }
    @inlinable public func removeAll(where predicate: (T.Element) throws -> Bool) rethrows {
        try value.removeAll(where: predicate)
    }
}
