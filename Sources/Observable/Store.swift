//
//  Store.swift
//  Basic
//
//  Created by 慧趣小歪 on 2018/11/24.
//


#if canImport(Operator)
import Operator
#endif
#if canImport(Foundation)
import Foundation
#endif
/// 数据监听器
public final class Store<T> {
    
    private var observers : [Observer<T>] = []
    
    internal var _value : T
    public var value : T {
        get { return _value }
        set {
            let oldValue = _value
            _value = newValue
            
            let filterObservers:() -> Void = { [unowned self] in
                
                self.observers = self.observers.filter {
                    if $0.target == nil { return false }
                    $0.notice(newValue, oldValue)
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
        
    }
    
    public init(_ v : T) { _value = v }
    
    public func syncObservers(from listener:Store<T>) {
        observers = listener.observers
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
    public func addObserver<This:AnyObject>(target: This, change: @escaping (ObservedChange<Handler<This, T>, T>) -> Void) -> Notice<T> {
        let observer = Observer<T>(target) {
            [unowned target, unowned self] (new, old) in
            let handler = Handler(target, &self._value, old)
            change(ObservedChange<Handler<This, T>, T>(handler, new, old))
        }
        observers.append(observer)
        return Notice<T>(self, observer)
    }
    
    @discardableResult
    public func addObserver(target: AnyObject, action: Selector, needRelease:Bool = false) -> Notice<T> {
        let observer = Observer<T>(target, action, needRelease)
        observers.append(observer)
        return Notice<T>(self, observer)
    }
    
}

extension Store {
    
    fileprivate struct Observer<Value> {
        
        weak var target : AnyObject?
        var notice : Notice
        
        typealias Notice = (_ new:Value, _ old:Value) -> Void
        
        init(_ target: AnyObject, _ notice: @escaping Notice) {
            self.target = target
            self.notice = notice
        }
        
        init(_ target: AnyObject, _ action: Selector, _ needRelease:Bool = false) {
            self.target = target
            self.notice = { [weak target] in
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
        
        public func recoverValue() {
            point.pointee = value
        }
        
    }
    
    public struct Notice<T> {
        
        fileprivate let listener : Store<T>
        fileprivate let observer : Observer<T>
        
        fileprivate init(_ listener:Store<T>, _ observer:Observer<T>) {
            self.listener = listener
            self.observer = observer
        }
        
        public func changed() {
            let value = listener.value
            observer.notice(value, value)
        }
        
    }
    
}

#if canImport(Operator)
extension Store {
    
    @inline(__always)
    public static postfix func & <T>(store:Store<T>) -> T {
        return store.value
    }
    
}

extension Store {
    
    @inline(__always)
    public static func <- (lhs: Store<T>, rhs: T) {
        lhs.value = rhs
    }
    
    @inline(__always)
    public static func <-? (lhs: Store<T>, rhs: T?) {
        if let value = rhs {
            lhs.value = value
        }
    }
}
#endif


extension Store : CustomStringConvertible where T : CustomStringConvertible {
    public var description: String { return value.description }
}


extension Store : CustomDebugStringConvertible where T : CustomDebugStringConvertible {
    public var debugDescription: String { return value.debugDescription }
}

extension Store : Costable where T : Costable {
    
    public var cost: Int { return value.cost }
    
}

extension Store where T == String {
    
    @inline(__always)
    public func append(_ other: String) {
        value.append(other)
    }
    
    @inline(__always)
    public static func += (lhs: inout Store<String>, rhs: String) {
        lhs.value += rhs
    }
    
    @inline(__always)
    public func lowercased() -> String {
        return value.lowercased()
    }
    
    @inline(__always)
    public func uppercased() -> String {
        return value.uppercased()
    }
    
    public var isEmpty: Bool { return value.isEmpty }
    
    public var length: Int { return value.length }
    
    @inline(__always)
    public func hasPrefix(_ prefix: String) -> Bool {
        return value.hasPrefix(prefix)
    }
    
    @inline(__always)
    public func hasSuffix(_ suffix: String) -> Bool {
        return value.hasSuffix(suffix)
    }
    
}


extension Store where T == Bool {
    
    @inline(__always)
    public func toggle() {
        value.toggle()
    }
    
}

extension Store : Comparable where T : Comparable {
    
    @inline(__always)
    public static func < (lhs: Store<T>, rhs: Store<T>) -> Bool {
        return lhs.value < rhs.value
    }
    
    @inline(__always)
    public static func <= (lhs: Store<T>, rhs: Store<T>) -> Bool {
        return lhs.value <= rhs.value
    }
    
    @inline(__always)
    public static func >= (lhs: Store<T>, rhs: Store<T>) -> Bool {
        return lhs.value >= rhs.value
    }
    
    @inline(__always)
    public static func > (lhs: Store<T>, rhs: Store<T>) -> Bool {
        return lhs.value > rhs.value
    }
    
}

extension Store : Equatable where T : Equatable {
    
    @inline(__always)
    public static func == (lhs: Store<T>, rhs: Store<T>) -> Bool {
        return lhs.value == rhs.value
    }
    
}

extension Store : Hashable where T : Hashable {
    
    public var hashValue: Int { return value.hashValue }
    
    public func hash(into hasher: inout Hasher) {
        value.hash(into: &hasher)
    }

}

extension Store : Encodable where T : Encodable {
    
    @inline(__always)
    public func encode(to encoder: Encoder) throws {
        try value.encode(to: encoder)
    }

}

extension Store : Decodable where T : Decodable {
    
    @inline(__always)
    public convenience init(from decoder: Decoder) throws {
        self.init(try T(from: decoder))
    }
    
}



extension Store : RawRepresentable where T : RawRepresentable {
    
    public typealias RawValue = T.RawValue
    
    @inline(__always)
    public convenience init?(rawValue: T.RawValue) {
        if let value = T(rawValue: rawValue) {
            self.init(value)
        } else {
            return nil
        }
    }
    
    public var rawValue: T.RawValue { return value.rawValue }
}

extension Store : ExpressibleByNilLiteral where T : ExpressibleByNilLiteral {
    
    @inline(__always)
    public convenience init(nilLiteral: ()) {
        self.init(nil)
    }
    
}

extension Store : ExpressibleByFloatLiteral where T : ExpressibleByFloatLiteral {
    
    public typealias FloatLiteralType = T.FloatLiteralType
    
    @inline(__always)
    public convenience init(floatLiteral value: T.FloatLiteralType) {
        self.init(T(floatLiteral: value))
    }
}

extension Store : ExpressibleByIntegerLiteral where T : ExpressibleByIntegerLiteral {
    
    public typealias IntegerLiteralType = T.IntegerLiteralType
    
    @inline(__always)
    public convenience init(integerLiteral value: T.IntegerLiteralType) {
        self.init(T(integerLiteral: value))
    }
}

extension Store : ExpressibleByBooleanLiteral where T : ExpressibleByBooleanLiteral {
    
    public typealias BooleanLiteralType = T.BooleanLiteralType
    
    @inline(__always)
    public convenience init(booleanLiteral value: T.BooleanLiteralType) {
        self.init(T(booleanLiteral: value))
    }
}

extension Store : ExpressibleByUnicodeScalarLiteral where T : ExpressibleByUnicodeScalarLiteral {
    
    public typealias UnicodeScalarLiteralType = T.UnicodeScalarLiteralType
    
    @inline(__always)
    public convenience init(unicodeScalarLiteral value: T.UnicodeScalarLiteralType) {
        self.init(T(unicodeScalarLiteral: value))
    }
    
}

extension Store : ExpressibleByExtendedGraphemeClusterLiteral where T : ExpressibleByExtendedGraphemeClusterLiteral {
    
    public typealias ExtendedGraphemeClusterLiteralType = T.ExtendedGraphemeClusterLiteralType
    
    @inline(__always)
    public convenience init(extendedGraphemeClusterLiteral value: T.ExtendedGraphemeClusterLiteralType) {
        self.init(T(extendedGraphemeClusterLiteral: value))
    }
    
}
extension Store : ExpressibleByStringLiteral where T : ExpressibleByStringLiteral {
    
    public typealias StringLiteralType = T.StringLiteralType
    
    @inline(__always)
    public convenience init(stringLiteral value: T.StringLiteralType) {
        self.init(T(stringLiteral: value))
    }
    
}

extension Store : ExpressibleByArrayLiteral where T : ExpressibleByArrayLiteral, T : RangeReplaceableCollection, T.ArrayLiteralElement == T.Element {
    
    public typealias ArrayLiteralElement = T.ArrayLiteralElement
    
    /// Creates an instance initialized with the given elements.
    public convenience init(arrayLiteral elements: T.ArrayLiteralElement...) {
        self.init(T(elements))
    }

}


extension Store : RangeExpression where T : RangeExpression {
    
    public typealias Bound = T.Bound
    
    @inline(__always)
    public func relative<C>(to collection: C) -> Range<T.Bound> where C : Collection, T.Bound == C.Index {
        return value.relative(to: collection)
    }
    
    @inline(__always)
    public func contains(_ element: T.Bound) -> Bool {
        return value.contains(element)
    }

}

extension Store : IteratorProtocol where T : IteratorProtocol {
    
    public func next() -> T.Element? {
        return value.next()
    }
    
}

extension Store : Sequence where T : Sequence {
    
    public typealias Element = T.Element
    
    public typealias Iterator = T.Iterator
    
    
    @inline(__always)
    public func makeIterator() -> T.Iterator {
        return value.makeIterator()
    }
    
    public var underestimatedCount: Int { return value.underestimatedCount }
    
    @inline(__always)
    public func map<U>(_ transform: (Element) throws -> U) rethrows -> [U] {
        return try value.map(transform)
    }
    
    @inline(__always)
    public func filter(_ isIncluded: (Element) throws -> Bool) rethrows -> [Element] {
        return try value.filter(isIncluded)
    }
    
    @inline(__always)
    public func forEach(_ body: (Element) throws -> Void) rethrows {
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


extension Store : Collection where T : Collection {
    
    public typealias Index = T.Index
    
    public var startIndex: T.Index { return value.startIndex }
    public var endIndex: T.Index { return value.startIndex }

    public subscript(position: T.Index) -> T.Element {
        return value[position]
    }
    public subscript(bounds: Range<T.Index>) -> T.SubSequence {
        return value[bounds]
    }
    
    public typealias Indices = T.Indices
    
    public var indices: T.Indices { return value.indices }

    @inline(__always)
    public func prefix(upTo end: T.Index) -> T.SubSequence {
        return value.prefix(upTo: end)
    }
    @inline(__always)
    public func suffix(from start: T.Index) -> T.SubSequence {
        return value.suffix(from: start)
    }
    @inline(__always)
    public func prefix(through position: T.Index) -> T.SubSequence {
        return value.prefix(through: position)
    }
    public var isEmpty: Bool { return value.isEmpty }
    
    public var count: Int { return value.count }
    
    public var first: T.Element? { return value.first }
    
    @inline(__always)
    public func index(_ i: T.Index, offsetBy distance: Int) -> T.Index {
        return value.index(i, offsetBy: distance)
    }
    @inline(__always)
    public func index(_ i: T.Index, offsetBy distance: Int, limitedBy limit: T.Index) -> T.Index? {
        return value.index(i, offsetBy: distance, limitedBy: limit)
    }
    @inline(__always)
    public func distance(from start: T.Index, to end: T.Index) -> Int {
        return value.distance(from: start, to: end)
    }
    @inline(__always)
    public func index(after i: T.Index) -> T.Index {
        return value.index(after: i)
    }
    @inline(__always)
    public func formIndex(after i: inout T.Index) {
        return value.formIndex(after: &i)
    }
    
    @available(*, deprecated, message: "all index distances are now of type Int")
    public typealias IndexDistance = Int
    
}

extension Store : MutableCollection where T : MutableCollection {
    
    public subscript(position: T.Index) -> T.Element {
        get { return value[position] }
        set { value[position] = newValue }
    }
    
    public subscript(bounds: Range<T.Index>) -> T.SubSequence {
        get { return value[bounds] }
        set { value[bounds] = newValue }
    }
    
    @inline(__always)
    public func partition(by belongsInSecondPartition: (T.Element) throws -> Bool) rethrows -> T.Index {
        return try value.partition(by: belongsInSecondPartition)
    }
    
    @inline(__always)
    public func swapAt(_ i: T.Index, _ j: T.Index) {
        return value.swapAt(i, j)
    }
}

extension Store : RangeReplaceableCollection where T : RangeReplaceableCollection {
    
    @inline(__always)
    public convenience init() {
        self.init(T())
    }
    
    @inline(__always)
    public func replaceSubrange<C>(_ subrange: Range<T.Index>, with newElements: C) where C : Collection, T.Element == C.Element {
        value.replaceSubrange(subrange, with: newElements)
    }
    @inline(__always)
    public func reserveCapacity(_ n: Int) {
        value.reserveCapacity(n)
    }
    @inline(__always)
    public convenience init(repeating repeatedValue: T.Element, count: Int) {
        self.init(T(repeating: repeatedValue, count: count))
    }
    @inline(__always)
    public convenience init<S>(_ elements: S) where S : Sequence, T.Element == S.Element {
        self.init(T(elements))
    }
    @inline(__always)
    public func append(_ newElement: T.Element) {
        value.append(newElement)
    }
    @inline(__always)
    public func append<S>(contentsOf newElements: S) where S : Sequence, T.Element == S.Element {
        value.append(contentsOf: newElements)
    }
    @inline(__always)
    public func insert(_ newElement: T.Element, at i: T.Index) {
        value.insert(newElement, at: i)
    }
    @inline(__always)
    public func insert<S>(contentsOf newElements: S, at i: T.Index) where S : Collection, T.Element == S.Element {
        value.insert(contentsOf: newElements, at: i)
    }
    
    @inline(__always)
    @discardableResult
    public func remove(at i: T.Index) -> T.Element {
        return value.remove(at: i)
    }
    
    @inline(__always)
    public func removeSubrange(_ bounds: Range<T.Index>) {
        value.removeSubrange(bounds)
    }
    
    @inline(__always)
    public func removeFirst() -> T.Element {
        return value.removeFirst()
    }
    
    @inline(__always)
    public func removeFirst(_ k: Int) {
        value.removeFirst(k)
    }
    @inline(__always)
    public func removeAll(keepingCapacity keepCapacity: Bool) {
        value.removeAll(keepingCapacity: keepCapacity)
    }
    @inline(__always)
    public func removeAll(where predicate: (T.Element) throws -> Bool) rethrows {
        try value.removeAll(where: predicate)
    }
}
