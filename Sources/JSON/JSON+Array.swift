//
//  JSON+Array.swift
//  TestJSON
//
//  Created by 李招利 on 2019/1/14.
//  Copyright © 2019 jwl. All rights reserved.
//

import Foundation

extension JSON {
    
    public final class Array: RawRepresentable, ExpressibleByArrayLiteral {
        
        public typealias ArrayLiteralElement = Any?

        public typealias RawValue = [JSON]
        
        private(set) public var rawValue: [JSON]
        
        public init() {
            rawValue = []
        }
        
        public init<S>(_ list:S) where S : Sequence, S.Element == JSON {
            if S.self == [JSON].self {
                rawValue =  list as! [JSON]
            } else if S.self == Array.self {
                rawValue = (list as! Array).rawValue
            } else {
                rawValue = Swift.Array(list)
            }
        }
        
        public init(rawValue list: [JSON]) {
            rawValue = list
        }
        
        /// Creates an instance initialized with the given elements.
        public init(arrayLiteral elements: ArrayLiteralElement...) {
            rawValue = elements.compactMap { JSON.from($0) }
        }
        
        /// Creates a new collection containing the specified number of a single,
        /// repeated value.
        ///
        /// Here's an example of creating an array initialized with five strings
        /// containing the letter *Z*.
        ///
        ///     let fiveZs = Array(repeating: "Z", count: 5)
        ///     print(fiveZs)
        ///     // Prints "["Z", "Z", "Z", "Z", "Z"]"
        ///
        /// - Parameters:
        ///   - repeatedValue: The element to repeat.
        ///   - count: The number of times to repeat the value passed in the
        ///     `repeating` parameter. `count` must be zero or greater.
        public init(repeating repeatedValue: JSON, count: Int) {
            rawValue = [JSON](repeating: repeatedValue, count: count)
        }

    }
    
}

extension JSON.Array: RangeReplaceableCollection {
    
    public typealias Index = Int
    public typealias Element = JSON
    public typealias SubSequence = ArraySlice<JSON>
    
    public subscript(bounds: Int) -> JSON {
        get { return rawValue[bounds] }
        set { rawValue[bounds] = newValue }
    }
    
    public var startIndex: Int { return rawValue.startIndex }
    
    public var endIndex: Int { return rawValue.endIndex }
    
    public func index(after i: Int) -> Int {
        return rawValue.index(after: i)
    }
    
    public func replaceSubrange<C>(_ subrange: Range<Int>, with newElements: C) where C : Collection, JSON == C.Element {
        rawValue.replaceSubrange(subrange, with: newElements)
    }
    
}

extension JSON.Array: BidirectionalCollection {
    
    /// Returns the position immediately before the given index.
    ///
    /// - Parameter i: A valid index of the collection. `i` must be greater than
    ///   `startIndex`.
    /// - Returns: The index value immediately before `i`.
    public func index(before i: Int) -> Int {
        return rawValue.index(before: i)
    }
    
}

extension JSON.Array: MutableCollection {
    
}

extension JSON.Array: CustomReflectable {
    
    /// The custom mirror for this instance.
    ///
    /// If this type has value semantics, the mirror should be unaffected by
    /// subsequent mutations of the instance.
    public var customMirror: Mirror { return rawValue.customMirror }
    
}

extension JSON.Array: CustomStringConvertible {
    private func serialize(pretty: Bool) -> String {
        var jsonStr = String()
        
        var writer = JSON.Writer(pretty: pretty, sortedKeys: false) {
            if let text = $0 { jsonStr.append(text) }
        }
        
        writer.serializeArray(self)
        
        return jsonStr
    }
    
    public var description: String {
        return serialize(pretty: false)
    }
    
}


extension JSON.Array: CustomDebugStringConvertible {
    
    public var debugDescription: String {
        return serialize(pretty: true)
    }
}

extension JSON.Array: Equatable {
    
    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (lhs: JSON.Array, rhs: JSON.Array) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
}

extension JSON.Array: Hashable {
    
    
    /// Hashes the essential components of this value by feeding them into the
    /// given hasher.
    ///
    /// Implement this method to conform to the `Hashable` protocol. The
    /// components used for hashing must be the same as the components compared
    /// in your type's `==` operator implementation. Call `hasher.combine(_:)`
    /// with each of these components.
    ///
    /// - Important: Never call `finalize()` on `hasher`. Doing so may become a
    ///   compile-time error in the future.
    ///
    /// - Parameter hasher: The hasher to use when combining the components
    ///   of this instance.
    public func hash(into hasher: inout Hasher) {
        for value in rawValue {
            hasher.combine(value)
        }
    }
}



extension JSON.Array {
    
    /// Calls a closure with a pointer to the array's contiguous storage.
    ///
    /// Often, the optimizer can eliminate bounds checks within an array
    /// algorithm, but when that fails, invoking the same algorithm on the
    /// buffer pointer passed into your closure lets you trade safety for speed.
    ///
    /// The following example shows how you can iterate over the contents of the
    /// buffer pointer:
    ///
    ///     let numbers = [1, 2, 3, 4, 5]
    ///     let sum = numbers.withUnsafeBufferPointer { buffer -> Int in
    ///         var result = 0
    ///         for i in stride(from: buffer.startIndex, to: buffer.endIndex, by: 2) {
    ///             result += buffer[i]
    ///         }
    ///         return result
    ///     }
    ///     // 'sum' == 9
    ///
    /// The pointer passed as an argument to `body` is valid only during the
    /// execution of `withUnsafeBufferPointer(_:)`. Do not store or return the
    /// pointer for later use.
    ///
    /// - Parameter body: A closure with an `UnsafeBufferPointer` parameter that
    ///   points to the contiguous storage for the array.  If no such storage exists, it is created. If
    ///   `body` has a return value, that value is also used as the return value
    ///   for the `withUnsafeBufferPointer(_:)` method. The pointer argument is
    ///   valid only for the duration of the method's execution.
    /// - Returns: The return value, if any, of the `body` closure parameter.
    public func withUnsafeBufferPointer<R>(_ body: (UnsafeBufferPointer<JSON>) throws -> R) rethrows -> R {
        return try rawValue.withUnsafeBufferPointer(body)
    }
    
    /// Calls the given closure with a pointer to the array's mutable contiguous
    /// storage.
    ///
    /// Often, the optimizer can eliminate bounds checks within an array
    /// algorithm, but when that fails, invoking the same algorithm on the
    /// buffer pointer passed into your closure lets you trade safety for speed.
    ///
    /// The following example shows how modifying the contents of the
    /// `UnsafeMutableBufferPointer` argument to `body` alters the contents of
    /// the array:
    ///
    ///     var numbers = [1, 2, 3, 4, 5]
    ///     numbers.withUnsafeMutableBufferPointer { buffer in
    ///         for i in stride(from: buffer.startIndex, to: buffer.endIndex - 1, by: 2) {
    ///             buffer.swapAt(i, i + 1)
    ///         }
    ///     }
    ///     print(numbers)
    ///     // Prints "[2, 1, 4, 3, 5]"
    ///
    /// The pointer passed as an argument to `body` is valid only during the
    /// execution of `withUnsafeMutableBufferPointer(_:)`. Do not store or
    /// return the pointer for later use.
    ///
    /// - Warning: Do not rely on anything about the array that is the target of
    ///   this method during execution of the `body` closure; it might not
    ///   appear to have its correct value. Instead, use only the
    ///   `UnsafeMutableBufferPointer` argument to `body`.
    ///
    /// - Parameter body: A closure with an `UnsafeMutableBufferPointer`
    ///   parameter that points to the contiguous storage for the array.
    ///    If no such storage exists, it is created. If `body` has a return value, that value is also
    ///   used as the return value for the `withUnsafeMutableBufferPointer(_:)`
    ///   method. The pointer argument is valid only for the duration of the
    ///   method's execution.
    /// - Returns: The return value, if any, of the `body` closure parameter.
    public func withUnsafeMutableBufferPointer<R>(_ body: (inout UnsafeMutableBufferPointer<JSON>) throws -> R) rethrows -> R {
        return try rawValue.withUnsafeMutableBufferPointer(body)
    }
    
    
    /// Calls the given closure with a pointer to the underlying bytes of the
    /// array's mutable contiguous storage.
    ///
    /// The array's `Element` type must be a *trivial type*, which can be copied
    /// with just a bit-for-bit copy without any indirection or
    /// reference-counting operations. Generally, native Swift types that do not
    /// contain strong or weak references are trivial, as are imported C structs
    /// and enums.
    ///
    /// The following example copies bytes from the `byteValues` array into
    /// `numbers`, an array of `Int`:
    ///
    ///     var numbers: [Int32] = [0, 0]
    ///     var byteValues: [UInt8] = [0x01, 0x00, 0x00, 0x00, 0x02, 0x00, 0x00, 0x00]
    ///
    ///     numbers.withUnsafeMutableBytes { destBytes in
    ///         byteValues.withUnsafeBytes { srcBytes in
    ///             destBytes.copyBytes(from: srcBytes)
    ///         }
    ///     }
    ///     // numbers == [1, 2]
    ///
    /// The pointer passed as an argument to `body` is valid only for the
    /// lifetime of the closure. Do not escape it from the closure for later
    /// use.
    ///
    /// - Warning: Do not rely on anything about the array that is the target of
    ///   this method during execution of the `body` closure; it might not
    ///   appear to have its correct value. Instead, use only the
    ///   `UnsafeMutableRawBufferPointer` argument to `body`.
    ///
    /// - Parameter body: A closure with an `UnsafeMutableRawBufferPointer`
    ///   parameter that points to the contiguous storage for the array.
    ///    If no such storage exists, it is created. If `body` has a return value, that value is also
    ///   used as the return value for the `withUnsafeMutableBytes(_:)` method.
    ///   The argument is valid only for the duration of the closure's
    ///   execution.
    /// - Returns: The return value, if any, of the `body` closure parameter.
    public func withUnsafeMutableBytes<R>(_ body: (UnsafeMutableRawBufferPointer) throws -> R) rethrows -> R {
        return try rawValue.withUnsafeMutableBytes(body)
    }
    
    /// Calls the given closure with a pointer to the underlying bytes of the
    /// array's contiguous storage.
    ///
    /// The array's `Element` type must be a *trivial type*, which can be copied
    /// with just a bit-for-bit copy without any indirection or
    /// reference-counting operations. Generally, native Swift types that do not
    /// contain strong or weak references are trivial, as are imported C structs
    /// and enums.
    ///
    /// The following example copies the bytes of the `numbers` array into a
    /// buffer of `UInt8`:
    ///
    ///     var numbers = [1, 2, 3]
    ///     var byteBuffer: [UInt8] = []
    ///     numbers.withUnsafeBytes {
    ///         byteBuffer.append(contentsOf: $0)
    ///     }
    ///     // byteBuffer == [1, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, ...]
    ///
    /// - Parameter body: A closure with an `UnsafeRawBufferPointer` parameter
    ///   that points to the contiguous storage for the array.
    ///    If no such storage exists, it is created. If `body` has a return value, that value is also
    ///   used as the return value for the `withUnsafeBytes(_:)` method. The
    ///   argument is valid only for the duration of the closure's execution.
    /// - Returns: The return value, if any, of the `body` closure parameter.
    public func withUnsafeBytes<R>(_ body: (UnsafeRawBufferPointer) throws -> R) rethrows -> R {
        return try rawValue.withUnsafeBytes(body)
    }
    
    /// Sorts the collection in place, using the given predicate as the
    /// comparison between elements.
    ///
    /// When you want to sort a collection of elements that doesn't conform to
    /// the `Comparable` protocol, pass a closure to this method that returns
    /// `true` when the first element passed should be ordered before the
    /// second.
    ///
    /// The predicate must be a *strict weak ordering* over the elements. That
    /// is, for any elements `a`, `b`, and `c`, the following conditions must
    /// hold:
    ///
    /// - `areInIncreasingOrder(a, a)` is always `false`. (Irreflexivity)
    /// - If `areInIncreasingOrder(a, b)` and `areInIncreasingOrder(b, c)` are
    ///   both `true`, then `areInIncreasingOrder(a, c)` is also `true`.
    ///   (Transitive comparability)
    /// - Two elements are *incomparable* if neither is ordered before the other
    ///   according to the predicate. If `a` and `b` are incomparable, and `b`
    ///   and `c` are incomparable, then `a` and `c` are also incomparable.
    ///   (Transitive incomparability)
    ///
    /// The sorting algorithm is not stable. A nonstable sort may change the
    /// relative order of elements for which `areInIncreasingOrder` does not
    /// establish an order.
    ///
    /// In the following example, the closure provides an ordering for an array
    /// of a custom enumeration that describes an HTTP response. The predicate
    /// orders errors before successes and sorts the error responses by their
    /// error code.
    ///
    ///     enum HTTPResponse {
    ///         case ok
    ///         case error(Int)
    ///     }
    ///
    ///     var responses: [HTTPResponse] = [.error(500), .ok, .ok, .error(404), .error(403)]
    ///     responses.sort {
    ///         switch ($0, $1) {
    ///         // Order errors by code
    ///         case let (.error(aCode), .error(bCode)):
    ///             return aCode < bCode
    ///
    ///         // All successes are equivalent, so none is before any other
    ///         case (.ok, .ok): return false
    ///
    ///         // Order errors before successes
    ///         case (.error, .ok): return true
    ///         case (.ok, .error): return false
    ///         }
    ///     }
    ///     print(responses)
    ///     // Prints "[.error(403), .error(404), .error(500), .ok, .ok]"
    ///
    /// Alternatively, use this method to sort a collection of elements that do
    /// conform to `Comparable` when you want the sort to be descending instead
    /// of ascending. Pass the greater-than operator (`>`) operator as the
    /// predicate.
    ///
    ///     var students = ["Kofi", "Abena", "Peter", "Kweku", "Akosua"]
    ///     students.sort(by: >)
    ///     print(students)
    ///     // Prints "["Peter", "Kweku", "Kofi", "Akosua", "Abena"]"
    ///
    /// - Parameter areInIncreasingOrder: A predicate that returns `true` if its
    ///   first argument should be ordered before its second argument;
    ///   otherwise, `false`. If `areInIncreasingOrder` throws an error during
    ///   the sort, the elements may be in a different order, but none will be
    ///   lost.
    public func sort(by areInIncreasingOrder: (JSON, JSON) throws -> Bool) rethrows {
        try rawValue.sort(by: areInIncreasingOrder)
    }


    /// Creates a new collection by concatenating the elements of a collection and
    /// a sequence.
    ///
    /// The two arguments must have the same `Element` type. For example, you can
    /// concatenate the elements of an integer array and a `Range<Int>` instance.
    ///
    ///     let numbers = [1, 2, 3, 4]
    ///     let moreNumbers = numbers + 5...10
    ///     print(moreNumbers)
    ///     // Prints "[1, 2, 3, 4, 5, 6, 7, 8, 9, 10]"
    ///
    /// The resulting collection has the type of the argument on the left-hand
    /// side. In the example above, `moreNumbers` has the same type as `numbers`,
    /// which is `[Int]`.
    ///
    /// - Parameters:
    ///   - lhs: A range-replaceable collection.
    ///   - rhs: A collection or finite sequence.
    public static func + <Other>(lhs: JSON.Array, rhs: Other) -> JSON.Array where Other : Sequence, Element == Other.Element {
        return JSON.Array(lhs.rawValue + rhs)
    }

    /// Creates a new collection by concatenating the elements of a sequence and a
    /// collection.
    ///
    /// The two arguments must have the same `Element` type. For example, you can
    /// concatenate the elements of a `Range<Int>` instance and an integer array.
    ///
    ///     let numbers = [7, 8, 9, 10]
    ///     let moreNumbers = 1...6 + numbers
    ///     print(moreNumbers)
    ///     // Prints "[1, 2, 3, 4, 5, 6, 7, 8, 9, 10]"
    ///
    /// The resulting collection has the type of argument on the right-hand side.
    /// In the example above, `moreNumbers` has the same type as `numbers`, which
    /// is `[Int]`.
    ///
    /// - Parameters:
    ///   - lhs: A collection or finite sequence.
    ///   - rhs: A range-replaceable collection.
    public static func + <Other>(lhs: Other, rhs: JSON.Array) -> JSON.Array where Other : Sequence, Element == Other.Element {
        return JSON.Array(lhs + rhs.rawValue)
    }

    /// Appends the elements of a sequence to a range-replaceable collection.
    ///
    /// Use this operator to append the elements of a sequence to the end of
    /// range-replaceable collection with same `Element` type. This example
    /// appends the elements of a `Range<Int>` instance to an array of integers.
    ///
    ///     var numbers = [1, 2, 3, 4, 5]
    ///     numbers += 10...15
    ///     print(numbers)
    ///     // Prints "[1, 2, 3, 4, 5, 10, 11, 12, 13, 14, 15]"
    ///
    /// - Parameters:
    ///   - lhs: The array to append to.
    ///   - rhs: A collection or finite sequence.
    ///
    /// - Complexity: O(*m*), where *m* is the length of the right-hand-side
    ///   argument.
    public static func += <Other>(lhs: inout JSON.Array, rhs: Other) where Other : Sequence, Element == Other.Element {
        lhs.rawValue += rhs
    }

    /// Creates a new collection by concatenating the elements of two collections.
    ///
    /// The two arguments must have the same `Element` type. For example, you can
    /// concatenate the elements of two integer arrays.
    ///
    ///     let lowerNumbers = [1, 2, 3, 4]
    ///     let higherNumbers: ContiguousArray = [5, 6, 7, 8, 9, 10]
    ///     let allNumbers = lowerNumbers + higherNumbers
    ///     print(allNumbers)
    ///     // Prints "[1, 2, 3, 4, 5, 6, 7, 8, 9, 10]"
    ///
    /// The resulting collection has the type of the argument on the left-hand
    /// side. In the example above, `moreNumbers` has the same type as `numbers`,
    /// which is `[Int]`.
    ///
    /// - Parameters:
    ///   - lhs: A range-replaceable collection.
    ///   - rhs: Another range-replaceable collection.
    public static func + <Other>(lhs: JSON.Array, rhs: Other) -> JSON.Array where Other : RangeReplaceableCollection, Element == Other.Element {
        return JSON.Array(lhs.rawValue + rhs)
    }

}

extension JSON.Array : Codable {
    
    public convenience init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        var list = [JSON]()
        if let count = container.count {
            list.reserveCapacity(count)
        }
        while container.isAtEnd {
            list.append(try container.decode(JSON.self))
        }
        self.init(list)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try rawValue.forEach{ try container.encode($0) }
    }
    
}
