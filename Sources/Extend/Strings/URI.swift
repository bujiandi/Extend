//
//  URI.swift
//  Extend
//
//  Created by 李招利 on 2019/4/19.
//

#if swift(>=5.0)
private let separatorCharacter:Character = #"\"#
#else
private let separatorCharacter:Character = "\\"
#endif

@inline(__always)
private func componentsFrom(path:String) -> [Substring] {
    var components:[Substring]
    if let index = path.firstIndex(of: "?") {
        components = path[..<index].split(separator: separatorCharacter)
    } else {
        components = path.split(separator: separatorCharacter)
    }
    if  components.first?.isEmpty ?? false {
        components.removeFirst()
    }
    return components
}

public struct URI {
    
    public var components:[String]
    
    public init() {
        components = []
    }
    
    public init(_ absoluteURI:String) {
        components = componentsFrom(path: absoluteURI).compactMap{ $0.isEmpty ? nil : String($0) }
    }
    
    public init(rootPath:URI, fileName:String) {
        components = rootPath.components + fileName
            .split(separator: separatorCharacter)
            .compactMap{ $0.isEmpty ? nil : String($0) }
    }
    public init(root:String, fileName:String) {
        components =
            componentsFrom(path: root).compactMap{ $0.isEmpty ? nil : String($0) } + fileName
                .split(separator: separatorCharacter)
                .compactMap{ $0.isEmpty ? nil : String($0) }
    }
    
    public var absolute:String {
        get {
            return String(separatorCharacter) + components.joined(separator: String(separatorCharacter))
        }
        set {
            components = componentsFrom(path: newValue).compactMap{ $0.isEmpty ? nil : String($0) }
        }
    }
    
    @inlinable public var isRoot:Bool {
        return components.isEmpty
    }
    
    /// 文件名
    @inlinable public var fileName:String {
        return components.last ?? ""
    }
    
    /// 文件扩展名
    @inlinable public var fileExtension:String {
        return fileName.components(separatedBy:".").last ?? ""
    }
    
    /// 父目录
    @inlinable public var parent:URI? {
        if components.isEmpty {
            return nil
        }
        var newComponents = components
        newComponents.removeLast()
        return URI(newComponents)
    }
    
}

extension URI: RawRepresentable {
    
    public typealias RawValue = String
    
    @inlinable public var rawValue: String {
        return absolute
    }
    
    public init(rawValue path: String) {
        components = componentsFrom(path: path).compactMap{ $0.isEmpty ? nil : String($0) }
    }
    
}

extension URI: ExpressibleByUnicodeScalarLiteral {
    
    public typealias UnicodeScalarLiteralType = String
    
    public init(unicodeScalarLiteral path: String) {
        components = componentsFrom(path: path).compactMap{ $0.isEmpty ? nil : String($0) }
    }
    
}

extension URI: ExpressibleByExtendedGraphemeClusterLiteral {
    
    public typealias ExtendedGraphemeClusterLiteralType = String
    
    public init(extendedGraphemeClusterLiteral path: String) {
        components = componentsFrom(path: path).compactMap{ $0.isEmpty ? nil : String($0) }
    }
    
}

extension URI: ExpressibleByStringLiteral {
    
    public typealias StringLiteralType = String
    /// Creates an instance initialized to the given string value.
    ///
    /// Do not call this initializer directly. It is used by the compiler when you
    /// initialize a string using a string literal. For example:
    ///
    ///     let nextStop = "Clark & Lake"
    ///
    /// This assignment to the `nextStop` constant calls this string literal
    /// initializer behind the scenes.
    public init(stringLiteral path: String) {
        components = componentsFrom(path: path).compactMap{ $0.isEmpty ? nil : String($0) }
        
    }
}

extension URI {
    
    /// The total number of elements that the array can contain without
    /// allocating new storage.
    ///
    /// Every array reserves a specific amount of memory to hold its contents.
    /// When you add elements to an array and that array begins to exceed its
    /// reserved capacity, the array allocates a larger region of memory and
    /// copies its elements into the new storage. The new storage is a multiple
    /// of the old storage's size. This exponential growth strategy means that
    /// appending an element happens in constant time, averaging the performance
    /// of many append operations. Append operations that trigger reallocation
    /// have a performance cost, but they occur less and less often as the array
    /// grows larger.
    ///
    /// The following example creates an array of integers from an array literal,
    /// then appends the elements of another collection. Before appending, the
    /// array allocates new storage that is large enough store the resulting
    /// elements.
    ///
    ///     var numbers = [10, 20, 30, 40, 50]
    ///     // numbers.count == 5
    ///     // numbers.capacity == 5
    ///
    ///     numbers.append(contentsOf: stride(from: 60, through: 100, by: 10))
    ///     // numbers.count == 10
    ///     // numbers.capacity == 12
    @inlinable public var capacity: Int { return components.capacity }
    
    @inlinable public static func + (lhs: URI, rhs: URI) -> URI {
        return URI(lhs.components + rhs.components)
    }
    
    @inlinable public static func += (lhs: inout URI, rhs: URI) {
        lhs.components.append(contentsOf: rhs.components)
    }
    
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
    @inlinable public func withUnsafeBufferPointer<R>(_ body: (UnsafeBufferPointer<String>) throws -> R) rethrows -> R {
        return try components.withUnsafeBufferPointer(body)
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
    @inlinable public mutating func withUnsafeMutableBufferPointer<R>(_ body: (inout UnsafeMutableBufferPointer<String>) throws -> R) rethrows -> R {
        return try components.withUnsafeMutableBufferPointer(body)
    }
    
    /// Replaces a range of elements with the elements in the specified
    /// collection.
    ///
    /// This method has the effect of removing the specified range of elements
    /// from the array and inserting the new elements at the same location. The
    /// number of new elements need not match the number of elements being
    /// removed.
    ///
    /// In this example, three elements in the middle of an array of integers are
    /// replaced by the five elements of a `Repeated<Int>` instance.
    ///
    ///      var nums = [10, 20, 30, 40, 50]
    ///      nums.replaceSubrange(1...3, with: repeatElement(1, count: 5))
    ///      print(nums)
    ///      // Prints "[10, 1, 1, 1, 1, 1, 50]"
    ///
    /// If you pass a zero-length range as the `subrange` parameter, this method
    /// inserts the elements of `newElements` at `subrange.startIndex`. Calling
    /// the `insert(contentsOf:at:)` method instead is preferred.
    ///
    /// Likewise, if you pass a zero-length collection as the `newElements`
    /// parameter, this method removes the elements in the given subrange
    /// without replacement. Calling the `removeSubrange(_:)` method instead is
    /// preferred.
    ///
    /// - Parameters:
    ///   - subrange: The subrange of the array to replace. The start and end of
    ///     a subrange must be valid indices of the array.
    ///   - newElements: The new elements to add to the array.
    ///
    /// - Complexity: O(*n* + *m*), where *n* is length of the array and
    ///   *m* is the length of `newElements`. If the call to this method simply
    ///   appends the contents of `newElements` to the array, this method is
    ///   equivalent to `append(contentsOf:)`.
    @inlinable public mutating func replaceSubrange<C>(_ subrange: Range<Int>, with newElements: __owned C) where String == C.Element, C : Collection {
        components.replaceSubrange(subrange, with: newElements)
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
    @inlinable public mutating func withUnsafeMutableBytes<R>(_ body: (UnsafeMutableRawBufferPointer) throws -> R) rethrows -> R {
        return try components.withUnsafeMutableBytes(body)
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
    @inlinable public func withUnsafeBytes<R>(_ body: (UnsafeRawBufferPointer) throws -> R) rethrows -> R {
        return try components.withUnsafeBytes(body)
    }
    
    /// Returns a subsequence containing all but the specified number of final
    /// elements.
    ///
    /// If the number of elements to drop exceeds the number of elements in the
    /// collection, the result is an empty subsequence.
    ///
    ///     let numbers = [1, 2, 3, 4, 5]
    ///     print(numbers.dropLast(2))
    ///     // Prints "[1, 2, 3]"
    ///     print(numbers.dropLast(10))
    ///     // Prints "[]"
    ///
    /// - Parameter k: The number of elements to drop off the end of the
    ///   collection. `k` must be greater than or equal to zero.
    /// - Returns: A subsequence that leaves off `k` elements from the end.
    ///
    /// - Complexity: O(1) if the collection conforms to
    ///   `RandomAccessCollection`; otherwise, O(*k*), where *k* is the number of
    ///   elements to drop.
    @inlinable public __consuming func dropLast(_ k: Int) -> ArraySlice<String> {
        return components.dropLast(k)
    }
    
    /// Returns a subsequence, up to the given maximum length, containing the
    /// final elements of the collection.
    ///
    /// If the maximum length exceeds the number of elements in the collection,
    /// the result contains the entire collection.
    ///
    ///     let numbers = [1, 2, 3, 4, 5]
    ///     print(numbers.suffix(2))
    ///     // Prints "[4, 5]"
    ///     print(numbers.suffix(10))
    ///     // Prints "[1, 2, 3, 4, 5]"
    ///
    /// - Parameter maxLength: The maximum number of elements to return.
    ///   `maxLength` must be greater than or equal to zero.
    /// - Returns: A subsequence terminating at the end of the collection with at
    ///   most `maxLength` elements.
    ///
    /// - Complexity: O(1) if the collection conforms to
    ///   `RandomAccessCollection`; otherwise, O(*k*), where *k* is equal to
    ///   `maxLength`.
    @inlinable public __consuming func suffix(_ maxLength: Int) -> ArraySlice<String> {
        return components.suffix(maxLength)
    }
    
    /// Returns an array containing the results of mapping the given closure
    /// over the sequence's elements.
    ///
    /// In this example, `map` is used first to convert the names in the array
    /// to lowercase strings and then to count their characters.
    ///
    ///     let cast = ["Vivien", "Marlon", "Kim", "Karl"]
    ///     let lowercaseNames = cast.map { $0.lowercased() }
    ///     // 'lowercaseNames' == ["vivien", "marlon", "kim", "karl"]
    ///     let letterCounts = cast.map { $0.count }
    ///     // 'letterCounts' == [6, 6, 3, 4]
    ///
    /// - Parameter transform: A mapping closure. `transform` accepts an
    ///   element of this sequence as its parameter and returns a transformed
    ///   value of the same or of a different type.
    /// - Returns: An array containing the transformed elements of this
    ///   sequence.
    @inlinable public func map<T>(_ transform: (String) throws -> T) rethrows -> [T] {
        return try components.map(transform)
    }
    
    /// Returns a subsequence containing all but the given number of initial
    /// elements.
    ///
    /// If the number of elements to drop exceeds the number of elements in
    /// the collection, the result is an empty subsequence.
    ///
    ///     let numbers = [1, 2, 3, 4, 5]
    ///     print(numbers.dropFirst(2))
    ///     // Prints "[3, 4, 5]"
    ///     print(numbers.dropFirst(10))
    ///     // Prints "[]"
    ///
    /// - Parameter k: The number of elements to drop from the beginning of
    ///   the collection. `k` must be greater than or equal to zero.
    /// - Returns: A subsequence starting after the specified number of
    ///   elements.
    ///
    /// - Complexity: O(1) if the collection conforms to
    ///   `RandomAccessCollection`; otherwise, O(*k*), where *k* is the number of
    ///   elements to drop from the beginning of the collection.
    @inlinable public __consuming func dropFirst(_ k: Int = 1) -> ArraySlice<String> {
        return components.dropFirst(k)
    }
    
    /// Returns a subsequence by skipping elements while `predicate` returns
    /// `true` and returning the remaining elements.
    ///
    /// - Parameter predicate: A closure that takes an element of the
    ///   sequence as its argument and returns `true` if the element should
    ///   be skipped or `false` if it should be included. Once the predicate
    ///   returns `false` it will not be called again.
    ///
    /// - Complexity: O(*n*), where *n* is the length of the collection.
    @inlinable public __consuming func drop(while predicate: (String) throws -> Bool) rethrows -> ArraySlice<String> {
        return try components.drop(while: predicate)
    }
    
    /// Returns a subsequence, up to the specified maximum length, containing
    /// the initial elements of the collection.
    ///
    /// If the maximum length exceeds the number of elements in the collection,
    /// the result contains all the elements in the collection.
    ///
    ///     let numbers = [1, 2, 3, 4, 5]
    ///     print(numbers.prefix(2))
    ///     // Prints "[1, 2]"
    ///     print(numbers.prefix(10))
    ///     // Prints "[1, 2, 3, 4, 5]"
    ///
    /// - Parameter maxLength: The maximum number of elements to return.
    ///   `maxLength` must be greater than or equal to zero.
    /// - Returns: A subsequence starting at the beginning of this collection
    ///   with at most `maxLength` elements.
    ///
    /// - Complexity: O(1) if the collection conforms to
    ///   `RandomAccessCollection`; otherwise, O(*k*), where *k* is the number of
    ///   elements to select from the beginning of the collection.
    @inlinable public __consuming func prefix(_ maxLength: Int) -> ArraySlice<String> {
        return components.prefix(maxLength)
    }
    
    /// Returns a subsequence containing the initial elements until `predicate`
    /// returns `false` and skipping the remaining elements.
    ///
    /// - Parameter predicate: A closure that takes an element of the
    ///   sequence as its argument and returns `true` if the element should
    ///   be included or `false` if it should be excluded. Once the predicate
    ///   returns `false` it will not be called again.
    ///
    /// - Complexity: O(*n*), where *n* is the length of the collection.
    @inlinable public __consuming func prefix(while predicate: (String) throws -> Bool) rethrows -> ArraySlice<String> {
        return try components.prefix(while: predicate)
    }
    
    /// Returns a subsequence from the start of the collection up to, but not
    /// including, the specified position.
    ///
    /// The resulting subsequence *does not include* the element at the position
    /// `end`. The following example searches for the index of the number `40`
    /// in an array of integers, and then prints the prefix of the array up to,
    /// but not including, that index:
    ///
    ///     let numbers = [10, 20, 30, 40, 50, 60]
    ///     if let i = numbers.firstIndex(of: 40) {
    ///         print(numbers.prefix(upTo: i))
    ///     }
    ///     // Prints "[10, 20, 30]"
    ///
    /// Passing the collection's starting index as the `end` parameter results in
    /// an empty subsequence.
    ///
    ///     print(numbers.prefix(upTo: numbers.startIndex))
    ///     // Prints "[]"
    ///
    /// Using the `prefix(upTo:)` method is equivalent to using a partial
    /// half-open range as the collection's subscript. The subscript notation is
    /// preferred over `prefix(upTo:)`.
    ///
    ///     if let i = numbers.firstIndex(of: 40) {
    ///         print(numbers[..<i])
    ///     }
    ///     // Prints "[10, 20, 30]"
    ///
    /// - Parameter end: The "past the end" index of the resulting subsequence.
    ///   `end` must be a valid index of the collection.
    /// - Returns: A subsequence up to, but not including, the `end` position.
    ///
    /// - Complexity: O(1)
    @inlinable public __consuming func prefix(upTo end: Int) -> ArraySlice<String> {
        return components.prefix(upTo: end)
    }
    
    /// Returns a subsequence from the specified position to the end of the
    /// collection.
    ///
    /// The following example searches for the index of the number `40` in an
    /// array of integers, and then prints the suffix of the array starting at
    /// that index:
    ///
    ///     let numbers = [10, 20, 30, 40, 50, 60]
    ///     if let i = numbers.firstIndex(of: 40) {
    ///         print(numbers.suffix(from: i))
    ///     }
    ///     // Prints "[40, 50, 60]"
    ///
    /// Passing the collection's `endIndex` as the `start` parameter results in
    /// an empty subsequence.
    ///
    ///     print(numbers.suffix(from: numbers.endIndex))
    ///     // Prints "[]"
    ///
    /// Using the `suffix(from:)` method is equivalent to using a partial range
    /// from the index as the collection's subscript. The subscript notation is
    /// preferred over `suffix(from:)`.
    ///
    ///     if let i = numbers.firstIndex(of: 40) {
    ///         print(numbers[i...])
    ///     }
    ///     // Prints "[40, 50, 60]"
    ///
    /// - Parameter start: The index at which to start the resulting subsequence.
    ///   `start` must be a valid index of the collection.
    /// - Returns: A subsequence starting at the `start` position.
    ///
    /// - Complexity: O(1)
    @inlinable public __consuming func suffix(from start: Int) -> ArraySlice<String> {
        return components.suffix(from: start)
    }
    
    /// Returns a subsequence from the start of the collection through the
    /// specified position.
    ///
    /// The resulting subsequence *includes* the element at the position `end`.
    /// The following example searches for the index of the number `40` in an
    /// array of integers, and then prints the prefix of the array up to, and
    /// including, that index:
    ///
    ///     let numbers = [10, 20, 30, 40, 50, 60]
    ///     if let i = numbers.firstIndex(of: 40) {
    ///         print(numbers.prefix(through: i))
    ///     }
    ///     // Prints "[10, 20, 30, 40]"
    ///
    /// Using the `prefix(through:)` method is equivalent to using a partial
    /// closed range as the collection's subscript. The subscript notation is
    /// preferred over `prefix(through:)`.
    ///
    ///     if let i = numbers.firstIndex(of: 40) {
    ///         print(numbers[...i])
    ///     }
    ///     // Prints "[10, 20, 30, 40]"
    ///
    /// - Parameter end: The index of the last element to include in the
    ///   resulting subsequence. `end` must be a valid index of the collection
    ///   that is not equal to the `endIndex` property.
    /// - Returns: A subsequence up to, and including, the `end` position.
    ///
    /// - Complexity: O(1)
    @inlinable public __consuming func prefix(through position: Int) -> ArraySlice<String> {
        return components.prefix(through: position)
    }
    
    /// Returns the longest possible subsequences of the collection, in order,
    /// that don't contain elements satisfying the given predicate.
    ///
    /// The resulting array consists of at most `maxSplits + 1` subsequences.
    /// Elements that are used to split the sequence are not returned as part of
    /// any subsequence.
    ///
    /// The following examples show the effects of the `maxSplits` and
    /// `omittingEmptySubsequences` parameters when splitting a string using a
    /// closure that matches spaces. The first use of `split` returns each word
    /// that was originally separated by one or more spaces.
    ///
    ///     let line = "BLANCHE:   I don't want realism. I want magic!"
    ///     print(line.split(whereSeparator: { $0 == " " }))
    ///     // Prints "["BLANCHE:", "I", "don\'t", "want", "realism.", "I", "want", "magic!"]"
    ///
    /// The second example passes `1` for the `maxSplits` parameter, so the
    /// original string is split just once, into two new strings.
    ///
    ///     print(line.split(maxSplits: 1, whereSeparator: { $0 == " " }))
    ///     // Prints "["BLANCHE:", "  I don\'t want realism. I want magic!"]"
    ///
    /// The final example passes `false` for the `omittingEmptySubsequences`
    /// parameter, so the returned array contains empty strings where spaces
    /// were repeated.
    ///
    ///     print(line.split(omittingEmptySubsequences: false, whereSeparator: { $0 == " " }))
    ///     // Prints "["BLANCHE:", "", "", "I", "don\'t", "want", "realism.", "I", "want", "magic!"]"
    ///
    /// - Parameters:
    ///   - maxSplits: The maximum number of times to split the collection, or
    ///     one less than the number of subsequences to return. If
    ///     `maxSplits + 1` subsequences are returned, the last one is a suffix
    ///     of the original collection containing the remaining elements.
    ///     `maxSplits` must be greater than or equal to zero. The default value
    ///     is `Int.max`.
    ///   - omittingEmptySubsequences: If `false`, an empty subsequence is
    ///     returned in the result for each pair of consecutive elements
    ///     satisfying the `isSeparator` predicate and for each element at the
    ///     start or end of the collection satisfying the `isSeparator`
    ///     predicate. The default value is `true`.
    ///   - isSeparator: A closure that takes an element as an argument and
    ///     returns a Boolean value indicating whether the collection should be
    ///     split at that element.
    /// - Returns: An array of subsequences, split from this collection's
    ///   elements.
    ///
    /// - Complexity: O(*n*), where *n* is the length of the collection.
    @inlinable public __consuming func split(maxSplits: Int = Int.max, omittingEmptySubsequences: Bool = true, whereSeparator isSeparator: (String) throws -> Bool) rethrows -> [ArraySlice<String>] {
        return try components.split(maxSplits: maxSplits, omittingEmptySubsequences: omittingEmptySubsequences, whereSeparator: isSeparator)
    }
    
    /// The last element of the collection.
    ///
    /// If the collection is empty, the value of this property is `nil`.
    ///
    ///     let numbers = [10, 20, 30, 40, 50]
    ///     if let lastNumber = numbers.last {
    ///         print(lastNumber)
    ///     }
    ///     // Prints "50"
    ///
    /// - Complexity: O(1)
    @inlinable public var last: String? {
        return components.last
    }
    
    /// Returns the first index in which an element of the collection satisfies
    /// the given predicate.
    ///
    /// You can use the predicate to find an element of a type that doesn't
    /// conform to the `Equatable` protocol or to find an element that matches
    /// particular criteria. Here's an example that finds a student name that
    /// begins with the letter "A":
    ///
    ///     let students = ["Kofi", "Abena", "Peter", "Kweku", "Akosua"]
    ///     if let i = students.firstIndex(where: { $0.hasPrefix("A") }) {
    ///         print("\(students[i]) starts with 'A'!")
    ///     }
    ///     // Prints "Abena starts with 'A'!"
    ///
    /// - Parameter predicate: A closure that takes an element as its argument
    ///   and returns a Boolean value that indicates whether the passed element
    ///   represents a match.
    /// - Returns: The index of the first element for which `predicate` returns
    ///   `true`. If no elements in the collection satisfy the given predicate,
    ///   returns `nil`.
    ///
    /// - Complexity: O(*n*), where *n* is the length of the collection.
    @inlinable public func firstIndex(where predicate: (String) throws -> Bool) rethrows -> Int? {
        return try components.firstIndex(where: predicate)
    }
    
    /// Returns the last element of the sequence that satisfies the given
    /// predicate.
    ///
    /// This example uses the `last(where:)` method to find the last
    /// negative number in an array of integers:
    ///
    ///     let numbers = [3, 7, 4, -2, 9, -6, 10, 1]
    ///     if let lastNegative = numbers.last(where: { $0 < 0 }) {
    ///         print("The last negative number is \(lastNegative).")
    ///     }
    ///     // Prints "The last negative number is -6."
    ///
    /// - Parameter predicate: A closure that takes an element of the sequence as
    ///   its argument and returns a Boolean value indicating whether the
    ///   element is a match.
    /// - Returns: The last element of the sequence that satisfies `predicate`,
    ///   or `nil` if there is no element that satisfies `predicate`.
    ///
    /// - Complexity: O(*n*), where *n* is the length of the collection.
    @inlinable public func last(where predicate: (String) throws -> Bool) rethrows -> String? {
        return try components.last(where: predicate)
    }
    
    /// Returns the index of the last element in the collection that matches the
    /// given predicate.
    ///
    /// You can use the predicate to find an element of a type that doesn't
    /// conform to the `Equatable` protocol or to find an element that matches
    /// particular criteria. This example finds the index of the last name that
    /// begins with the letter *A:*
    ///
    ///     let students = ["Kofi", "Abena", "Peter", "Kweku", "Akosua"]
    ///     if let i = students.lastIndex(where: { $0.hasPrefix("A") }) {
    ///         print("\(students[i]) starts with 'A'!")
    ///     }
    ///     // Prints "Akosua starts with 'A'!"
    ///
    /// - Parameter predicate: A closure that takes an element as its argument
    ///   and returns a Boolean value that indicates whether the passed element
    ///   represents a match.
    /// - Returns: The index of the last element in the collection that matches
    ///   `predicate`, or `nil` if no elements match.
    ///
    /// - Complexity: O(*n*), where *n* is the length of the collection.
    @inlinable public func lastIndex(where predicate: (String) throws -> Bool) rethrows -> Int? {
        return try components.lastIndex(where: predicate)
    }
    
    /// Reorders the elements of the collection such that all the elements
    /// that match the given predicate are after all the elements that don't
    /// match.
    ///
    /// After partitioning a collection, there is a pivot index `p` where
    /// no element before `p` satisfies the `belongsInSecondPartition`
    /// predicate and every element at or after `p` satisfies
    /// `belongsInSecondPartition`.
    ///
    /// In the following example, an array of numbers is partitioned by a
    /// predicate that matches elements greater than 30.
    ///
    ///     var numbers = [30, 40, 20, 30, 30, 60, 10]
    ///     let p = numbers.partition(by: { $0 > 30 })
    ///     // p == 5
    ///     // numbers == [30, 10, 20, 30, 30, 60, 40]
    ///
    /// The `numbers` array is now arranged in two partitions. The first
    /// partition, `numbers[..<p]`, is made up of the elements that
    /// are not greater than 30. The second partition, `numbers[p...]`,
    /// is made up of the elements that *are* greater than 30.
    ///
    ///     let first = numbers[..<p]
    ///     // first == [30, 10, 20, 30, 30]
    ///     let second = numbers[p...]
    ///     // second == [60, 40]
    ///
    /// - Parameter belongsInSecondPartition: A predicate used to partition
    ///   the collection. All elements satisfying this predicate are ordered
    ///   after all elements not satisfying it.
    /// - Returns: The index of the first element in the reordered collection
    ///   that matches `belongsInSecondPartition`. If no elements in the
    ///   collection match `belongsInSecondPartition`, the returned index is
    ///   equal to the collection's `endIndex`.
    ///
    /// - Complexity: O(*n*), where *n* is the length of the collection.
    @inlinable public mutating func partition(by belongsInSecondPartition: (String) throws -> Bool) rethrows -> Int {
        return try components.partition(by: belongsInSecondPartition)
    }
    
    /// Returns the elements of the sequence, shuffled using the given generator
    /// as a source for randomness.
    ///
    /// You use this method to randomize the elements of a sequence when you are
    /// using a custom random number generator. For example, you can shuffle the
    /// numbers between `0` and `9` by calling the `shuffled(using:)` method on
    /// that range:
    ///
    ///     let numbers = 0...9
    ///     let shuffledNumbers = numbers.shuffled(using: &myGenerator)
    ///     // shuffledNumbers == [8, 9, 4, 3, 2, 6, 7, 0, 5, 1]
    ///
    /// - Parameter generator: The random number generator to use when shuffling
    ///   the sequence.
    /// - Returns: An array of this sequence's elements in a shuffled order.
    ///
    /// - Complexity: O(*n*), where *n* is the length of the sequence.
    /// - Note: The algorithm used to shuffle a sequence may change in a future
    ///   version of Swift. If you're passing a generator that results in the
    ///   same shuffled order each time you run your program, that sequence may
    ///   change when your program is compiled using a different version of
    ///   Swift.
    @inlinable public func shuffled<T>(using generator: inout T) -> URI where T : RandomNumberGenerator {
        return URI(components.shuffled(using: &generator))
    }
    
    /// Returns the elements of the sequence, shuffled.
    ///
    /// For example, you can shuffle the numbers between `0` and `9` by calling
    /// the `shuffled()` method on that range:
    ///
    ///     let numbers = 0...9
    ///     let shuffledNumbers = numbers.shuffled()
    ///     // shuffledNumbers == [1, 7, 6, 2, 8, 9, 4, 3, 5, 0]
    ///
    /// This method is equivalent to calling `shuffled(using:)`, passing in the
    /// system's default random generator.
    ///
    /// - Returns: A shuffled array of this sequence's elements.
    ///
    /// - Complexity: O(*n*), where *n* is the length of the sequence.
    @inlinable public func shuffled() -> URI {
        return URI(components.shuffled())
    }
    
    /// Shuffles the collection in place, using the given generator as a source
    /// for randomness.
    ///
    /// You use this method to randomize the elements of a collection when you
    /// are using a custom random number generator. For example, you can use the
    /// `shuffle(using:)` method to randomly reorder the elements of an array.
    ///
    ///     var names = ["Alejandro", "Camila", "Diego", "Luciana", "Luis", "Sofía"]
    ///     names.shuffle(using: &myGenerator)
    ///     // names == ["Sofía", "Alejandro", "Camila", "Luis", "Diego", "Luciana"]
    ///
    /// - Parameter generator: The random number generator to use when shuffling
    ///   the collection.
    ///
    /// - Complexity: O(*n*), where *n* is the length of the collection.
    /// - Note: The algorithm used to shuffle a collection may change in a future
    ///   version of Swift. If you're passing a generator that results in the
    ///   same shuffled order each time you run your program, that sequence may
    ///   change when your program is compiled using a different version of
    ///   Swift.
    @inlinable public mutating func shuffle<T>(using generator: inout T) where T : RandomNumberGenerator {
        components.shuffle(using: &generator)
    }
    
    /// Shuffles the collection in place.
    ///
    /// Use the `shuffle()` method to randomly reorder the elements of an array.
    ///
    ///     var names = ["Alejandro", "Camila", "Diego", "Luciana", "Luis", "Sofía"]
    ///     names.shuffle(using: myGenerator)
    ///     // names == ["Luis", "Camila", "Luciana", "Sofía", "Alejandro", "Diego"]
    ///
    /// This method is equivalent to calling `shuffle(using:)`, passing in the
    /// system's default random generator.
    ///
    /// - Complexity: O(*n*), where *n* is the length of the collection.
    @inlinable public mutating func shuffle() {
        components.shuffle()
    }
    
    @available(swift, deprecated: 4.1, renamed: "compactMap(_:)", message: "Please use compactMap(_:) for the case where closure returns an optional value")
    public func flatMap<ElementOfResult>(_ transform: (String) throws -> ElementOfResult?) rethrows -> [ElementOfResult] {
        return try components.flatMap(transform)
    }
    
    @inlinable public mutating func withContiguousMutableStorageIfAvailable<R>(_ body: (inout UnsafeMutableBufferPointer<String>) throws -> R) rethrows -> R? {
        return try components.withContiguousMutableStorageIfAvailable(body)
    }
    
    /// Accesses a contiguous subrange of the collection's elements.
    ///
    /// The accessed slice uses the same indices for the same elements as the
    /// original collection. Always use the slice's `startIndex` property
    /// instead of assuming that its indices start at a particular value.
    ///
    /// This example demonstrates getting a slice of an array of strings, finding
    /// the index of one of the strings in the slice, and then using that index
    /// in the original array.
    ///
    ///     let streets = ["Adams", "Bryant", "Channing", "Douglas", "Evarts"]
    ///     let streetsSlice = streets[2 ..< streets.endIndex]
    ///     print(streetsSlice)
    ///     // Prints "["Channing", "Douglas", "Evarts"]"
    ///
    ///     let index = streetsSlice.firstIndex(of: "Evarts")    // 4
    ///     streets[index!] = "Eustace"
    ///     print(streets[index!])
    ///     // Prints "Eustace"
    ///
    /// - Parameter bounds: A range of the collection's indices. The bounds of
    ///   the range must be valid indices of the collection.
    ///
    /// - Complexity: O(1)
    @inlinable public subscript(bounds: Range<Int>) -> Slice<Array<String>> {
        return components[bounds]
    }
    
    /// Exchanges the values at the specified indices of the collection.
    ///
    /// Both parameters must be valid indices of the collection that are not
    /// equal to `endIndex`. Calling `swapAt(_:_:)` with the same index as both
    /// `i` and `j` has no effect.
    ///
    /// - Parameters:
    ///   - i: The index of the first value to swap.
    ///   - j: The index of the second value to swap.
    ///
    /// - Complexity: O(1)
    @inlinable public mutating func swapAt(_ i: Int, _ j: Int) {
        components.swapAt(i, j)
    }
    
    /// The indices that are valid for subscripting the collection, in ascending
    /// order.
    @inlinable public var indices: Range<Int> {
        return components.indices
    }
    
    /// Accesses the contiguous subrange of the collection's elements specified
    /// by a range expression.
    ///
    /// The range expression is converted to a concrete subrange relative to this
    /// collection. For example, using a `PartialRangeFrom` range expression
    /// with an array accesses the subrange from the start of the range
    /// expression until the end of the array.
    ///
    ///     let streets = ["Adams", "Bryant", "Channing", "Douglas", "Evarts"]
    ///     let streetsSlice = streets[2...]
    ///     print(streetsSlice)
    ///     // ["Channing", "Douglas", "Evarts"]
    ///
    /// The accessed slice uses the same indices for the same elements as the
    /// original collection uses. This example searches `streetsSlice` for one
    /// of the strings in the slice, and then uses that index in the original
    /// array.
    ///
    ///     let index = streetsSlice.firstIndex(of: "Evarts")    // 4
    ///     print(streets[index!])
    ///     // "Evarts"
    ///
    /// Always use the slice's `startIndex` property instead of assuming that its
    /// indices start at a particular value. Attempting to access an element by
    /// using an index outside the bounds of the slice's indices may result in a
    /// runtime error, even if that index is valid for the original collection.
    ///
    ///     print(streetsSlice.startIndex)
    ///     // 2
    ///     print(streetsSlice[2])
    ///     // "Channing"
    ///
    ///     print(streetsSlice[0])
    ///     // error: Index out of bounds
    ///
    /// - Parameter bounds: A range of the collection's indices. The bounds of
    ///   the range must be valid indices of the collection.
    ///
    /// - Complexity: O(1)
    @inlinable public subscript<R>(r: R) -> ArraySlice<String> where R : RangeExpression, Int == R.Bound {
        return components[r]
    }
    
    @inlinable public subscript(x: (UnboundedRange_) -> ()) -> ArraySlice<String> {
        return components[x]
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
    @inlinable public init(repeating repeatedValue: String, count: Int) {
        components = [String](repeating: repeatedValue, count: count)
    }
    
    /// Creates a new instance of a collection containing the elements of a
    /// sequence.
    ///
    /// - Parameter elements: The sequence of elements for the new collection.
    @inlinable public init<S>(_ elements: S) where S : Sequence, String == S.Element {
        components =  [String](elements)
    }
    
    /// Adds an element to the end of the collection.
    ///
    /// If the collection does not have sufficient capacity for another element,
    /// additional storage is allocated before appending `newElement`. The
    /// following example adds a new number to an array of integers:
    ///
    ///     var numbers = [1, 2, 3, 4, 5]
    ///     numbers.append(100)
    ///
    ///     print(numbers)
    ///     // Prints "[1, 2, 3, 4, 5, 100]"
    ///
    /// - Parameter newElement: The element to append to the collection.
    ///
    /// - Complexity: O(1) on average, over many calls to `append(_:)` on the
    ///   same collection.
    @inlinable public mutating func append(_ newElement: __owned String) {
        let newElements = newElement
            .split(separator: #"\"#)
            .compactMap{ $0.isEmpty ? nil : String($0) }
        components.append(contentsOf: newElements)
    }
    
    /// Adds the elements of a sequence or collection to the end of this
    /// collection.
    ///
    /// The collection being appended to allocates any additional necessary
    /// storage to hold the new elements.
    ///
    /// The following example appends the elements of a `Range<Int>` instance to
    /// an array of integers:
    ///
    ///     var numbers = [1, 2, 3, 4, 5]
    ///     numbers.append(contentsOf: 10...15)
    ///     print(numbers)
    ///     // Prints "[1, 2, 3, 4, 5, 10, 11, 12, 13, 14, 15]"
    ///
    /// - Parameter newElements: The elements to append to the collection.
    ///
    /// - Complexity: O(*m*), where *m* is the length of `newElements`.
    @inlinable public mutating func append<S>(contentsOf newElements: __owned S) where S : Sequence, String == S.Element {
        components.append(contentsOf: newElements.filter{ !$0.isEmpty })
    }
    
    /// Inserts a new element into the collection at the specified position.
    ///
    /// The new element is inserted before the element currently at the
    /// specified index. If you pass the collection's `endIndex` property as
    /// the `index` parameter, the new element is appended to the
    /// collection.
    ///
    ///     var numbers = [1, 2, 3, 4, 5]
    ///     numbers.insert(100, at: 3)
    ///     numbers.insert(200, at: numbers.endIndex)
    ///
    ///     print(numbers)
    ///     // Prints "[1, 2, 3, 100, 4, 5, 200]"
    ///
    /// Calling this method may invalidate any existing indices for use with this
    /// collection.
    ///
    /// - Parameter newElement: The new element to insert into the collection.
    /// - Parameter i: The position at which to insert the new element.
    ///   `index` must be a valid index into the collection.
    ///
    /// - Complexity: O(*n*), where *n* is the length of the collection. If
    ///   `i == endIndex`, this method is equivalent to `append(_:)`.
    @inlinable public mutating func insert(_ newElement: __owned String, at i: Int) {
        let newElements = newElement
            .split(separator: #"\"#)
            .compactMap{ $0.isEmpty ? nil : String($0) }
        components.insert(contentsOf: newElements, at: i)
    }
    
    /// Inserts the elements of a sequence into the collection at the specified
    /// position.
    ///
    /// The new elements are inserted before the element currently at the
    /// specified index. If you pass the collection's `endIndex` property as the
    /// `index` parameter, the new elements are appended to the collection.
    ///
    /// Here's an example of inserting a range of integers into an array of the
    /// same type:
    ///
    ///     var numbers = [1, 2, 3, 4, 5]
    ///     numbers.insert(contentsOf: 100...103, at: 3)
    ///     print(numbers)
    ///     // Prints "[1, 2, 3, 100, 101, 102, 103, 4, 5]"
    ///
    /// Calling this method may invalidate any existing indices for use with this
    /// collection.
    ///
    /// - Parameter newElements: The new elements to insert into the collection.
    /// - Parameter i: The position at which to insert the new elements. `index`
    ///   must be a valid index of the collection.
    ///
    /// - Complexity: O(*n* + *m*), where *n* is length of this collection and
    ///   *m* is the length of `newElements`. If `i == endIndex`, this method
    ///   is equivalent to `append(contentsOf:)`.
    @inlinable public mutating func insert<C>(contentsOf newElements: __owned C, at i: Int) where C : Collection, String == C.Element {
        components.insert(contentsOf: newElements, at: i)
    }
    
    /// Removes and returns the element at the specified position.
    ///
    /// All the elements following the specified position are moved to close the
    /// gap. This example removes the middle element from an array of
    /// measurements.
    ///
    ///     var measurements = [1.2, 1.5, 2.9, 1.2, 1.6]
    ///     let removed = measurements.remove(at: 2)
    ///     print(measurements)
    ///     // Prints "[1.2, 1.5, 1.2, 1.6]"
    ///
    /// Calling this method may invalidate any existing indices for use with this
    /// collection.
    ///
    /// - Parameter position: The position of the element to remove. `position`
    ///   must be a valid index of the collection that is not equal to the
    ///   collection's end index.
    /// - Returns: The removed element.
    ///
    /// - Complexity: O(*n*), where *n* is the length of the collection.
    @inlinable public mutating func remove(at position: Int) -> String {
        return components.remove(at: position)
    }
    
    /// Removes the elements in the specified subrange from the collection.
    ///
    /// All the elements following the specified position are moved to close the
    /// gap. This example removes three elements from the middle of an array of
    /// measurements.
    ///
    ///     var measurements = [1.2, 1.5, 2.9, 1.2, 1.5]
    ///     measurements.removeSubrange(1..<4)
    ///     print(measurements)
    ///     // Prints "[1.2, 1.5]"
    ///
    /// Calling this method may invalidate any existing indices for use with this
    /// collection.
    ///
    /// - Parameter bounds: The range of the collection to be removed. The
    ///   bounds of the range must be valid indices of the collection.
    ///
    /// - Complexity: O(*n*), where *n* is the length of the collection.
    @inlinable public mutating func removeSubrange(_ bounds: Range<Int>) {
        components.removeSubrange(bounds)
    }
    
    /// Removes the specified number of elements from the beginning of the
    /// collection.
    ///
    ///     var bugs = ["Aphid", "Bumblebee", "Cicada", "Damselfly", "Earwig"]
    ///     bugs.removeFirst(3)
    ///     print(bugs)
    ///     // Prints "["Damselfly", "Earwig"]"
    ///
    /// Calling this method may invalidate any existing indices for use with this
    /// collection.
    ///
    /// - Parameter k: The number of elements to remove from the collection.
    ///   `k` must be greater than or equal to zero and must not exceed the
    ///   number of elements in the collection.
    ///
    /// - Complexity: O(*n*), where *n* is the length of the collection.
    @inlinable public mutating func removeFirst(_ k: Int) {
        components.removeFirst(k)
    }
    
    /// Removes and returns the first element of the collection.
    ///
    /// The collection must not be empty.
    ///
    ///     var bugs = ["Aphid", "Bumblebee", "Cicada", "Damselfly", "Earwig"]
    ///     bugs.removeFirst()
    ///     print(bugs)
    ///     // Prints "["Bumblebee", "Cicada", "Damselfly", "Earwig"]"
    ///
    /// Calling this method may invalidate any existing indices for use with this
    /// collection.
    ///
    /// - Returns: The removed element.
    ///
    /// - Complexity: O(*n*), where *n* is the length of the collection.
    @inlinable public mutating func removeFirst() -> String {
        return components.removeFirst()
    }
    
    /// Removes all elements from the collection.
    ///
    /// Calling this method may invalidate any existing indices for use with this
    /// collection.
    ///
    /// - Parameter keepCapacity: Pass `true` to request that the collection
    ///   avoid releasing its storage. Retaining the collection's storage can
    ///   be a useful optimization when you're planning to grow the collection
    ///   again. The default value is `false`.
    ///
    /// - Complexity: O(*n*), where *n* is the length of the collection.
    @inlinable public mutating func removeAll(keepingCapacity keepCapacity: Bool = false) {
        return components.removeAll(keepingCapacity: keepCapacity)
    }
    
    /// Prepares the collection to store the specified number of elements, when
    /// doing so is appropriate for the underlying type.
    ///
    /// If you will be adding a known number of elements to a collection, use
    /// this method to avoid multiple reallocations. A type that conforms to
    /// `RangeReplaceableCollection` can choose how to respond when this method
    /// is called. Depending on the type, it may make sense to allocate more or
    /// less storage than requested or to take no action at all.
    ///
    /// - Parameter n: The requested number of elements to store.
    @inlinable public mutating func reserveCapacity(_ n: Int) {
        components.reserveCapacity(n)
    }
    
    /// Replaces the specified subrange of elements with the given collection.
    ///
    /// This method has the effect of removing the specified range of elements
    /// from the collection and inserting the new elements at the same location.
    /// The number of new elements need not match the number of elements being
    /// removed.
    ///
    /// In this example, three elements in the middle of an array of integers are
    /// replaced by the five elements of a `Repeated<Int>` instance.
    ///
    ///      var nums = [10, 20, 30, 40, 50]
    ///      nums.replaceSubrange(1...3, with: repeatElement(1, count: 5))
    ///      print(nums)
    ///      // Prints "[10, 1, 1, 1, 1, 1, 50]"
    ///
    /// If you pass a zero-length range as the `subrange` parameter, this method
    /// inserts the elements of `newElements` at `subrange.startIndex`. Calling
    /// the `insert(contentsOf:at:)` method instead is preferred.
    ///
    /// Likewise, if you pass a zero-length collection as the `newElements`
    /// parameter, this method removes the elements in the given subrange
    /// without replacement. Calling the `removeSubrange(_:)` method instead is
    /// preferred.
    ///
    /// Calling this method may invalidate any existing indices for use with this
    /// collection.
    ///
    /// - Parameters:
    ///   - subrange: The subrange of the collection to replace. The bounds of
    ///     the range must be valid indices of the collection.
    ///   - newElements: The new elements to add to the collection.
    ///
    /// - Complexity: O(*n* + *m*), where *n* is length of this collection and
    ///   *m* is the length of `newElements`. If the call to this method simply
    ///   appends the contents of `newElements` to the collection, the complexity
    ///   is O(*m*).
    @inlinable public mutating func replaceSubrange<C, R>(_ subrange: R, with newElements: __owned C) where C : Collection, R : RangeExpression, String == C.Element, Int == R.Bound {
        components.replaceSubrange(subrange, with: newElements)
    }
    
    /// Removes the elements in the specified subrange from the collection.
    ///
    /// All the elements following the specified position are moved to close the
    /// gap. This example removes three elements from the middle of an array of
    /// measurements.
    ///
    ///     var measurements = [1.2, 1.5, 2.9, 1.2, 1.5]
    ///     measurements.removeSubrange(1..<4)
    ///     print(measurements)
    ///     // Prints "[1.2, 1.5]"
    ///
    /// Calling this method may invalidate any existing indices for use with this
    /// collection.
    ///
    /// - Parameter bounds: The range of the collection to be removed. The
    ///   bounds of the range must be valid indices of the collection.
    ///
    /// - Complexity: O(*n*), where *n* is the length of the collection.
    @inlinable public mutating func removeSubrange<R>(_ bounds: R) where R : RangeExpression, Int == R.Bound {
        components.removeSubrange(bounds)
    }
    
    /// Removes and returns the last element of the collection.
    ///
    /// Calling this method may invalidate all saved indices of this
    /// collection. Do not rely on a previously stored index value after
    /// altering a collection with any operation that can change its length.
    ///
    /// - Returns: The last element of the collection if the collection is not
    /// empty; otherwise, `nil`.
    ///
    /// - Complexity: O(1)
    @inlinable public mutating func popLast() -> String? {
        return components.popLast()
    }
    
    /// Removes and returns the last element of the collection.
    ///
    /// The collection must not be empty.
    ///
    /// Calling this method may invalidate all saved indices of this
    /// collection. Do not rely on a previously stored index value after
    /// altering a collection with any operation that can change its length.
    ///
    /// - Returns: The last element of the collection.
    ///
    /// - Complexity: O(1)
    @inlinable public mutating func removeLast() -> String {
        return components.removeLast()
    }
    
    /// Removes the specified number of elements from the end of the
    /// collection.
    ///
    /// Attempting to remove more elements than exist in the collection
    /// triggers a runtime error.
    ///
    /// Calling this method may invalidate all saved indices of this
    /// collection. Do not rely on a previously stored index value after
    /// altering a collection with any operation that can change its length.
    ///
    /// - Parameter k: The number of elements to remove from the collection.
    ///   `k` must be greater than or equal to zero and must not exceed the
    ///   number of elements in the collection.
    ///
    /// - Complexity: O(*k*), where *k* is the specified number of elements.
    @inlinable public mutating func removeLast(_ k: Int) {
        components.removeLast(k)
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
    @inlinable public static func + <Other>(lhs: URI, rhs: Other) -> URI where Other : Sequence, String == Other.Element {
        return URI(lhs.components + rhs)
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
    @inlinable public static func + <Other>(lhs: Other, rhs: URI) -> URI where Other : Sequence, String == Other.Element {
        return URI(lhs + rhs.components)
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
    @inlinable public static func += <Other>(lhs: inout URI, rhs: Other) where Other : Sequence, String == Other.Element {
        lhs.components.append(contentsOf: rhs.filter{ !$0.isEmpty })
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
    @inlinable public static func + <Other>(lhs: URI, rhs: Other) -> URI where Other : RangeReplaceableCollection, String == Other.Element {
        return URI(lhs.components + rhs.filter{ !$0.isEmpty })
    }
    
    /// Removes all the elements that satisfy the given predicate.
    ///
    /// Use this method to remove every element in a collection that meets
    /// particular criteria. The order of the remaining elements is preserved.
    /// This example removes all the odd values from an
    /// array of numbers:
    ///
    ///     var numbers = [5, 6, 7, 8, 9, 10, 11]
    ///     numbers.removeAll(where: { $0 % 2 != 0 })
    ///     // numbers == [6, 8, 10]
    ///
    /// - Parameter shouldBeRemoved: A closure that takes an element of the
    ///   sequence as its argument and returns a Boolean value indicating
    ///   whether the element should be removed from the collection.
    ///
    /// - Complexity: O(*n*), where *n* is the length of the collection.
    @inlinable public mutating func removeAll(where shouldBeRemoved: (String) throws -> Bool) rethrows {
        return try components.removeAll(where: shouldBeRemoved)
    }
    
    /// Reverses the elements of the collection in place.
    ///
    /// The following example reverses the elements of an array of characters:
    ///
    ///     var characters: [Character] = ["C", "a", "f", "é"]
    ///     characters.reverse()
    ///     print(characters)
    ///     // Prints "["é", "f", "a", "C"]
    ///
    /// - Complexity: O(*n*), where *n* is the number of elements in the
    ///   collection.
    @inlinable public mutating func reverse() {
        components.reverse()
    }
    
    /// Returns a view presenting the elements of the collection in reverse
    /// order.
    ///
    /// You can reverse a collection without allocating new space for its
    /// elements by calling this `reversed()` method. A `ReversedCollection`
    /// instance wraps an underlying collection and provides access to its
    /// elements in reverse order. This example prints the characters of a
    /// string in reverse order:
    ///
    ///     let word = "Backwards"
    ///     for char in word.reversed() {
    ///         print(char, terminator: "")
    ///     }
    ///     // Prints "sdrawkcaB"
    ///
    /// If you need a reversed collection of the same type, you may be able to
    /// use the collection's sequence-based or collection-based initializer. For
    /// example, to get the reversed version of a string, reverse its
    /// characters and initialize a new `String` instance from the result.
    ///
    ///     let reversedWord = String(word.reversed())
    ///     print(reversedWord)
    ///     // Prints "sdrawkcaB"
    ///
    /// - Complexity: O(1)
    @inlinable public __consuming func reversed() -> ReversedCollection<Array<String>> {
        return components.reversed()
    }
    
    /// A value less than or equal to the number of elements in the sequence,
    /// calculated nondestructively.
    ///
    /// The default implementation returns 0. If you provide your own
    /// implementation, make sure to compute the value nondestructively.
    ///
    /// - Complexity: O(1), except if the sequence also conforms to `Collection`.
    ///   In this case, see the documentation of `Collection.underestimatedCount`.
    @inlinable public var underestimatedCount: Int {
        return components.underestimatedCount
    }
    
    /// Calls the given closure on each element in the sequence in the same order
    /// as a `for`-`in` loop.
    ///
    /// The two loops in the following example produce the same output:
    ///
    ///     let numberWords = ["one", "two", "three"]
    ///     for word in numberWords {
    ///         print(word)
    ///     }
    ///     // Prints "one"
    ///     // Prints "two"
    ///     // Prints "three"
    ///
    ///     numberWords.forEach { word in
    ///         print(word)
    ///     }
    ///     // Same as above
    ///
    /// Using the `forEach` method is distinct from a `for`-`in` loop in two
    /// important ways:
    ///
    /// 1. You cannot use a `break` or `continue` statement to exit the current
    ///    call of the `body` closure or skip subsequent calls.
    /// 2. Using the `return` statement in the `body` closure will exit only from
    ///    the current call to `body`, not from any outer scope, and won't skip
    ///    subsequent calls.
    ///
    /// - Parameter body: A closure that takes an element of the sequence as a
    ///   parameter.
    @inlinable public func forEach(_ body: (String) throws -> Void) rethrows {
        try components.forEach(body)
    }
    
    /// Returns the first element of the sequence that satisfies the given
    /// predicate.
    ///
    /// The following example uses the `first(where:)` method to find the first
    /// negative number in an array of integers:
    ///
    ///     let numbers = [3, 7, 4, -2, 9, -6, 10, 1]
    ///     if let firstNegative = numbers.first(where: { $0 < 0 }) {
    ///         print("The first negative number is \(firstNegative).")
    ///     }
    ///     // Prints "The first negative number is -2."
    ///
    /// - Parameter predicate: A closure that takes an element of the sequence as
    ///   its argument and returns a Boolean value indicating whether the
    ///   element is a match.
    /// - Returns: The first element of the sequence that satisfies `predicate`,
    ///   or `nil` if there is no element that satisfies `predicate`.
    ///
    /// - Complexity: O(*n*), where *n* is the length of the sequence.
    @inlinable public func first(where predicate: (String) throws -> Bool) rethrows -> String? {
        return try components.first(where: predicate)
    }
    
    @inlinable public func withContiguousStorageIfAvailable<R>(_ body: (UnsafeBufferPointer<String>) throws -> R) rethrows -> R? {
        return try components.withContiguousStorageIfAvailable(body)
    }
    
    /// Returns a sequence of pairs (*n*, *x*), where *n* represents a
    /// consecutive integer starting at zero and *x* represents an element of
    /// the sequence.
    ///
    /// This example enumerates the characters of the string "Swift" and prints
    /// each character along with its place in the string.
    ///
    ///     for (n, c) in "Swift".enumerated() {
    ///         print("\(n): '\(c)'")
    ///     }
    ///     // Prints "0: 'S'"
    ///     // Prints "1: 'w'"
    ///     // Prints "2: 'i'"
    ///     // Prints "3: 'f'"
    ///     // Prints "4: 't'"
    ///
    /// When you enumerate a collection, the integer part of each pair is a counter
    /// for the enumeration, but is not necessarily the index of the paired value.
    /// These counters can be used as indices only in instances of zero-based,
    /// integer-indexed collections, such as `Array` and `ContiguousArray`. For
    /// other collections the counters may be out of range or of the wrong type
    /// to use as an index. To iterate over the elements of a collection with its
    /// indices, use the `zip(_:_:)` function.
    ///
    /// This example iterates over the indices and elements of a set, building a
    /// list consisting of indices of names with five or fewer letters.
    ///
    ///     let names: Set = ["Sofia", "Camilla", "Martina", "Mateo", "Nicolás"]
    ///     var shorterIndices: [Set<String>.Index] = []
    ///     for (i, name) in zip(names.indices, names) {
    ///         if name.count <= 5 {
    ///             shorterIndices.append(i)
    ///         }
    ///     }
    ///
    /// Now that the `shorterIndices` array holds the indices of the shorter
    /// names in the `names` set, you can use those indices to access elements in
    /// the set.
    ///
    ///     for i in shorterIndices {
    ///         print(names[i])
    ///     }
    ///     // Prints "Sofia"
    ///     // Prints "Mateo"
    ///
    /// - Returns: A sequence of pairs enumerating the sequence.
    ///
    /// - Complexity: O(1)
    @inlinable public func enumerated() -> EnumeratedSequence<Array<String>> {
        return components.enumerated()
    }
    
    /// Returns the minimum element in the sequence, using the given predicate as
    /// the comparison between elements.
    ///
    /// The predicate must be a *strict weak ordering* over the elements. That
    /// is, for any elements `a`, `b`, and `c`, the following conditions must
    /// hold:
    ///
    /// - `areInIncreasingOrder(a, a)` is always `false`. (Irreflexivity)
    /// - If `areInIncreasingOrder(a, b)` and `areInIncreasingOrder(b, c)` are
    ///   both `true`, then `areInIncreasingOrder(a, c)` is also
    ///   `true`. (Transitive comparability)
    /// - Two elements are *incomparable* if neither is ordered before the other
    ///   according to the predicate. If `a` and `b` are incomparable, and `b`
    ///   and `c` are incomparable, then `a` and `c` are also incomparable.
    ///   (Transitive incomparability)
    ///
    /// This example shows how to use the `min(by:)` method on a
    /// dictionary to find the key-value pair with the lowest value.
    ///
    ///     let hues = ["Heliotrope": 296, "Coral": 16, "Aquamarine": 156]
    ///     let leastHue = hues.min { a, b in a.value < b.value }
    ///     print(leastHue)
    ///     // Prints "Optional(("Coral", 16))"
    ///
    /// - Parameter areInIncreasingOrder: A predicate that returns `true`
    ///   if its first argument should be ordered before its second
    ///   argument; otherwise, `false`.
    /// - Returns: The sequence's minimum element, according to
    ///   `areInIncreasingOrder`. If the sequence has no elements, returns
    ///   `nil`.
    ///
    /// - Complexity: O(*n*), where *n* is the length of the sequence.
    @warn_unqualified_access
    @inlinable public func min(by areInIncreasingOrder: (String, String) throws -> Bool) rethrows -> String? {
        return try components.min(by: areInIncreasingOrder)
    }
    
    /// Returns the maximum element in the sequence, using the given predicate
    /// as the comparison between elements.
    ///
    /// The predicate must be a *strict weak ordering* over the elements. That
    /// is, for any elements `a`, `b`, and `c`, the following conditions must
    /// hold:
    ///
    /// - `areInIncreasingOrder(a, a)` is always `false`. (Irreflexivity)
    /// - If `areInIncreasingOrder(a, b)` and `areInIncreasingOrder(b, c)` are
    ///   both `true`, then `areInIncreasingOrder(a, c)` is also
    ///   `true`. (Transitive comparability)
    /// - Two elements are *incomparable* if neither is ordered before the other
    ///   according to the predicate. If `a` and `b` are incomparable, and `b`
    ///   and `c` are incomparable, then `a` and `c` are also incomparable.
    ///   (Transitive incomparability)
    ///
    /// This example shows how to use the `max(by:)` method on a
    /// dictionary to find the key-value pair with the highest value.
    ///
    ///     let hues = ["Heliotrope": 296, "Coral": 16, "Aquamarine": 156]
    ///     let greatestHue = hues.max { a, b in a.value < b.value }
    ///     print(greatestHue)
    ///     // Prints "Optional(("Heliotrope", 296))"
    ///
    /// - Parameter areInIncreasingOrder:  A predicate that returns `true` if its
    ///   first argument should be ordered before its second argument;
    ///   otherwise, `false`.
    /// - Returns: The sequence's maximum element if the sequence is not empty;
    ///   otherwise, `nil`.
    ///
    /// - Complexity: O(*n*), where *n* is the length of the sequence.
    @warn_unqualified_access
    @inlinable public func max(by areInIncreasingOrder: (String, String) throws -> Bool) rethrows -> String? {
        return try components.max(by: areInIncreasingOrder)
    }
    
    /// Returns a Boolean value indicating whether the initial elements of the
    /// sequence are equivalent to the elements in another sequence, using
    /// the given predicate as the equivalence test.
    ///
    /// The predicate must be a *equivalence relation* over the elements. That
    /// is, for any elements `a`, `b`, and `c`, the following conditions must
    /// hold:
    ///
    /// - `areEquivalent(a, a)` is always `true`. (Reflexivity)
    /// - `areEquivalent(a, b)` implies `areEquivalent(b, a)`. (Symmetry)
    /// - If `areEquivalent(a, b)` and `areEquivalent(b, c)` are both `true`, then
    ///   `areEquivalent(a, c)` is also `true`. (Transitivity)
    ///
    /// - Parameters:
    ///   - possiblePrefix: A sequence to compare to this sequence.
    ///   - areEquivalent: A predicate that returns `true` if its two arguments
    ///     are equivalent; otherwise, `false`.
    /// - Returns: `true` if the initial elements of the sequence are equivalent
    ///   to the elements of `possiblePrefix`; otherwise, `false`. If
    ///   `possiblePrefix` has no elements, the return value is `true`.
    ///
    /// - Complexity: O(*m*), where *m* is the lesser of the length of the
    ///   sequence and the length of `possiblePrefix`.
    @inlinable public func starts<PossiblePrefix>(with possiblePrefix: PossiblePrefix, by areEquivalent: (String, PossiblePrefix.Element) throws -> Bool) rethrows -> Bool where PossiblePrefix : Sequence {
        return try components.starts(with: possiblePrefix, by: areEquivalent)
    }
    
    /// Returns a Boolean value indicating whether this sequence and another
    /// sequence contain equivalent elements in the same order, using the given
    /// predicate as the equivalence test.
    ///
    /// At least one of the sequences must be finite.
    ///
    /// The predicate must be a *equivalence relation* over the elements. That
    /// is, for any elements `a`, `b`, and `c`, the following conditions must
    /// hold:
    ///
    /// - `areEquivalent(a, a)` is always `true`. (Reflexivity)
    /// - `areEquivalent(a, b)` implies `areEquivalent(b, a)`. (Symmetry)
    /// - If `areEquivalent(a, b)` and `areEquivalent(b, c)` are both `true`, then
    ///   `areEquivalent(a, c)` is also `true`. (Transitivity)
    ///
    /// - Parameters:
    ///   - other: A sequence to compare to this sequence.
    ///   - areEquivalent: A predicate that returns `true` if its two arguments
    ///     are equivalent; otherwise, `false`.
    /// - Returns: `true` if this sequence and `other` contain equivalent items,
    ///   using `areEquivalent` as the equivalence test; otherwise, `false.`
    ///
    /// - Complexity: O(*m*), where *m* is the lesser of the length of the
    ///   sequence and the length of `other`.
    @inlinable public func elementsEqual<OtherSequence>(_ other: OtherSequence, by areEquivalent: (String, OtherSequence.Element) throws -> Bool) rethrows -> Bool where OtherSequence : Sequence {
        return try components.elementsEqual(other, by: areEquivalent)
    }
    
    /// Returns a Boolean value indicating whether the sequence precedes another
    /// sequence in a lexicographical (dictionary) ordering, using the given
    /// predicate to compare elements.
    ///
    /// The predicate must be a *strict weak ordering* over the elements. That
    /// is, for any elements `a`, `b`, and `c`, the following conditions must
    /// hold:
    ///
    /// - `areInIncreasingOrder(a, a)` is always `false`. (Irreflexivity)
    /// - If `areInIncreasingOrder(a, b)` and `areInIncreasingOrder(b, c)` are
    ///   both `true`, then `areInIncreasingOrder(a, c)` is also
    ///   `true`. (Transitive comparability)
    /// - Two elements are *incomparable* if neither is ordered before the other
    ///   according to the predicate. If `a` and `b` are incomparable, and `b`
    ///   and `c` are incomparable, then `a` and `c` are also incomparable.
    ///   (Transitive incomparability)
    ///
    /// - Parameters:
    ///   - other: A sequence to compare to this sequence.
    ///   - areInIncreasingOrder:  A predicate that returns `true` if its first
    ///     argument should be ordered before its second argument; otherwise,
    ///     `false`.
    /// - Returns: `true` if this sequence precedes `other` in a dictionary
    ///   ordering as ordered by `areInIncreasingOrder`; otherwise, `false`.
    ///
    /// - Note: This method implements the mathematical notion of lexicographical
    ///   ordering, which has no connection to Unicode.  If you are sorting
    ///   strings to present to the end user, use `String` APIs that perform
    ///   localized comparison instead.
    ///
    /// - Complexity: O(*m*), where *m* is the lesser of the length of the
    ///   sequence and the length of `other`.
    @inlinable public func lexicographicallyPrecedes<OtherSequence>(_ other: OtherSequence, by areInIncreasingOrder: (String, String) throws -> Bool) rethrows -> Bool where OtherSequence : Sequence, String == OtherSequence.Element {
        return try components.lexicographicallyPrecedes(other, by: areInIncreasingOrder)
    }
    
    /// Returns a Boolean value indicating whether the sequence contains an
    /// element that satisfies the given predicate.
    ///
    /// You can use the predicate to check for an element of a type that
    /// doesn't conform to the `Equatable` protocol, such as the
    /// `HTTPResponse` enumeration in this example.
    ///
    ///     enum HTTPResponse {
    ///         case ok
    ///         case error(Int)
    ///     }
    ///
    ///     let lastThreeResponses: [HTTPResponse] = [.ok, .ok, .error(404)]
    ///     let hadError = lastThreeResponses.contains { element in
    ///         if case .error = element {
    ///             return true
    ///         } else {
    ///             return false
    ///         }
    ///     }
    ///     // 'hadError' == true
    ///
    /// Alternatively, a predicate can be satisfied by a range of `Equatable`
    /// elements or a general condition. This example shows how you can check an
    /// array for an expense greater than $100.
    ///
    ///     let expenses = [21.37, 55.21, 9.32, 10.18, 388.77, 11.41]
    ///     let hasBigPurchase = expenses.contains { $0 > 100 }
    ///     // 'hasBigPurchase' == true
    ///
    /// - Parameter predicate: A closure that takes an element of the sequence
    ///   as its argument and returns a Boolean value that indicates whether
    ///   the passed element represents a match.
    /// - Returns: `true` if the sequence contains an element that satisfies
    ///   `predicate`; otherwise, `false`.
    ///
    /// - Complexity: O(*n*), where *n* is the length of the sequence.
    @inlinable public func contains(where predicate: (String) throws -> Bool) rethrows -> Bool {
        return try components.contains(where: predicate)
    }
    
    /// Returns a Boolean value indicating whether every element of a sequence
    /// satisfies a given predicate.
    ///
    /// The following code uses this method to test whether all the names in an
    /// array have at least five characters:
    ///
    ///     let names = ["Sofia", "Camilla", "Martina", "Mateo", "Nicolás"]
    ///     let allHaveAtLeastFive = names.allSatisfy({ $0.count >= 5 })
    ///     // allHaveAtLeastFive == true
    ///
    /// - Parameter predicate: A closure that takes an element of the sequence
    ///   as its argument and returns a Boolean value that indicates whether
    ///   the passed element satisfies a condition.
    /// - Returns: `true` if the sequence contains only elements that satisfy
    ///   `predicate`; otherwise, `false`.
    ///
    /// - Complexity: O(*n*), where *n* is the length of the sequence.
    @inlinable public func allSatisfy(_ predicate: (String) throws -> Bool) rethrows -> Bool {
        return try components.allSatisfy(predicate)
    }
    
    /// Returns the result of combining the elements of the sequence using the
    /// given closure.
    ///
    /// Use the `reduce(_:_:)` method to produce a single value from the elements
    /// of an entire sequence. For example, you can use this method on an array
    /// of numbers to find their sum or product.
    ///
    /// The `nextPartialResult` closure is called sequentially with an
    /// accumulating value initialized to `initialResult` and each element of
    /// the sequence. This example shows how to find the sum of an array of
    /// numbers.
    ///
    ///     let numbers = [1, 2, 3, 4]
    ///     let numberSum = numbers.reduce(0, { x, y in
    ///         x + y
    ///     })
    ///     // numberSum == 10
    ///
    /// When `numbers.reduce(_:_:)` is called, the following steps occur:
    ///
    /// 1. The `nextPartialResult` closure is called with `initialResult`---`0`
    ///    in this case---and the first element of `numbers`, returning the sum:
    ///    `1`.
    /// 2. The closure is called again repeatedly with the previous call's return
    ///    value and each element of the sequence.
    /// 3. When the sequence is exhausted, the last value returned from the
    ///    closure is returned to the caller.
    ///
    /// If the sequence has no elements, `nextPartialResult` is never executed
    /// and `initialResult` is the result of the call to `reduce(_:_:)`.
    ///
    /// - Parameters:
    ///   - initialResult: The value to use as the initial accumulating value.
    ///     `initialResult` is passed to `nextPartialResult` the first time the
    ///     closure is executed.
    ///   - nextPartialResult: A closure that combines an accumulating value and
    ///     an element of the sequence into a new accumulating value, to be used
    ///     in the next call of the `nextPartialResult` closure or returned to
    ///     the caller.
    /// - Returns: The final accumulated value. If the sequence has no elements,
    ///   the result is `initialResult`.
    ///
    /// - Complexity: O(*n*), where *n* is the length of the sequence.
    @inlinable public func reduce<Result>(_ initialResult: Result, _ nextPartialResult: (Result, String) throws -> Result) rethrows -> Result {
        return try components.reduce(initialResult, nextPartialResult)
    }
    
    /// Returns the result of combining the elements of the sequence using the
    /// given closure.
    ///
    /// Use the `reduce(into:_:)` method to produce a single value from the
    /// elements of an entire sequence. For example, you can use this method on an
    /// array of integers to filter adjacent equal entries or count frequencies.
    ///
    /// This method is preferred over `reduce(_:_:)` for efficiency when the
    /// result is a copy-on-write type, for example an Array or a Dictionary.
    ///
    /// The `updateAccumulatingResult` closure is called sequentially with a
    /// mutable accumulating value initialized to `initialResult` and each element
    /// of the sequence. This example shows how to build a dictionary of letter
    /// frequencies of a string.
    ///
    ///     let letters = "abracadabra"
    ///     let letterCount = letters.reduce(into: [:]) { counts, letter in
    ///         counts[letter, default: 0] += 1
    ///     }
    ///     // letterCount == ["a": 5, "b": 2, "r": 2, "c": 1, "d": 1]
    ///
    /// When `letters.reduce(into:_:)` is called, the following steps occur:
    ///
    /// 1. The `updateAccumulatingResult` closure is called with the initial
    ///    accumulating value---`[:]` in this case---and the first character of
    ///    `letters`, modifying the accumulating value by setting `1` for the key
    ///    `"a"`.
    /// 2. The closure is called again repeatedly with the updated accumulating
    ///    value and each element of the sequence.
    /// 3. When the sequence is exhausted, the accumulating value is returned to
    ///    the caller.
    ///
    /// If the sequence has no elements, `updateAccumulatingResult` is never
    /// executed and `initialResult` is the result of the call to
    /// `reduce(into:_:)`.
    ///
    /// - Parameters:
    ///   - initialResult: The value to use as the initial accumulating value.
    ///   - updateAccumulatingResult: A closure that updates the accumulating
    ///     value with an element of the sequence.
    /// - Returns: The final accumulated value. If the sequence has no elements,
    ///   the result is `initialResult`.
    ///
    /// - Complexity: O(*n*), where *n* is the length of the sequence.
    @inlinable public func reduce<Result>(into initialResult: __owned Result, _ updateAccumulatingResult: (inout Result, String) throws -> ()) rethrows -> Result {
        return try components.reduce(into: initialResult, updateAccumulatingResult)
    }
    
    /// Returns an array containing the concatenated results of calling the
    /// given transformation with each element of this sequence.
    ///
    /// Use this method to receive a single-level collection when your
    /// transformation produces a sequence or collection for each element.
    ///
    /// In this example, note the difference in the result of using `map` and
    /// `flatMap` with a transformation that returns an array.
    ///
    ///     let numbers = [1, 2, 3, 4]
    ///
    ///     let mapped = numbers.map { Array(repeating: $0, count: $0) }
    ///     // [[1], [2, 2], [3, 3, 3], [4, 4, 4, 4]]
    ///
    ///     let flatMapped = numbers.flatMap { Array(repeating: $0, count: $0) }
    ///     // [1, 2, 2, 3, 3, 3, 4, 4, 4, 4]
    ///
    /// In fact, `s.flatMap(transform)`  is equivalent to
    /// `Array(s.map(transform).joined())`.
    ///
    /// - Parameter transform: A closure that accepts an element of this
    ///   sequence as its argument and returns a sequence or collection.
    /// - Returns: The resulting flattened array.
    ///
    /// - Complexity: O(*m* + *n*), where *n* is the length of this sequence
    ///   and *m* is the length of the result.
    @inlinable public func flatMap<SegmentOfResult>(_ transform: (String) throws -> SegmentOfResult) rethrows -> [SegmentOfResult.Element] where SegmentOfResult : Sequence {
        return try components.flatMap(transform)
    }
    
    /// Returns an array containing the non-`nil` results of calling the given
    /// transformation with each element of this sequence.
    ///
    /// Use this method to receive an array of non-optional values when your
    /// transformation produces an optional value.
    ///
    /// In this example, note the difference in the result of using `map` and
    /// `compactMap` with a transformation that returns an optional `Int` value.
    ///
    ///     let possibleNumbers = ["1", "2", "three", "///4///", "5"]
    ///
    ///     let mapped: [Int?] = possibleNumbers.map { str in Int(str) }
    ///     // [1, 2, nil, nil, 5]
    ///
    ///     let compactMapped: [Int] = possibleNumbers.compactMap { str in Int(str) }
    ///     // [1, 2, 5]
    ///
    /// - Parameter transform: A closure that accepts an element of this
    ///   sequence as its argument and returns an optional value.
    /// - Returns: An array of the non-`nil` results of calling `transform`
    ///   with each element of the sequence.
    ///
    /// - Complexity: O(*m* + *n*), where *n* is the length of this sequence
    ///   and *m* is the length of the result.
    @inlinable public func compactMap<ElementOfResult>(_ transform: (String) throws -> ElementOfResult?) rethrows -> [ElementOfResult] {
        return try components.compactMap(transform)
    }
    
    /// Returns the elements of the sequence, sorted using the given predicate as
    /// the comparison between elements.
    ///
    /// When you want to sort a sequence of elements that don't conform to the
    /// `Comparable` protocol, pass a predicate to this method that returns
    /// `true` when the first element should be ordered before the second. The
    /// elements of the resulting array are ordered according to the given
    /// predicate.
    ///
    /// In the following example, the predicate provides an ordering for an array
    /// of a custom `HTTPResponse` type. The predicate orders errors before
    /// successes and sorts the error responses by their error code.
    ///
    ///     enum HTTPResponse {
    ///         case ok
    ///         case error(Int)
    ///     }
    ///
    ///     let responses: [HTTPResponse] = [.error(500), .ok, .ok, .error(404), .error(403)]
    ///     let sortedResponses = responses.sorted {
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
    ///     print(sortedResponses)
    ///     // Prints "[.error(403), .error(404), .error(500), .ok, .ok]"
    ///
    /// You also use this method to sort elements that conform to the
    /// `Comparable` protocol in descending order. To sort your sequence in
    /// descending order, pass the greater-than operator (`>`) as the
    /// `areInIncreasingOrder` parameter.
    ///
    ///     let students: Set = ["Kofi", "Abena", "Peter", "Kweku", "Akosua"]
    ///     let descendingStudents = students.sorted(by: >)
    ///     print(descendingStudents)
    ///     // Prints "["Peter", "Kweku", "Kofi", "Akosua", "Abena"]"
    ///
    /// Calling the related `sorted()` method is equivalent to calling this
    /// method and passing the less-than operator (`<`) as the predicate.
    ///
    ///     print(students.sorted())
    ///     // Prints "["Abena", "Akosua", "Kofi", "Kweku", "Peter"]"
    ///     print(students.sorted(by: <))
    ///     // Prints "["Abena", "Akosua", "Kofi", "Kweku", "Peter"]"
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
    /// The sorting algorithm is not guaranteed to be stable. A stable sort
    /// preserves the relative order of elements for which
    /// `areInIncreasingOrder` does not establish an order.
    ///
    /// - Parameter areInIncreasingOrder: A predicate that returns `true` if its
    ///   first argument should be ordered before its second argument;
    ///   otherwise, `false`.
    /// - Returns: A sorted array of the sequence's elements.
    ///
    /// - Complexity: O(*n* log *n*), where *n* is the length of the sequence.
    @inlinable public func sorted(by areInIncreasingOrder: (String, String) throws -> Bool) rethrows -> URI {
        return URI(try components.sorted(by: areInIncreasingOrder))
    }
    
    /// Sorts the collection in place, using the given predicate as the
    /// comparison between elements.
    ///
    /// When you want to sort a collection of elements that don't conform to
    /// the `Comparable` protocol, pass a closure to this method that returns
    /// `true` when the first element should be ordered before the second.
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
    /// `areInIncreasingOrder` must be a *strict weak ordering* over the
    /// elements. That is, for any elements `a`, `b`, and `c`, the following
    /// conditions must hold:
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
    /// The sorting algorithm is not guaranteed to be stable. A stable sort
    /// preserves the relative order of elements for which
    /// `areInIncreasingOrder` does not establish an order.
    ///
    /// - Parameter areInIncreasingOrder: A predicate that returns `true` if its
    ///   first argument should be ordered before its second argument;
    ///   otherwise, `false`. If `areInIncreasingOrder` throws an error during
    ///   the sort, the elements may be in a different order, but none will be
    ///   lost.
    ///
    /// - Complexity: O(*n* log *n*), where *n* is the length of the collection.
    @inlinable public mutating func sort(by areInIncreasingOrder: (String, String) throws -> Bool) rethrows {
        return try components.sort(by: areInIncreasingOrder)
    }
}

/// Default implementations of core requirements
extension URI {
    
    /// A Boolean value indicating whether the collection is empty.
    ///
    /// When you need to check whether your collection is empty, use the
    /// `isEmpty` property instead of checking that the `count` property is
    /// equal to zero. For collections that don't conform to
    /// `RandomAccessCollection`, accessing the `count` property iterates
    /// through the elements of the collection.
    ///
    ///     let horseName = "Silver"
    ///     if horseName.isEmpty {
    ///         print("I've been through the desert on a horse with no name.")
    ///     } else {
    ///         print("Hi ho, \(horseName)!")
    ///     }
    ///     // Prints "Hi ho, Silver!")
    ///
    /// - Complexity: O(1)
    @inlinable public var isEmpty: Bool {
        return components.isEmpty
    }
    
    /// The first element of the collection.
    ///
    /// If the collection is empty, the value of this property is `nil`.
    ///
    ///     let numbers = [10, 20, 30, 40, 50]
    ///     if let firstNumber = numbers.first {
    ///         print(firstNumber)
    ///     }
    ///     // Prints "10"
    @inlinable public var first: String? {
        return components.first
    }
    
}

/// Supply the default `makeIterator()` method for `Collection` models
/// that accept the default associated `Iterator`,
/// `IndexingIterator<Self>`.
extension URI {
    
    /// Returns an iterator over the elements of the collection.
    @inlinable public __consuming func makeIterator() -> IndexingIterator<Array<String>> {
        return components.makeIterator()
    }
}



/// Default implementation for forward collections.
extension URI {
    
    /// Offsets the given index by the specified distance.
    ///
    /// The value passed as `distance` must not offset `i` beyond the bounds of
    /// the collection.
    ///
    /// - Parameters:
    ///   - i: A valid index of the collection.
    ///   - distance: The distance to offset `i`. `distance` must not be negative
    ///     unless the collection conforms to the `BidirectionalCollection`
    ///     protocol.
    ///
    /// - Complexity: O(1) if the collection conforms to
    ///   `RandomAccessCollection`; otherwise, O(*k*), where *k* is the absolute
    ///   value of `distance`.
    @inlinable public func formIndex(_ i: inout Int, offsetBy distance: Int) {
        return components.formIndex(&i, offsetBy: distance)
    }
    
    /// Offsets the given index by the specified distance, or so that it equals
    /// the given limiting index.
    ///
    /// The value passed as `distance` must not offset `i` beyond the bounds of
    /// the collection, unless the index passed as `limit` prevents offsetting
    /// beyond those bounds.
    ///
    /// - Parameters:
    ///   - i: A valid index of the collection.
    ///   - distance: The distance to offset `i`. `distance` must not be negative
    ///     unless the collection conforms to the `BidirectionalCollection`
    ///     protocol.
    ///   - limit: A valid index of the collection to use as a limit. If
    ///     `distance > 0`, a limit that is less than `i` has no effect.
    ///     Likewise, if `distance < 0`, a limit that is greater than `i` has no
    ///     effect.
    /// - Returns: `true` if `i` has been offset by exactly `distance` steps
    ///   without going beyond `limit`; otherwise, `false`. When the return
    ///   value is `false`, the value of `i` is equal to `limit`.
    ///
    /// - Complexity: O(1) if the collection conforms to
    ///   `RandomAccessCollection`; otherwise, O(*k*), where *k* is the absolute
    ///   value of `distance`.
    @inlinable public func formIndex(_ i: inout Int, offsetBy distance: Int, limitedBy limit: Int) -> Bool {
        return components.formIndex(&i, offsetBy: distance, limitedBy: limit)
    }
    
    /// Returns a random element of the collection, using the given generator as
    /// a source for randomness.
    ///
    /// Call `randomElement(using:)` to select a random element from an array or
    /// another collection when you are using a custom random number generator.
    /// This example picks a name at random from an array:
    ///
    ///     let names = ["Zoey", "Chloe", "Amani", "Amaia"]
    ///     let randomName = names.randomElement(using: &myGenerator)!
    ///     // randomName == "Amani"
    ///
    /// - Parameter generator: The random number generator to use when choosing a
    ///   random element.
    /// - Returns: A random element from the collection. If the collection is
    ///   empty, the method returns `nil`.
    ///
    /// - Complexity: O(1) if the collection conforms to
    ///   `RandomAccessCollection`; otherwise, O(*n*), where *n* is the length
    ///   of the collection.
    /// - Note: The algorithm used to select a random element may change in a
    ///   future version of Swift. If you're passing a generator that results in
    ///   the same sequence of elements each time you run your program, that
    ///   sequence may change when your program is compiled using a different
    ///   version of Swift.
    @inlinable public func randomElement<T>(using generator: inout T) -> String? where T : RandomNumberGenerator {
        return components.randomElement(using: &generator)
    }
    
    /// Returns a random element of the collection.
    ///
    /// Call `randomElement()` to select a random element from an array or
    /// another collection. This example picks a name at random from an array:
    ///
    ///     let names = ["Zoey", "Chloe", "Amani", "Amaia"]
    ///     let randomName = names.randomElement()!
    ///     // randomName == "Amani"
    ///
    /// This method is equivalent to calling `randomElement(using:)`, passing in
    /// the system's default random generator.
    ///
    /// - Returns: A random element from the collection. If the collection is
    ///   empty, the method returns `nil`.
    ///
    /// - Complexity: O(1) if the collection conforms to
    ///   `RandomAccessCollection`; otherwise, O(*n*), where *n* is the length
    ///   of the collection.
    @inlinable public func randomElement() -> String? {
        return components.randomElement()
    }
}

extension URI : CustomReflectable {
    
    /// A mirror that reflects the array.
    public var customMirror: Mirror {
        return Mirror(reflecting: self)
    }
}

extension URI : ExpressibleByArrayLiteral {
    
    /// Creates an array from the given array literal.
    ///
    /// Do not call this initializer directly. It is used by the compiler
    /// when you use an array literal. Instead, create a new array by using an
    /// array literal as its value. To do this, enclose a comma-separated list of
    /// values in square brackets.
    ///
    /// Here, an array of strings is created from an array literal holding
    /// only strings.
    ///
    ///     let ingredients = ["cocoa beans", "sugar", "cocoa butter", "salt"]
    ///
    /// - Parameter elements: A variadic list of elements of the new array.
    public init(arrayLiteral elements: String...) {
        components = elements
    }
}

extension URI : CustomStringConvertible, CustomDebugStringConvertible {
    
    /// A textual representation of the array and its elements.
    public var description: String {
        return rawValue
    }
    
    /// A textual representation of the array and its elements, suitable for
    /// debugging.
    public var debugDescription: String {
        return description.debugDescription
    }
}

extension URI : RandomAccessCollection, MutableCollection, RangeReplaceableCollection {
    
    public subscript(position: Int) -> String {
        get { return components[position] }
        set { components[position] = newValue }
    }
    
    public typealias SubSequence = ArraySlice<String>
    
    /// The index type for arrays, `Int`.
    public typealias Index = Int
    
    /// The type that represents the indices that are valid for subscripting an
    /// array, in ascending order.
    public typealias Indices = Range<Int>
    
    /// The type that allows iteration over an array's elements.
    public typealias Iterator = IndexingIterator<[String]>
    
    /// The position of the first element in a nonempty array.
    ///
    /// For an instance of `Array`, `startIndex` is always zero. If the array
    /// is empty, `startIndex` is equal to `endIndex`.
    @inlinable public var startIndex: Int {
        return components.startIndex
    }
    
    /// The array's "past the end" position---that is, the position one greater
    /// than the last valid subscript argument.
    ///
    /// When you need a range that includes the last element of an array, use the
    /// half-open range operator (`..<`) with `endIndex`. The `..<` operator
    /// creates a range that doesn't include the upper bound, so it's always
    /// safe to use with `endIndex`. For example:
    ///
    ///     let numbers = [10, 20, 30, 40, 50]
    ///     if let i = numbers.firstIndex(of: 30) {
    ///         print(numbers[i ..< numbers.endIndex])
    ///     }
    ///     // Prints "[30, 40, 50]"
    ///
    /// If the array is empty, `endIndex` is equal to `startIndex`.
    @inlinable public var endIndex: Int {
        return components.endIndex
    }
    
    /// Returns the position immediately after the given index.
    ///
    /// - Parameter i: A valid index of the collection. `i` must be less than
    ///   `endIndex`.
    /// - Returns: The index immediately after `i`.
    @inlinable public func index(after i: Int) -> Int {
        return components.index(after: i)
    }
    
    /// Replaces the given index with its successor.
    ///
    /// - Parameter i: A valid index of the collection. `i` must be less than
    ///   `endIndex`.
    @inlinable public func formIndex(after i: inout Int) {
        return components.formIndex(after: &i)
    }
    
    /// Returns the position immediately before the given index.
    ///
    /// - Parameter i: A valid index of the collection. `i` must be greater than
    ///   `startIndex`.
    /// - Returns: The index immediately before `i`.
    @inlinable public func index(before i: Int) -> Int {
        return components.index(before: i)
    }
    
    /// Replaces the given index with its predecessor.
    ///
    /// - Parameter i: A valid index of the collection. `i` must be greater than
    ///   `startIndex`.
    @inlinable public func formIndex(before i: inout Int) {
        return components.formIndex(before: &i)
    }
    
    /// Returns an index that is the specified distance from the given index.
    ///
    /// The following example obtains an index advanced four positions from an
    /// array's starting index and then prints the element at that position.
    ///
    ///     let numbers = [10, 20, 30, 40, 50]
    ///     let i = numbers.index(numbers.startIndex, offsetBy: 4)
    ///     print(numbers[i])
    ///     // Prints "50"
    ///
    /// The value passed as `distance` must not offset `i` beyond the bounds of
    /// the collection.
    ///
    /// - Parameters:
    ///   - i: A valid index of the array.
    ///   - distance: The distance to offset `i`.
    /// - Returns: An index offset by `distance` from the index `i`. If
    ///   `distance` is positive, this is the same value as the result of
    ///   `distance` calls to `index(after:)`. If `distance` is negative, this
    ///   is the same value as the result of `abs(distance)` calls to
    ///   `index(before:)`.
    @inlinable public func index(_ i: Int, offsetBy distance: Int) -> Int {
        return components.index(i, offsetBy: distance)
    }
    
    /// Returns an index that is the specified distance from the given index,
    /// unless that distance is beyond a given limiting index.
    ///
    /// The following example obtains an index advanced four positions from an
    /// array's starting index and then prints the element at that position. The
    /// operation doesn't require going beyond the limiting `numbers.endIndex`
    /// value, so it succeeds.
    ///
    ///     let numbers = [10, 20, 30, 40, 50]
    ///     if let i = numbers.index(numbers.startIndex,
    ///                              offsetBy: 4,
    ///                              limitedBy: numbers.endIndex) {
    ///         print(numbers[i])
    ///     }
    ///     // Prints "50"
    ///
    /// The next example attempts to retrieve an index ten positions from
    /// `numbers.startIndex`, but fails, because that distance is beyond the
    /// index passed as `limit`.
    ///
    ///     let j = numbers.index(numbers.startIndex,
    ///                           offsetBy: 10,
    ///                           limitedBy: numbers.endIndex)
    ///     print(j)
    ///     // Prints "nil"
    ///
    /// The value passed as `distance` must not offset `i` beyond the bounds of
    /// the collection, unless the index passed as `limit` prevents offsetting
    /// beyond those bounds.
    ///
    /// - Parameters:
    ///   - i: A valid index of the array.
    ///   - distance: The distance to offset `i`.
    ///   - limit: A valid index of the collection to use as a limit. If
    ///     `distance > 0`, `limit` has no effect if it is less than `i`.
    ///     Likewise, if `distance < 0`, `limit` has no effect if it is greater
    ///     than `i`.
    /// - Returns: An index offset by `distance` from the index `i`, unless that
    ///   index would be beyond `limit` in the direction of movement. In that
    ///   case, the method returns `nil`.
    ///
    /// - Complexity: O(1)
    @inlinable public func index(_ i: Int, offsetBy distance: Int, limitedBy limit: Int) -> Int? {
        return components.index(i, offsetBy: distance, limitedBy: limit)
    }
    
    /// Returns the distance between two indices.
    ///
    /// - Parameters:
    ///   - start: A valid index of the collection.
    ///   - end: Another valid index of the collection. If `end` is equal to
    ///     `start`, the result is zero.
    /// - Returns: The distance between `start` and `end`.
    @inlinable public func distance(from start: Int, to end: Int) -> Int {
        return components.distance(from: start, to: end)
    }
    
    /// Accesses a contiguous subrange of the array's elements.
    ///
    /// The returned `ArraySlice` instance uses the same indices for the same
    /// elements as the original array. In particular, that slice, unlike an
    /// array, may have a nonzero `startIndex` and an `endIndex` that is not
    /// equal to `count`. Always use the slice's `startIndex` and `endIndex`
    /// properties instead of assuming that its indices start or end at a
    /// particular value.
    ///
    /// This example demonstrates getting a slice of an array of strings, finding
    /// the index of one of the strings in the slice, and then using that index
    /// in the original array.
    ///
    ///     let streets = ["Adams", "Bryant", "Channing", "Douglas", "Evarts"]
    ///     let streetsSlice = streets[2 ..< streets.endIndex]
    ///     print(streetsSlice)
    ///     // Prints "["Channing", "Douglas", "Evarts"]"
    ///
    ///     let i = streetsSlice.firstIndex(of: "Evarts")    // 4
    ///     print(streets[i!])
    ///     // Prints "Evarts"
    ///
    /// - Parameter bounds: A range of integers. The bounds of the range must be
    ///   valid indices of the array.
    @inlinable public subscript(bounds: Range<Int>) -> ArraySlice<String> {
        return components[bounds]
    }
    
    /// The number of elements in the collection.
    ///
    /// To check whether a collection is empty, use its `isEmpty` property
    /// instead of comparing `count` to zero. Unless the collection guarantees
    /// random-access performance, calculating `count` can be an O(*n*)
    /// operation.
    ///
    /// - Complexity: O(1) if the collection conforms to
    ///   `RandomAccessCollection`; otherwise, O(*n*), where *n* is the length
    ///   of the collection.
    @inlinable public var count: Int {
        return components.count
    }
}

extension URI {
    
    /// Returns the elements of this sequence of sequences, concatenated.
    ///
    /// In this example, an array of three ranges is flattened so that the
    /// elements of each range can be iterated in turn.
    ///
    ///     let ranges = [0..<3, 8..<10, 15..<17]
    ///
    ///     // A for-in loop over 'ranges' accesses each range:
    ///     for range in ranges {
    ///       print(range)
    ///     }
    ///     // Prints "0..<3"
    ///     // Prints "8..<10"
    ///     // Prints "15..<17"
    ///
    ///     // Use 'joined()' to access each element of each range:
    ///     for index in ranges.joined() {
    ///         print(index, terminator: " ")
    ///     }
    ///     // Prints: "0 1 2 8 9 15 16"
    ///
    /// - Returns: A flattened view of the elements of this
    ///   sequence of sequences.
    @inlinable public __consuming func joined() -> FlattenSequence<Array<String>> {
        return components.joined()
    }
    
    /// Returns the concatenated elements of this sequence of sequences,
    /// inserting the given separator between each element.
    ///
    /// This example shows how an array of `[Int]` instances can be joined, using
    /// another `[Int]` instance as the separator:
    ///
    ///     let nestedNumbers = [[1, 2, 3], [4, 5, 6], [7, 8, 9]]
    ///     let joined = nestedNumbers.joined(separator: [-1, -2])
    ///     print(Array(joined))
    ///     // Prints "[1, 2, 3, -1, -2, 4, 5, 6, -1, -2, 7, 8, 9]"
    ///
    /// - Parameter separator: A sequence to insert between each of this
    ///   sequence's elements.
    /// - Returns: The joined sequence of elements.
    @inlinable public __consuming func joined<Separator>(separator: Separator) -> JoinedSequence<Array<String>> where Separator : Sequence, Separator.Element == String.Element {
        return components.joined(separator: separator)
    }
}

extension URI {
    
    /// Returns a new string by concatenating the elements of the sequence,
    /// adding the given separator between each element.
    ///
    /// The following example shows how an array of strings can be joined to a
    /// single, comma-separated string:
    ///
    ///     let cast = ["Vivien", "Marlon", "Kim", "Karl"]
    ///     let list = cast.joined(separator: ", ")
    ///     print(list)
    ///     // Prints "Vivien, Marlon, Kim, Karl"
    ///
    /// - Parameter separator: A string to insert between each of the elements
    ///   in this sequence. The default separator is an empty string.
    /// - Returns: A single, concatenated string.
    public func joined(separator: String = "") -> String {
        return components.joined(separator: separator)
    }
}

extension URI : Equatable {
    
    /// Returns a Boolean value indicating whether two arrays contain the same
    /// elements in the same order.
    ///
    /// You can use the equal-to operator (`==`) to compare any two arrays
    /// that store the same, `Equatable`-conforming element type.
    ///
    /// - Parameters:
    ///   - lhs: An array to compare.
    ///   - rhs: Another array to compare.
    @inlinable public static func == (lhs: URI, rhs: URI) -> Bool {
        return lhs.components == rhs.components
    }
    
}

extension URI : Comparable {
    
    @inlinable public static func < (lhs: URI, rhs: URI) -> Bool {
        return lhs.absolute < rhs.absolute
    }
    
}

extension URI : Hashable {
    /// Hashes the essential components of this value by feeding them into the
    /// given hasher.
    ///
    /// - Parameter hasher: The hasher to use when combining the components
    ///   of this instance.
    @inlinable public func hash(into hasher: inout Hasher) {
        hasher.combine(components)
    }
    
}

extension URI : Encodable {
    
    /// Encodes the elements of this array into the given encoder in an unkeyed
    /// container.
    ///
    /// This function throws an error if any values are invalid for the given
    /// encoder's format.
    ///
    /// - Parameter encoder: The encoder to write data to.
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(absolute)
    }
}

extension URI : Decodable {
    
    /// Creates a new array by decoding from the given decoder.
    ///
    /// This initializer throws an error if reading from the decoder fails, or
    /// if the data read is corrupted or otherwise invalid.
    ///
    /// - Parameter decoder: The decoder to read data from.
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        components = componentsFrom(path: try container.decode(String.self)).compactMap{ $0.isEmpty ? nil : String($0) }
    }
}


