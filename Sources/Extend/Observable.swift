//
//  Observable.swift
//  
//
//  Created by bujiandi on 2019/6/18.
//

import Operator

fileprivate struct Observer<Value> {
    
    weak var target:AnyObject?
    
    private let notify:(Value, Value) -> Void
    
    init(tellTarget: AnyObject, _ onChange:@escaping (Value, Value) -> Void) {
        target = tellTarget
        notify = onChange
    }
    
    func declare(from oldValue:Value, to newValue:Value) -> Bool {
        if target != nil {
            notify(oldValue, newValue)
            return true
        }
        return false
    }
}

#if swift(>=5.1)
@propertyDelegate
@dynamicMemberLookup
public struct Observable<Value> {
    
    public typealias ValueChange = (Value, Value) -> Void
    
    private let getValue: () -> Value
    private let setValue: (Value) -> Void
    private let clearObserver: () -> Void
    private let appendObserver: (AnyObject, @escaping ValueChange) -> Void
    private let publishValueChange:(Value, Value) -> Void
    
    /// The value referenced by the binding. Assignments to the value
    /// will be immediately visible on reading (assuming the binding
    /// represents a mutable location), but the view changes they cause
    /// may be processed asynchronously to the assignment.
    public var value: Value {
        get { return getValue() }
        nonmutating set {
            let oldValue = getValue()
            setValue(newValue)
            publishValue(from: oldValue, to: newValue)
        }
    }
    
    /// Initializes from initial value storage it and storage observers.
    public init(initialValue: Value) {
        var storeValue:Value = initialValue
        getValue = { storeValue }
        setValue = { storeValue = $0 }
        
        var observers:[Observer<Value>] = []
        appendObserver = { target, changeCallback in
            observers.append(Observer<Value>(tellTarget: target, changeCallback))
        }
        publishValueChange = { oldValue, newValue in
            observers = observers.filter { $0.declare(from: oldValue, to: newValue) }
        }
    }
    /// Initializes from functions to read and write the value.
    public init(
        getValue: @escaping () -> Value,
        setValue: @escaping (Value) -> Void,
        appendObserver: @escaping (AnyObject, @escaping ValueChange) -> Void,
        publishValueChange: @escaping (Value, Value) -> Void
        ) {
        self.getValue = getValue
        self.setValue = setValue
        
        self.appendObserver = appendObserver
        self.publishValueChange = publishValueChange
    }
}
#else
public struct Observable<Value> {
    
    public typealias ValueChange = (Value, Value) -> Void

    private let getValue: () -> Value
    private let setValue: (Value) -> Void
    private let clearObserver: () -> Void
    private let appendObserver: (AnyObject, @escaping ValueChange) -> Void
    private let publishValueChange: (Value, Value) -> Void
    
    /// The value referenced by the binding. Assignments to the value
    /// will be immediately visible on reading (assuming the binding
    /// represents a mutable location), but the view changes they cause
    /// may be processed asynchronously to the assignment.
    public var value: Value {
        get { return getValue() }
        nonmutating set {
            let oldValue = getValue()
            setValue(newValue)
            publishValue(from: oldValue, to: newValue)
        }
    }
    
    /// Initializes from initial value storage it and storage observers.
    public init(initialValue: Value) {
        var storeValue:Value = initialValue
        getValue = { storeValue }
        setValue = { storeValue = $0 }
        
        var observers:[Observer<Value>] = []
        appendObserver = { target, changeCallback in
            observers.append(Observer<Value>(tellTarget: target, changeCallback))
        }
        publishValueChange = { oldValue, newValue in
            observers = observers.filter { $0.declare(from: oldValue, to: newValue) }
        }
        clearObserver = { observers.removeAll() }
    }
    
    /// Initializes from functions to read and write the value.
    public init(
        getValue: @escaping () -> Value,
        setValue: @escaping (Value) -> Void,
        appendObserver: @escaping (AnyObject, @escaping ValueChange) -> Void,
        publishValueChange: @escaping (Value, Value) -> Void
        ) {
        self.getValue = getValue
        self.setValue = setValue
        
        self.appendObserver = appendObserver
        self.publishValueChange = publishValueChange
        self.clearObserver = { }
    }
}
#endif

extension Observable {
    
    public func clearObservers() {
        clearObserver()
    }
    
    /// Initializes from initial value storage it and storage observers.
    public init(_ value: Value) {
        self = Observable<Value>(initialValue: value)
    }
    
    private func publishValue(from oldValue: Value, to newValue: Value) {
        publishValueChange(oldValue, newValue)
//        observers = observers.filter { $0.declare(from: oldValue, to: newValue) }
//        for observer in observers {
//            observer.declare(from: oldValue, to: newValue)
//        }
    }
    
    public func notify<T:AnyObject>(_ target:T, didChange: @escaping (Observed<T,Value>) -> Void) {
        appendObserver(target) {
            [unowned target] (oldValue, newValue) in
            didChange(Observed<T, Value>(
                valueFrom: oldValue,
                to: newValue,
                notify: target)
            )
        }
//        observers = observers.filter { $0.target != nil }
//        observers.append(observer)
    }
    
    public func notify<T:AnyObject>(_ target:T, didChange action: Selector) {
        appendObserver(target) {
            [unowned target] (oldValue, newValue) in
            let obj = target as AnyObject
            _ = obj.perform(action, with: Observed<T, Value>(
                valueFrom: oldValue,
                to: newValue,
                notify: target)
            )//?.release()
        }
    }
    
    public func notifyChanged() {
        let newValue = getValue()
        publishValue(from: newValue, to: newValue)
    }
    
    /// Initializes from functions to read and write the value.
    //    p`
    
    /// Creates a observable with an immutable `value`.
    public static func constant(_ value: Value) -> Observable<Value> {
        return Observable<Value>(
            getValue: { value },
            setValue: { print("immutable value can't change", value , "to", $0) },
            appendObserver: { print("immutable value can't observe", $0, $1) },
            publishValueChange: { print("immutable value can't change", $0 , "to", $1) }
        )
    }
}

extension Observable {
    
    /// Creates an instance by projecting the base value to an optional value.
    public init<V>(_ base: Observable<V>) where Value == V? {
        setValue = {
            if let newValue = $0 {
                base.value = newValue
            }
        }
        getValue = { base.value }
        var observers:[Observer<Value>] = []
        appendObserver = { (target, callback) in
            base.appendObserver(target) { (oldValue, newValue) in
                callback(oldValue, newValue)
            }
            observers.append(Observer<Value>(tellTarget: target, callback))
        }
        publishValueChange = { (oldValue, newValue) in
            if let new = newValue {
                base.value = new
            } else {
                observers = observers
                    .filter { $0.declare(from: oldValue, to: newValue) }
            }
        }
        clearObserver = { observers.removeAll() }
    }
    
    /// Creates an instance by projecting the base optional value to its
    /// unwrapped value, or returns `nil` if the base value is `nil`.
    public init?(_ base: Observable<Value?>) {
        guard let value = base.value else {
            return nil
        }
        setValue = { base.value = $0 }
        getValue = { value }
        appendObserver = { (target, callback) in
            base.appendObserver(target) { (oldValue, newValue) in
                if let old = oldValue, let new = newValue {
                    callback(old, new)
                }
            }
        }
        publishValueChange = base.publishValueChange
        clearObserver = { base.clearObserver() }
    }
    
//    public init<V>(_ base: Observable<V>) where V : Hashable {
//        setValue = { base.value.hashValue }
//        getValue = { value.has }
//    }
}

extension Observable where Value : SetAlgebra, Value.Element : Hashable {
    
    /// Returns a `Observable<Bool>` representing whether `value` contains
    /// `element`.
    ///
    /// Setting the result to `true` will add `element` to `value`, and setting
    /// it to `false` will remove `element` from `value`.
    public func contains(_ element: Value.Element) -> Observable<Bool> {
        let observable = storage
        return Observable<Bool>(
            getValue: { return observable.value.contains(element) },
            setValue: { (newValue:Bool) in
                let oldValue = observable.value.contains(element)
                switch (oldValue, newValue) {
                case (true, false):
                    observable.value.remove(element)
                case (false, true):
                    observable.value.insert(element)
                default:
                    observable.notifyChanged()
                }
            },
            appendObserver: { (target, callback) in
                observable.notify(target) {
                    callback($0.old.contains(element), $0.new.contains(element))
                }
            },
            publishValueChange: { (oldValue, newValue) in
                switch (oldValue, newValue) {
                case (true, false):
                    observable.value.remove(element)
                case (false, true):
                    observable.value.insert(element)
                default:
                    observable.notifyChanged()
                }
            }
        )
    }
}

extension Observable: RawRepresentable where Value : RawRepresentable {
    
    public typealias RawValue = Observable<Value.RawValue>
    
    @inlinable public init?(rawValue: Observable<Value.RawValue>) {
        if let value = Value(rawValue: rawValue.value) {
            self.init(value)
        } else {
            return nil
        }
    }
    /// Returns the projection of the receiver's value to its `rawValue`.
    public var rawValue: Observable<Value.RawValue> {
        return Observable<Value.RawValue>.constant(storage.value.rawValue)
//        let observable = observer
//        return Observable<Value.RawValue>(
//            getValue: { observable.value.rawValue },
//            setValue: { observable.value.rawValue = $0 }
//        )
    }
}

extension Observable where Value : CaseIterable, Value : Equatable {
    
    /// Projects the value of `self` to its index within `Value.allCases`.
    public var caseIndex: Observable<Value.AllCases.Index> {
        let index = Value.allCases.firstIndex(of: storage.value)!
        return Observable<Value.AllCases.Index>.constant(index)
    }
}

//extension Observable : DynamicViewProperty {
//}

/// Observables are trivially BindingConvertible.
extension Observable : ObservableConvertible {
    
    /// A observable to the persistent storage of `self`.
    @inlinable public var storage: Observable<Value> {
        return self
    }
}

extension Observable : Sequence where Value : MutableCollection, Value.Index : Hashable {
    
    /// A type representing the sequence's elements.
    public typealias Element = Observable<Value.Element>
    
    /// A type that provides the sequence's iteration interface and
    /// encapsulates its iteration state.
    public typealias Iterator = IndexingIterator<Observable<Value>>
    
    /// A sequence that represents a contiguous subrange of the collection's
    /// elements.
    ///
    /// This associated type appears as a requirement in the `Sequence`
    /// protocol, but it is restated here with stricter constraints. In a
    /// collection, the subsequence should also conform to `Collection`.
    public typealias SubSequence = Slice<Observable<Value>>
}

extension Observable : Collection where Value : MutableCollection, Value.Index : Hashable {
    
    /// A type that represents a position in the collection.
    ///
    /// Valid indices consist of the position of every element and a
    /// "past the end" position that's not valid for use as a subscript
    /// argument.
    public typealias Index = Value.Index
    
    /// A type that represents the indices that are valid for subscripting the
    /// collection, in ascending order.
    public typealias Indices = Value.Indices
    
    /// The position of the first element in a nonempty collection.
    ///
    /// If the collection is empty, `startIndex` is equal to `endIndex`.
    public var startIndex: Value.Index { return value.startIndex }
    
    /// The collection's "past the end" position---that is, the position one
    /// greater than the last valid subscript argument.
    ///
    /// When you need a range that includes the last element of a collection, use
    /// the half-open range operator (`..<`) with `endIndex`. The `..<` operator
    /// creates a range that doesn't include the upper bound, so it's always
    /// safe to use with `endIndex`. For example:
    ///
    ///     let numbers = [10, 20, 30, 40, 50]
    ///     if let index = numbers.firstIndex(of: 30) {
    ///         print(numbers[index ..< numbers.endIndex])
    ///     }
    ///     // Prints "[30, 40, 50]"
    ///
    /// If the collection is empty, `endIndex` is equal to `startIndex`.
    public var endIndex: Value.Index { return value.endIndex }
    
    /// Returns the position immediately after the given index.
    ///
    /// The successor of an index must be well defined. For an index `i` into a
    /// collection `c`, calling `c.index(after: i)` returns the same index every
    /// time.
    ///
    /// - Parameter i: A valid index of the collection. `i` must be less than
    ///   `endIndex`.
    /// - Returns: The index value immediately after `i`.
    public func index(after i: Value.Index) -> Value.Index {
        return value.index(after: i)
    }
    
    /// Replaces the given index with its successor.
    ///
    /// - Parameter i: A valid index of the collection. `i` must be less than
    ///   `endIndex`.
    public func formIndex(after i: inout Value.Index) {
        value.formIndex(after: &i)
    }
    
    /// Accesses the element at the specified position.
    ///
    /// The following example accesses an element of an array through its
    /// subscript to print its value:
    ///
    ///     var streets = ["Adams", "Bryant", "Channing", "Douglas", "Evarts"]
    ///     print(streets[1])
    ///     // Prints "Bryant"
    ///
    /// You can subscript a collection with any valid index other than the
    /// collection's end index. The end index refers to the position one past
    /// the last element of a collection, so it doesn't correspond with an
    /// element.
    ///
    /// - Parameter position: The position of the element to access. `position`
    ///   must be a valid index of the collection that is not equal to the
    ///   `endIndex` property.
    ///
    /// - Complexity: O(1)
    public subscript(position: Value.Index) -> Observable<Value.Element> {
        return Observable<Value.Element>(
            getValue: { return self.value[position] },
            setValue: { self.value[position] = $0 },
            appendObserver: { (target, callback) in
                self.notify(target) {
                    callback( $0.old[position], $0.new[position] )
                }
            },
            publishValueChange: { (_, newValue) in
                self.value[position] = newValue
            }
        )
    }
    
    /// The indices that are valid for subscripting the collection, in ascending
    /// order.
    ///
    /// A collection's `indices` property can hold a strong reference to the
    /// collection itself, causing the collection to be nonuniquely referenced.
    /// If you mutate the collection while iterating over its indices, a strong
    /// reference can result in an unexpected copy of the collection. To avoid
    /// the unexpected copy, use the `index(after:)` method starting with
    /// `startIndex` to produce indices instead.
    ///
    ///     var c = MyFancyCollection([10, 20, 30, 40, 50])
    ///     var i = c.startIndex
    ///     while i != c.endIndex {
    ///         c[i] /= 5
    ///         i = c.index(after: i)
    ///     }
    ///     // c == MyFancyCollection([2, 4, 6, 8, 10])
    public var indices: Value.Indices {
        return value.indices
    }
}

extension Observable : BidirectionalCollection where Value : BidirectionalCollection, Value : MutableCollection, Value.Index : Hashable {
    
    /// Returns the position immediately before the given index.
    ///
    /// - Parameter i: A valid index of the collection. `i` must be greater than
    ///   `startIndex`.
    /// - Returns: The index value immediately before `i`.
    public func index(before i: Value.Index) -> Value.Index {
        return value.index(before: i)
    }
    
    /// Replaces the given index with its predecessor.
    ///
    /// - Parameter i: A valid index of the collection. `i` must be greater than
    ///   `startIndex`.
    public func formIndex(before i: inout Value.Index) {
        value.formIndex(before: &i)
    }
}

extension Observable : RandomAccessCollection where Value : MutableCollection, Value : RandomAccessCollection, Value.Index : Hashable {
    
    
}

#if swift(>=5.1)
/// Types that conform to ObservableConvertible can provide a Observable to
/// their persistent storage.
@dynamicMemberLookup public protocol ObservableConvertible {
    
    /// The type of the value represented by the binding.
    associatedtype Value
    
    /// A observable to the persistent storage of `self`.
    var storage: Observable<Value> { get }

    /// Creates a new `Observable` focused on `Subject` using a key path.
    subscript<Subject>(dynamicMember keyPath: WritableKeyPath<Value, Subject>) -> Observable<Subject> { get }

}

extension ObservableConvertible {
    /// Creates a new `Observable` focused on `Subject` using a key path.
    public subscript<Subject>(dynamicMember keyPath: WritableKeyPath<Value, Subject>) -> Observable<Subject> {
        let observable = storage
        return Observable<Subject>(
            getValue: { return observable.value[keyPath: keyPath] },
            setValue: { observable.value[keyPath: keyPath] = $0 },
            appendObserver: { (target, callback) in
                observable.notify(target) {
                    callback($0.old[keyPath: keyPath], $0.new[keyPath: keyPath])
                }
        },
            publishValueChange: { _, _ in observable.notifyChanged() }
        )
    }
}

#else

public protocol ObservableConvertible {
    
    /// The type of the value represented by the binding.
    associatedtype Value
    
    /// A observable to the persistent storage of `self`.
    var storage: Observable<Value> { get }
    
}

#endif

extension ObservableConvertible {
    
//    /// Create a new Observable that will apply `transaction` to any changes.
//    public func transaction(_ transaction: Transaction) -> Observable<Value> {
//        let observable = storage
//        return Observable<Value>(
//            getValue: { observable.value },
//            setValue: { observable.value = $0 }
//        )
//    }
//
//    /// Create a new Observable that will apply `animation` to any changes.
//    public func animation(_ animation: Animation? = .default) -> Observable<Value> {
//        let observable = storage
//        return Observable<Value>(
//            getValue: { observable.value },
//            setValue: { observable.value = $0 }
//        )
//    }
    
    /// Creates a new `Observable` focused on `Subject` using a key path.
    public subscript<Subject>(keyPath keyPath: WritableKeyPath<Value, Subject>) -> Observable<Subject> {
        let observable = storage
        return Observable<Subject>(
            getValue: { return observable.value[keyPath: keyPath] },
            setValue: { observable.value[keyPath: keyPath] = $0 },
            appendObserver: { (target, callback) in
                observable.notify(target) {
                    callback($0.old[keyPath: keyPath], $0.new[keyPath: keyPath])
                }
            },
            publishValueChange: { _,_ in observable.notifyChanged() }
        )
    }
    
    /// Creates a new `Observable` focused on the wrapped value of the `Optional`
    /// `Subject` or the specified default value.
    public subscript<Subject>(keyPath: WritableKeyPath<Self.Value, Subject?>, default defaultValue: Subject) -> Observable<Subject> {
        let observable = storage
        return Observable<Subject>(
            getValue: { return observable.value[keyPath: keyPath] ?? defaultValue },
            setValue: { observable.value[keyPath: keyPath] = $0 },
            appendObserver: { (target, callback) in
                observable.notify(target) {
                    callback($0.old[keyPath: keyPath] ?? defaultValue, $0.new[keyPath: keyPath] ?? defaultValue)
                }
            },
            publishValueChange: { (_, newValue) in
                observable.value[keyPath: keyPath] = newValue
                }
        )
    }
    
    /// Creates a new observable whose value is the pair of the values
    /// represented by the observables `self` and `rhs`. Uses the
    /// transaction from `self` for the new observable.
    public func zip<T>(with rhs: T) -> Observable<(Value, T.Value)> where T : ObservableConvertible {
        let observable = storage
        var observers = [Observer<(Value, T.Value)>]()
        return Observable<(Value, T.Value)>(
            getValue: { return (observable.value, rhs.storage.value) },
            setValue: { (observable.value, rhs.storage.value) = $0 },
            appendObserver: { target, callback in
                observers.append(Observer<(Value, T.Value)>(tellTarget: target, callback))
            },
            publishValueChange: { (oldValue, newValue) in
                (observable.value, rhs.storage.value) = newValue
                observers = observers
                    .filter { $0.declare(from: oldValue, to: newValue) }
            }
        )
    }
}



extension Observable {
    
    @inlinable public static func <- (lhs: Observable<Value>, rhs: Value) {
        lhs.value = rhs
    }
    
    @inlinable public static func <-? (lhs: Observable<Value>, rhs: Value?) {
        if let value = rhs {
            lhs.value = value
        }
    }
}

extension Observable : CustomStringConvertible where Value : CustomStringConvertible {
    @inlinable public var description: String { return value.description }
}


extension Observable : CustomDebugStringConvertible where Value : CustomDebugStringConvertible {
    @inlinable public var debugDescription: String { return value.debugDescription }
}

extension Observable : Costable where Value : Costable {
    
    @inlinable public var cost: Int { return value.cost }
    
}

extension Observable where Value == String {
    
    @inlinable public func append(_ other: String) {
        value.append(other)
    }
    
    @inlinable public static func += (lhs: inout Observable<String>, rhs: String) {
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


extension Observable where Value == Bool {
    
    @inlinable public func toggle() {
        value.toggle()
    }
    
}

extension Observable : Comparable where Value : Comparable {
    
    @inlinable public static func < (lhs: Observable<Value>, rhs: Observable<Value>) -> Bool {
        return lhs.value < rhs.value
    }
    
    @inlinable public static func <= (lhs: Observable<Value>, rhs: Observable<Value>) -> Bool {
        return lhs.value <= rhs.value
    }
    
    @inlinable public static func >= (lhs: Observable<Value>, rhs: Observable<Value>) -> Bool {
        return lhs.value >= rhs.value
    }
    
    @inlinable public static func > (lhs: Observable<Value>, rhs: Observable<Value>) -> Bool {
        return lhs.value > rhs.value
    }
    
}

extension Observable : Equatable where Value : Equatable {
    
    @inlinable public static func == (lhs: Observable<Value>, rhs: Observable<Value>) -> Bool {
        return lhs.value == rhs.value
    }
    
}

extension Observable : Hashable where Value : Hashable {
    
    public var hashValue: Int { return value.hashValue }
    
    public func hash(into hasher: inout Hasher) {
        value.hash(into: &hasher)
    }
    
}

extension Observable : Encodable where Value : Encodable {
    
    @inlinable public func encode(to encoder: Encoder) throws {
        try value.encode(to: encoder)
    }
    
}

extension Observable : Decodable where Value : Decodable {
    
    @inlinable public init(from decoder: Decoder) throws {
        self.init(try Value(from: decoder))
    }
    
}


extension Observable : ExpressibleByNilLiteral where Value : ExpressibleByNilLiteral {
    
    @inlinable public init(nilLiteral: ()) {
        self.init(Value(nilLiteral: ()))
    }
    
}

extension Observable : ExpressibleByFloatLiteral where Value : ExpressibleByFloatLiteral {
    
    public typealias FloatLiteralType = Value.FloatLiteralType
    
    @inlinable public init(floatLiteral value: Value.FloatLiteralType) {
        self.init(Value(floatLiteral: value))
    }
}

extension Observable : ExpressibleByIntegerLiteral where Value : ExpressibleByIntegerLiteral {
    
    public typealias IntegerLiteralType = Value.IntegerLiteralType
    
    @inlinable public init(integerLiteral value: Value.IntegerLiteralType) {
        self.init(Value(integerLiteral: value))
    }
}

extension Observable : ExpressibleByBooleanLiteral where Value : ExpressibleByBooleanLiteral {
    
    public typealias BooleanLiteralType = Value.BooleanLiteralType
    
    @inlinable public init(booleanLiteral value: Value.BooleanLiteralType) {
        self.init(Value(booleanLiteral: value))
    }
}

extension Observable : ExpressibleByUnicodeScalarLiteral where Value : ExpressibleByUnicodeScalarLiteral {
    
    public typealias UnicodeScalarLiteralType = Value.UnicodeScalarLiteralType
    
    @inlinable public init(unicodeScalarLiteral value: Value.UnicodeScalarLiteralType) {
        self.init(Value(unicodeScalarLiteral: value))
    }
    
}

extension Observable : ExpressibleByExtendedGraphemeClusterLiteral where Value : ExpressibleByExtendedGraphemeClusterLiteral {
    
    public typealias ExtendedGraphemeClusterLiteralType = Value.ExtendedGraphemeClusterLiteralType
    
    @inlinable public init(extendedGraphemeClusterLiteral value: Value.ExtendedGraphemeClusterLiteralType) {
        self.init(Value(extendedGraphemeClusterLiteral: value))
    }
    
}
extension Observable : ExpressibleByStringLiteral where Value : ExpressibleByStringLiteral {
    
    public typealias StringLiteralType = Value.StringLiteralType
    
    @inlinable public init(stringLiteral value: Value.StringLiteralType) {
        self.init(Value(stringLiteral: value))
    }
    
}

extension Observable : ExpressibleByArrayLiteral where Value : ExpressibleByArrayLiteral, Value : RangeReplaceableCollection, Value.ArrayLiteralElement == Value.Element {
    
    public typealias ArrayLiteralElement = Value.ArrayLiteralElement
    
    /// Creates an instance initialized with the given elements.
    @inlinable public init(arrayLiteral elements: Value.ArrayLiteralElement...) {
        self.init(Value(elements))
    }
    
}


extension Observable : RangeExpression where Value : RangeExpression {
    
    public typealias Bound = Value.Bound
    
    @inlinable public func relative<C>(to collection: C) -> Range<Value.Bound> where C : Collection, Value.Bound == C.Index {
        return value.relative(to: collection)
    }
    
    @inlinable public func contains(_ element: Value.Bound) -> Bool {
        return value.contains(element)
    }
    
}
