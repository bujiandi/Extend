//
//  Array+Utils.swift
//
//  Created by bujiandi on 14/10/4.
//

extension Int {
    public func times(_ function: (Int) -> Void) {
        for i in 0 ..< self { function(i) }
    }
}

extension Sequence {
    
    /// join in string
    @inlinable public func joined(separator:String, includeElement:(Element) throws -> String = { unwrapOptionalToString($0) }) rethrows -> String {
        var result:String = ""
        for item:Element in self {
            if !result.isEmpty { result += separator }
            result += try includeElement(item)
        }
        return result
    }
    
    /// change to Set<T>
    @inlinable public func setMap<T>(_ transform: (Element) throws -> T) rethrows -> Set<T> where T:Hashable {
        var set = Set<T>()
        for item:Element in self {
            set.insert(try transform(item))
        }
        return set
    }
    
    /// change first Element as U
    @inlinable public func firstMap<U>(_ transform: (Element) throws -> U?) rethrows -> U? {
        return (try first { try transform($0) != nil }) as? U
    }
    
    /// split array by element count
    @inlinable public func split(elementCount:Int) throws -> [[Element]] {
        if elementCount <= 0 {
            throw "elementCount mast bigger than 0" as StringError
        }
        var result : [[Element]] = []
        var list = [Element]()
        
        for item in self {
            
            if list.count == elementCount {
                result.append(list)
                list.removeAll(keepingCapacity: true)
            }
            list.append(item)
        }
        if list.count > 0 { result.append(list) }
        return result
    }
}

extension RangeReplaceableCollection {
    
    /// ignore nil element append
    @inlinable public mutating func appendIgnoreNil(_ element:Element?) {
        if let value = element { append(value) }
    }
}


extension RangeReplaceableCollection where Element : Hashable {
    
    @inlinable public mutating func remove(element: Element) {
        if let i = firstIndex(of: element) {
            remove(at: i)
        }
    }
    
}

extension Collection {
    
    /// ignore out of range
    @inlinable public func element(at index:Index) -> Element? {
        if !(startIndex..<endIndex).contains(index) { return nil }
        return self[index]
    }
    
}


extension MutableCollection where Index == Int {
    
    /// 数据随机乱序 [已经有了 shuffled()]
//    mutating func shuffleInPlace() {
//        if count < 2 { return }
//
//        for i in 0..<count - 1 {
//            let j = Int.random(in: 1..<count)
//            guard i != j else { continue }
//            swapAt(i, j) // swap(&self[i], &self[j])
//        }
//    }
    
}

public func unwrapOptionalToString<T>(_ v:T?) -> String {
    var val:String!
    guard let value = v else { return "" }
    
    let mirror = Mirror(reflecting: value)
    if mirror.displayStyle == .optional {
        let children = mirror.children
        if children.count == 0 {
            val = ""
        } else {
            val = "\(children[children.startIndex].value)"
        }
    } else {
        val = "\(value)"
    }
    return val
}


public struct WeakArray<Element> where Element : AnyObject {
    
    private var array:[WeakContainer<Element>] = []
    
    public init() {}
}

extension WeakArray : RangeReplaceableCollection {
    
    public func makeIterator() -> IndexingIterator<[Element]> {
        let list = array.compactMap { $0.obj }
        return list.makeIterator()
    }
    
    /// Creates an array containing the elements of a sequence.
    ///
    /// You can use this initializer to create an array from any other type that
    /// conforms to the `Sequence` protocol. For example, you might want to
    /// create an array with the integers from 1 through 7. Use this initializer
    /// around a range instead of typing all those numbers in an array literal.
    ///
    ///     let numbers = Array(1...7)
    ///     print(numbers)
    ///     // Prints "[1, 2, 3, 4, 5, 6, 7]"
    ///
    /// You can also use this initializer to convert a complex sequence or
    /// collection type back to an array. For example, the `keys` property of
    /// a dictionary isn't an array with its own storage, it's a collection
    /// that maps its elements from the dictionary only when they're
    /// accessed, saving the time and space needed to allocate an array. If
    /// you need to pass those keys to a method that takes an array, however,
    /// use this initializer to convert that list from its type of
    /// `LazyMapCollection<Dictionary<String, Int>, Int>` to a simple
    /// `[String]`.
    ///
    ///     func cacheImagesWithNames(names: [String]) {
    ///         // custom image loading and caching
    ///      }
    ///
    ///     let namedHues: [String: Int] = ["Vermillion": 18, "Magenta": 302,
    ///             "Gold": 50, "Cerise": 320]
    ///     let colorNames = Array(namedHues.keys)
    ///     cacheImagesWithNames(colorNames)
    ///
    ///     print(colorNames)
    ///     // Prints "["Gold", "Cerise", "Magenta", "Vermillion"]"
    ///
    /// - Parameter s: The sequence of elements to turn into an array.
    public init<S>(_ s: S) where Element == S.Element, S : Sequence {
        
    }
    
    /// Creates a new array containing the specified number of a single, repeated
    /// value.
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
    public init(repeating repeatedValue: Element, count: Int) {
        
    }
    
    /// The number of elements in the array.
    public var count: Int { return array.count }
    
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
    public var capacity: Int { return array.capacity }
    
    /// Reserves enough space to store the specified number of elements.
    ///
    /// If you are adding a known number of elements to an array, use this method
    /// to avoid multiple reallocations. This method ensures that the array has
    /// unique, mutable, contiguous storage, with space allocated for at least
    /// the requested number of elements.
    ///
    /// Calling the `reserveCapacity(_:)` method on an array with bridged storage
    /// triggers a copy to contiguous storage even if the existing storage
    /// has room to store `minimumCapacity` elements.
    ///
    /// For performance reasons, the size of the newly allocated storage might be
    /// greater than the requested capacity. Use the array's `capacity` property
    /// to determine the size of the new storage.
    ///
    /// Preserving an Array's Geometric Growth Strategy
    /// ===============================================
    ///
    /// If you implement a custom data structure backed by an array that grows
    /// dynamically, naively calling the `reserveCapacity(_:)` method can lead
    /// to worse than expected performance. Arrays need to follow a geometric
    /// allocation pattern for appending elements to achieve amortized
    /// constant-time performance. The `Array` type's `append(_:)` and
    /// `append(contentsOf:)` methods take care of this detail for you, but
    /// `reserveCapacity(_:)` allocates only as much space as you tell it to
    /// (padded to a round value), and no more. This avoids over-allocation, but
    /// can result in insertion not having amortized constant-time performance.
    ///
    /// The following code declares `values`, an array of integers, and the
    /// `addTenQuadratic()` function, which adds ten more values to the `values`
    /// array on each call.
    ///
    ///       var values: [Int] = [0, 1, 2, 3]
    ///
    ///       // Don't use 'reserveCapacity(_:)' like this
    ///       func addTenQuadratic() {
    ///           let newCount = values.count + 10
    ///           values.reserveCapacity(newCount)
    ///           for n in values.count..<newCount {
    ///               values.append(n)
    ///           }
    ///       }
    ///
    /// The call to `reserveCapacity(_:)` increases the `values` array's capacity
    /// by exactly 10 elements on each pass through `addTenQuadratic()`, which
    /// is linear growth. Instead of having constant time when averaged over
    /// many calls, the function may decay to performance that is linear in
    /// `values.count`. This is almost certainly not what you want.
    ///
    /// In cases like this, the simplest fix is often to simply remove the call
    /// to `reserveCapacity(_:)`, and let the `append(_:)` method grow the array
    /// for you.
    ///
    ///       func addTen() {
    ///           let newCount = values.count + 10
    ///           for n in values.count..<newCount {
    ///               values.append(n)
    ///           }
    ///       }
    ///
    /// If you need more control over the capacity of your array, implement your
    /// own geometric growth strategy, passing the size you compute to
    /// `reserveCapacity(_:)`.
    ///
    /// - Parameter minimumCapacity: The requested number of elements to store.
    ///
    /// - Complexity: O(*n*), where *n* is the number of elements in the array.
    public mutating func reserveCapacity(_ minimumCapacity: Int) {
        array.reserveCapacity(minimumCapacity)
    }
    
    /// Adds a new element at the end of the array.
    ///
    /// Use this method to append a single element to the end of a mutable array.
    ///
    ///     var numbers = [1, 2, 3, 4, 5]
    ///     numbers.append(100)
    ///     print(numbers)
    ///     // Prints "[1, 2, 3, 4, 5, 100]"
    ///
    /// Because arrays increase their allocated capacity using an exponential
    /// strategy, appending a single element to an array is an O(1) operation
    /// when averaged over many calls to the `append(_:)` method. When an array
    /// has additional capacity and is not sharing its storage with another
    /// instance, appending an element is O(1). When an array needs to
    /// reallocate storage before appending or its storage is shared with
    /// another copy, appending is O(*n*), where *n* is the length of the array.
    ///
    /// - Parameter newElement: The element to append to the array.
    ///
    /// - Complexity: Amortized O(1) over many additions. If the array uses a
    ///   bridged `NSArray` instance as its storage, the efficiency is
    ///   unspecified.
    public mutating func append(_ newElement: Element) {
        array.append(WeakContainer<Element>(newElement))
    }
    
    /// Adds the elements of a sequence to the end of the array.
    ///
    /// Use this method to append the elements of a sequence to the end of this
    /// array. This example appends the elements of a `Range<Int>` instance
    /// to an array of integers.
    ///
    ///     var numbers = [1, 2, 3, 4, 5]
    ///     numbers.append(contentsOf: 10...15)
    ///     print(numbers)
    ///     // Prints "[1, 2, 3, 4, 5, 10, 11, 12, 13, 14, 15]"
    ///
    /// - Parameter newElements: The elements to append to the array.
    ///
    /// - Complexity: O(*n*), where *n* is the length of the resulting array.
    public mutating func append<S>(contentsOf newElements: S) where Element == S.Element, S : Sequence {
        array.append(contentsOf: newElements.map { WeakContainer<Element>($0) })
    }
    
    /// Inserts a new element at the specified position.
    ///
    /// The new element is inserted before the element currently at the specified
    /// index. If you pass the array's `endIndex` property as the `index`
    /// parameter, the new element is appended to the array.
    ///
    ///     var numbers = [1, 2, 3, 4, 5]
    ///     numbers.insert(100, at: 3)
    ///     numbers.insert(200, at: numbers.endIndex)
    ///
    ///     print(numbers)
    ///     // Prints "[1, 2, 3, 100, 4, 5, 200]"
    ///
    /// - Parameter newElement: The new element to insert into the array.
    /// - Parameter i: The position at which to insert the new element.
    ///   `index` must be a valid index of the array or equal to its `endIndex`
    ///   property.
    ///
    /// - Complexity: O(*n*), where *n* is the length of the array.
    public mutating func insert(_ newElement: Element, at i: Int) {
        array.insert(WeakContainer<Element>(newElement), at: i)
    }
    
    /// Removes and returns the element at the specified position.
    ///
    /// All the elements following the specified position are moved up to
    /// close the gap.
    ///
    ///     var measurements: [Double] = [1.1, 1.5, 2.9, 1.2, 1.5, 1.3, 1.2]
    ///     let removed = measurements.remove(at: 2)
    ///     print(measurements)
    ///     // Prints "[1.1, 1.5, 1.2, 1.5, 1.3, 1.2]"
    ///
    /// - Parameter index: The position of the element to remove. `index` must
    ///   be a valid index of the array.
    /// - Returns: The element at the specified index.
    ///
    /// - Complexity: O(*n*), where *n* is the length of the array.
    public mutating func remove(at index: Int) -> Element {
        return array.remove(at: index).obj!
    }
    
    /// Removes all elements from the array.
    ///
    /// - Parameter keepCapacity: Pass `true` to keep the existing capacity of
    ///   the array after removing its elements. The default value is
    ///   `false`.
    ///
    /// - Complexity: O(*n*), where *n* is the length of the array.
    public mutating func removeAll(keepingCapacity keepCapacity: Bool = false) {
        array.removeAll(keepingCapacity: keepCapacity)
    }
}

extension WeakArray : CustomReflectable {
    
    /// A mirror that reflects the array.
    public var customMirror: Mirror { return array.customMirror }
}

extension WeakArray : ExpressibleByArrayLiteral {
    
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
    public init(arrayLiteral elements: Element...) {
        array = elements.map { WeakContainer<Element>($0) }
    }
}

extension WeakArray : CustomStringConvertible, CustomDebugStringConvertible {
    
    /// A textual representation of the array and its elements.
    public var description: String { return array.description }
    
    /// A textual representation of the array and its elements, suitable for
    /// debugging.
    public var debugDescription: String { return array.debugDescription }
}

extension WeakArray : RandomAccessCollection, MutableCollection {
    
    /// The index type for arrays, `Int`.
    public typealias Index = Int
    
    /// The type that represents the indices that are valid for subscripting an
    /// array, in ascending order.
    public typealias Indices = CountableRange<Int>
    
    /// The type that allows iteration over an array's elements.
    public typealias Iterator = IndexingIterator<[Element]>
    
    /// The position of the first element in a nonempty array.
    ///
    /// For an instance of `Array`, `startIndex` is always zero. If the array
    /// is empty, `startIndex` is equal to `endIndex`.
    public var startIndex: Int { return array.startIndex }
    
    /// The array's "past the end" position---that is, the position one greater
    /// than the last valid subscript argument.
    ///
    /// When you need a range that includes the last element of an array, use the
    /// half-open range operator (`..<`) with `endIndex`. The `..<` operator
    /// creates a range that doesn't include the upper bound, so it's always
    /// safe to use with `endIndex`. For example:
    ///
    ///     let numbers = [10, 20, 30, 40, 50]
    ///     if let i = numbers.index(of: 30) {
    ///         print(numbers[i ..< numbers.endIndex])
    ///     }
    ///     // Prints "[30, 40, 50]"
    ///
    /// If the array is empty, `endIndex` is equal to `startIndex`.
    public var endIndex: Int { return array.endIndex }
    
    /// Returns the position immediately after the given index.
    ///
    /// - Parameter i: A valid index of the collection. `i` must be less than
    ///   `endIndex`.
    /// - Returns: The index immediately after `i`.
    public func index(after i: Int) -> Int {
        return array.index(after: i)
    }
    
    /// Replaces the given index with its successor.
    ///
    /// - Parameter i: A valid index of the collection. `i` must be less than
    ///   `endIndex`.
    public func formIndex(after i: inout Int) {
        return array.formIndex(after: &i)
    }
    
    /// Returns the position immediately before the given index.
    ///
    /// - Parameter i: A valid index of the collection. `i` must be greater than
    ///   `startIndex`.
    /// - Returns: The index immediately before `i`.
    public func index(before i: Int) -> Int {
        return array.index(before: i)
    }
    
    /// Replaces the given index with its predecessor.
    ///
    /// - Parameter i: A valid index of the collection. `i` must be greater than
    ///   `startIndex`.
    public func formIndex(before i: inout Int) {
        return array.formIndex(before: &i)
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
    /// The value passed as `n` must not offset `i` beyond the bounds of the
    /// collection.
    ///
    /// - Parameters:
    ///   - i: A valid index of the array.
    ///   - n: The distance to offset `i`.
    /// - Returns: An index offset by `n` from the index `i`. If `n` is positive,
    ///   this is the same value as the result of `n` calls to `index(after:)`.
    ///   If `n` is negative, this is the same value as the result of `-n` calls
    ///   to `index(before:)`.
    public func index(_ i: Int, offsetBy n: Int) -> Int {
        return array.index(i, offsetBy: n)
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
    /// The value passed as `n` must not offset `i` beyond the bounds of the
    /// collection, unless the index passed as `limit` prevents offsetting
    /// beyond those bounds.
    ///
    /// - Parameters:
    ///   - i: A valid index of the array.
    ///   - n: The distance to offset `i`.
    ///   - limit: A valid index of the collection to use as a limit. If `n > 0`,
    ///     `limit` has no effect if it is less than `i`. Likewise, if `n < 0`,
    ///     `limit` has no effect if it is greater than `i`.
    /// - Returns: An index offset by `n` from the index `i`, unless that index
    ///   would be beyond `limit` in the direction of movement. In that case,
    ///   the method returns `nil`.
    public func index(_ i: Int, offsetBy n: Int, limitedBy limit: Int) -> Int? {
        return array.index(i, offsetBy: n, limitedBy: limit)
    }
    
    /// Returns the distance between two indices.
    ///
    /// - Parameters:
    ///   - start: A valid index of the collection.
    ///   - end: Another valid index of the collection. If `end` is equal to
    ///     `start`, the result is zero.
    /// - Returns: The distance between `start` and `end`.
    public func distance(from start: Int, to end: Int) -> Int {
        return array.distance(from: start, to: end)
    }
    
    /// Accesses the element at the specified position.
    ///
    /// The following example uses indexed subscripting to update an array's
    /// second element. After assigning the new value (`"Butler"`) at a specific
    /// position, that value is immediately available at that same position.
    ///
    ///     var streets = ["Adams", "Bryant", "Channing", "Douglas", "Evarts"]
    ///     streets[1] = "Butler"
    ///     print(streets[1])
    ///     // Prints "Butler"
    ///
    /// - Parameter index: The position of the element to access. `index` must be
    ///   greater than or equal to `startIndex` and less than `endIndex`.
    ///
    /// - Complexity: Reading an element from an array is O(1). Writing is O(1)
    ///   unless the array's storage is shared with another array, in which case
    ///   writing is O(*n*), where *n* is the length of the array.
    ///   If the array uses a bridged `NSArray` instance as its storage, the
    ///   efficiency is unspecified.
    public subscript(index: Int) -> Element {
        get { return array[index].obj! }
        set { array[index].obj = newValue }
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
    ///     let i = streetsSlice.index(of: "Evarts")    // 4
    ///     print(streets[i!])
    ///     // Prints "Evarts"
    ///
    /// - Parameter bounds: A range of integers. The bounds of the range must be
    ///   valid indices of the array.
    public subscript(bounds: Range<Int>) -> ArraySlice<Element> {
        let list = array.compactMap { $0.obj }
        return list[bounds]
    }
}

extension WeakArray where Element : Collection {
    
    /// Returns the elements of this collection of collections, concatenated.
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
    ///   collection of collections.
    public func joined() -> FlattenCollection<Array<Element>> {
        let list = array.compactMap { $0.obj }
        return list.joined()
    }
}

extension WeakArray where Element : Sequence {
    
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
    public func joined() -> FlattenSequence<Array<Element>> {
        let list = array.compactMap { $0.obj }
        return list.joined()
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
    public func joined<Separator>(separator: Separator) -> JoinedSequence<Array<Element>> where Separator : Sequence, Separator.Element == Element.Element {
        let list = array.compactMap { $0.obj }
        return list.joined(separator: separator)
    }
}

extension WeakArray where Element : Equatable {
    
    /// Returns the longest possible subsequences of the collection, in order,
    /// around elements equal to the given element.
    ///
    /// The resulting array consists of at most `maxSplits + 1` subsequences.
    /// Elements that are used to split the collection are not returned as part
    /// of any subsequence.
    ///
    /// The following examples show the effects of the `maxSplits` and
    /// `omittingEmptySubsequences` parameters when splitting a string at each
    /// space character (" "). The first use of `split` returns each word that
    /// was originally separated by one or more spaces.
    ///
    ///     let line = "BLANCHE:   I don't want realism. I want magic!"
    ///     print(line.split(separator: " "))
    ///     // Prints "["BLANCHE:", "I", "don\'t", "want", "realism.", "I", "want", "magic!"]"
    ///
    /// The second example passes `1` for the `maxSplits` parameter, so the
    /// original string is split just once, into two new strings.
    ///
    ///     print(line.split(separator: " ", maxSplits: 1))
    ///     // Prints "["BLANCHE:", "  I don\'t want realism. I want magic!"]"
    ///
    /// The final example passes `false` for the `omittingEmptySubsequences`
    /// parameter, so the returned array contains empty strings where spaces
    /// were repeated.
    ///
    ///     print(line.split(separator: " ", omittingEmptySubsequences: false))
    ///     // Prints "["BLANCHE:", "", "", "I", "don\'t", "want", "realism.", "I", "want", "magic!"]"
    ///
    /// - Parameters:
    ///   - separator: The element that should be split upon.
    ///   - maxSplits: The maximum number of times to split the collection, or
    ///     one less than the number of subsequences to return. If
    ///     `maxSplits + 1` subsequences are returned, the last one is a suffix
    ///     of the original collection containing the remaining elements.
    ///     `maxSplits` must be greater than or equal to zero. The default value
    ///     is `Int.max`.
    ///   - omittingEmptySubsequences: If `false`, an empty subsequence is
    ///     returned in the result for each consecutive pair of `separator`
    ///     elements in the collection and for each instance of `separator` at
    ///     the start or end of the collection. If `true`, only nonempty
    ///     subsequences are returned. The default value is `true`.
    /// - Returns: An array of subsequences, split from this collection's
    ///   elements.
    public func split(separator: Element, maxSplits: Int = 0, omittingEmptySubsequences: Bool = false) -> [ArraySlice<Element>] {
        let list = array.compactMap { $0.obj }
        return list.split(separator: separator, maxSplits: maxSplits, omittingEmptySubsequences: omittingEmptySubsequences)
    }
    
    /// Returns the first index where the specified value appears in the
    /// collection.
    ///
    /// After using `index(of:)` to find the position of a particular element in
    /// a collection, you can use it to access the element by subscripting. This
    /// example shows how you can modify one of the names in an array of
    /// students.
    ///
    ///     var students = ["Ben", "Ivy", "Jordell", "Maxime"]
    ///     if let i = students.index(of: "Maxime") {
    ///         students[i] = "Max"
    ///     }
    ///     print(students)
    ///     // Prints "["Ben", "Ivy", "Jordell", "Max"]"
    ///
    /// - Parameter element: An element to search for in the collection.
    /// - Returns: The first index where `element` is found. If `element` is not
    ///   found in the collection, returns `nil`.
    public func index(of element: Element) -> Int? {
        for (i, container) in array.enumerated() {
            if container.obj == element { return i }
        }
        return nil
    }
    
    
    
    /// Returns a Boolean value indicating whether the initial elements of the
    /// sequence are the same as the elements in another sequence.
    ///
    /// This example tests whether one countable range begins with the elements
    /// of another countable range.
    ///
    ///     let a = 1...3
    ///     let b = 1...10
    ///
    ///     print(b.starts(with: a))
    ///     // Prints "true"
    ///
    /// Passing a sequence with no elements or an empty collection as
    /// `possiblePrefix` always results in `true`.
    ///
    ///     print(b.starts(with: []))
    ///     // Prints "true"
    ///
    /// - Parameter possiblePrefix: A sequence to compare to this sequence.
    /// - Returns: `true` if the initial elements of the sequence are the same as
    ///   the elements of `possiblePrefix`; otherwise, `false`. If
    ///   `possiblePrefix` has no elements, the return value is `true`.
    public func starts<PossiblePrefix>(with possiblePrefix: PossiblePrefix) -> Bool where PossiblePrefix : Sequence, Element == PossiblePrefix.Element {
        let list = array.compactMap { $0.obj }
        return list.starts(with: possiblePrefix)
    }
    
    /// Returns a Boolean value indicating whether this sequence and another
    /// sequence contain the same elements in the same order.
    ///
    /// At least one of the sequences must be finite.
    ///
    /// This example tests whether one countable range shares the same elements
    /// as another countable range and an array.
    ///
    ///     let a = 1...3
    ///     let b = 1...10
    ///
    ///     print(a.elementsEqual(b))
    ///     // Prints "false"
    ///     print(a.elementsEqual([1, 2, 3]))
    ///     // Prints "true"
    ///
    /// - Parameter other: A sequence to compare to this sequence.
    /// - Returns: `true` if this sequence and `other` contain the same elements
    ///   in the same order.
    public func elementsEqual<OtherSequence>(_ other: OtherSequence) -> Bool where OtherSequence : Sequence, Element == OtherSequence.Element {
        let list = array.compactMap { $0.obj }
        return list.elementsEqual(other)
    }
    
    /// Returns a Boolean value indicating whether the sequence contains the
    /// given element.
    ///
    /// This example checks to see whether a favorite actor is in an array
    /// storing a movie's cast.
    ///
    ///     let cast = ["Vivien", "Marlon", "Kim", "Karl"]
    ///     print(cast.contains("Marlon"))
    ///     // Prints "true"
    ///     print(cast.contains("James"))
    ///     // Prints "false"
    ///
    /// - Parameter element: The element to find in the sequence.
    /// - Returns: `true` if the element was found in the sequence; otherwise,
    ///   `false`.
    public func contains(_ element: Element) -> Bool {
        let list = array.compactMap { $0.obj }
        return list.contains(element)
    }
}


extension WeakArray where Element : BidirectionalCollection {
    
    /// Returns the elements of this collection of collections, concatenated.
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
    ///   collection of collections.
    public func joined() -> FlattenCollection<Array<Element>> {
        let list = array.compactMap { $0.obj }
        return list.joined()
    }
}

extension WeakArray where Element : Comparable {
//
//    /// Returns the elements of the sequence, sorted.
//    ///
//    /// You can sort any sequence of elements that conform to the
//    /// `Comparable` protocol by calling this method. Elements are sorted in
//    /// ascending order.
//    ///
//    /// The sorting algorithm is not stable. A nonstable sort may change the
//    /// relative order of elements that compare equal.
//    ///
//    /// Here's an example of sorting a list of students' names. Strings in Swift
//    /// conform to the `Comparable` protocol, so the names are sorted in
//    /// ascending order according to the less-than operator (`<`).
//    ///
//    ///     let students: Set = ["Kofi", "Abena", "Peter", "Kweku", "Akosua"]
//    ///     let sortedStudents = students.sorted()
//    ///     print(sortedStudents)
//    ///     // Prints "["Abena", "Akosua", "Kofi", "Kweku", "Peter"]"
//    ///
//    /// To sort the elements of your sequence in descending order, pass the
//    /// greater-than operator (`>`) to the `sorted(by:)` method.
//    ///
//    ///     let descendingStudents = students.sorted(by: >)
//    ///     print(descendingStudents)
//    ///     // Prints "["Peter", "Kweku", "Kofi", "Akosua", "Abena"]"
//    ///
//    /// - Returns: A sorted array of the sequence's elements.
//    public func sorted() -> [Element]
//
//    /// Returns the elements of the collection, sorted.
//    ///
//    /// You can sort any collection of elements that conform to the
//    /// `Comparable` protocol by calling this method. Elements are sorted in
//    /// ascending order.
//    ///
//    /// The sorting algorithm is not stable. A nonstable sort may change the
//    /// relative order of elements that compare equal.
//    ///
//    /// Here's an example of sorting a list of students' names. Strings in Swift
//    /// conform to the `Comparable` protocol, so the names are sorted in
//    /// ascending order according to the less-than operator (`<`).
//    ///
//    ///     let students: Set = ["Kofi", "Abena", "Peter", "Kweku", "Akosua"]
//    ///     let sortedStudents = students.sorted()
//    ///     print(sortedStudents)
//    ///     // Prints "["Abena", "Akosua", "Kofi", "Kweku", "Peter"]"
//    ///
//    /// To sort the elements of your collection in descending order, pass the
//    /// greater-than operator (`>`) to the `sorted(by:)` method.
//    ///
//    ///     let descendingStudents = students.sorted(by: >)
//    ///     print(descendingStudents)
//    ///     // Prints "["Peter", "Kweku", "Kofi", "Akosua", "Abena"]"
//    ///
//    /// - Returns: A sorted array of the collection's elements.
//    public func sorted() -> [Element]
//
//    /// Sorts the collection in place.
//    ///
//    /// You can sort any mutable collection of elements that conform to the
//    /// `Comparable` protocol by calling this method. Elements are sorted in
//    /// ascending order.
//    ///
//    /// The sorting algorithm is not stable. A nonstable sort may change the
//    /// relative order of elements that compare equal.
//    ///
//    /// Here's an example of sorting a list of students' names. Strings in Swift
//    /// conform to the `Comparable` protocol, so the names are sorted in
//    /// ascending order according to the less-than operator (`<`).
//    ///
//    ///     var students = ["Kofi", "Abena", "Peter", "Kweku", "Akosua"]
//    ///     students.sort()
//    ///     print(students)
//    ///     // Prints "["Abena", "Akosua", "Kofi", "Kweku", "Peter"]"
//    ///
//    /// To sort the elements of your collection in descending order, pass the
//    /// greater-than operator (`>`) to the `sort(by:)` method.
//    ///
//    ///     students.sort(by: >)
//    ///     print(students)
//    ///     // Prints "["Peter", "Kweku", "Kofi", "Akosua", "Abena"]"
//    public mutating func sort()
//
//    /// Returns the minimum element in the sequence.
//    ///
//    /// This example finds the smallest value in an array of height measurements.
//    ///
//    ///     let heights = [67.5, 65.7, 64.3, 61.1, 58.5, 60.3, 64.9]
//    ///     let lowestHeight = heights.min()
//    ///     print(lowestHeight)
//    ///     // Prints "Optional(58.5)"
//    ///
//    /// - Returns: The sequence's minimum element. If the sequence has no
//    ///   elements, returns `nil`.
//    @warn_unqualified_access
//    public func min() -> Element?
//
//    /// Returns the maximum element in the sequence.
//    ///
//    /// This example finds the largest value in an array of height measurements.
//    ///
//    ///     let heights = [67.5, 65.7, 64.3, 61.1, 58.5, 60.3, 64.9]
//    ///     let greatestHeight = heights.max()
//    ///     print(greatestHeight)
//    ///     // Prints "Optional(67.5)"
//    ///
//    /// - Returns: The sequence's maximum element. If the sequence has no
//    ///   elements, returns `nil`.
//    @warn_unqualified_access
//    public func max() -> Element?
//
//    /// Returns a Boolean value indicating whether the sequence precedes another
//    /// sequence in a lexicographical (dictionary) ordering, using the
//    /// less-than operator (`<`) to compare elements.
//    ///
//    /// This example uses the `lexicographicallyPrecedes` method to test which
//    /// array of integers comes first in a lexicographical ordering.
//    ///
//    ///     let a = [1, 2, 2, 2]
//    ///     let b = [1, 2, 3, 4]
//    ///
//    ///     print(a.lexicographicallyPrecedes(b))
//    ///     // Prints "true"
//    ///     print(b.lexicographicallyPrecedes(b))
//    ///     // Prints "false"
//    ///
//    /// - Parameter other: A sequence to compare to this sequence.
//    /// - Returns: `true` if this sequence precedes `other` in a dictionary
//    ///   ordering; otherwise, `false`.
//    ///
//    /// - Note: This method implements the mathematical notion of lexicographical
//    ///   ordering, which has no connection to Unicode.  If you are sorting
//    ///   strings to present to the end user, use `String` APIs that
//    ///   perform localized comparison.
//    public func lexicographicallyPrecedes<OtherSequence>(_ other: OtherSequence) -> Bool where OtherSequence : Sequence, Element == OtherSequence.Element {
//
//    }
}

extension WeakArray : Equatable where Element : Equatable {
    
    public static func == (lhs: WeakArray<Element>, rhs: WeakArray<Element>) -> Bool {
        if lhs.count != rhs.count { return false }
        for i in 0..<lhs.count {
            if lhs.array[i].obj != rhs.array[i].obj {
                return false
            }
        }
        return true
    }
    
}

extension WeakArray : Encodable where Element : Encodable {
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        let list = array.compactMap { $0.obj }
        try container.encode(contentsOf: list)
    }
}

extension WeakArray : Decodable where Element : Decodable {
    
    /// Creates a new array by decoding from the given decoder.
    ///
    /// This initializer throws an error if reading from the decoder fails, or
    /// if the data read is corrupted or otherwise invalid.
    ///
    /// - Parameter decoder: The decoder to read data from.
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        while !container.isAtEnd {
            if let v = try? container.decode(Element.self) {
                array.append(WeakContainer<Element>(v))
            }
        }
    }
}
