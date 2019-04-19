//
//  StringError.swift
//  Extend
//
//  Created by bujiandi on 2019/4/18.
//

public struct StringError : Error {
    
    public var rawValue:String
    
    public init(_ description:String) {
        rawValue = description
    }
    
    public var localizedDescription: String {
        return rawValue
    }
}

extension StringError : RawRepresentable {
    
    public typealias RawValue = String
    
    public init(rawValue description: String) {
        rawValue = description
    }
}

extension StringError : ExpressibleByStringLiteral {
    
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
    public init(stringLiteral description: String) {
        rawValue = description
    }
}

extension StringError : Comparable {
    
    /// Returns a Boolean value indicating whether the value of the first
    /// argument is less than that of the second argument.
    ///
    /// This function is the only requirement of the `Comparable` protocol. The
    /// remainder of the relational operator functions are implemented by the
    /// standard library for any type that conforms to `Comparable`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    @inlinable public static func < (lhs: StringError, rhs: StringError) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
    
}

extension StringError : Equatable {
    
    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    @inlinable public static func == (lhs: StringError, rhs: StringError) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
}

extension StringError : Hashable {
    
    /// Hashes the essential components of this value by feeding them into the
    /// given hasher.
    ///
    /// - Parameter hasher: The hasher to use when combining the components
    ///   of this instance.
    public func hash(into hasher: inout Hasher) {
        hasher.combine(rawValue)
    }
}

/// Default implementations of core requirements
extension StringError {
    
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
        return rawValue.isEmpty
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
    @inlinable public var first: Character? {
        return rawValue.first
    }
    
    /// A value less than or equal to the number of elements in the collection.
    ///
    /// - Complexity: O(1) if the collection conforms to
    ///   `RandomAccessCollection`; otherwise, O(*n*), where *n* is the length
    ///   of the collection.
    @inlinable public var underestimatedCount: Int {
        return rawValue.underestimatedCount
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
        return rawValue.count
    }
}

/// Default implementation for forward collections.
extension StringError {
    
    /// Replaces the given index with its successor.
    ///
    /// - Parameter i: A valid index of the collection. `i` must be less than
    ///   `endIndex`.
    @inlinable public func formIndex(after i: inout String.Index) {
        rawValue.formIndex(after: &i)
    }
    
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
    @inlinable public func formIndex(_ i: inout String.Index, offsetBy distance: Int) {
        rawValue.formIndex(&i, offsetBy: distance)
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
    @inlinable public func formIndex(_ i: inout String.Index, offsetBy distance: Int, limitedBy limit: String.Index) -> Bool {
        return rawValue.formIndex(&i, offsetBy: distance, limitedBy: limit)
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
    @inlinable public func randomElement<T>(using generator: inout T) -> Character? where T : RandomNumberGenerator {
        return rawValue.randomElement(using: &generator)
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
    @inlinable public func randomElement() -> Character? {
        return rawValue.randomElement()
    }
}

/// Default implementation for bidirectional collections.
extension StringError {
    
    @inlinable public func formIndex(before i: inout String.Index) {
        rawValue.formIndex(before: &i)
    }
}

extension StringError : TextOutputStreamable {
    
    /// Writes the string into the given output stream.
    ///
    /// - Parameter target: An output stream.
    @inlinable public func write<Target>(to target: inout Target) where Target : TextOutputStream {
        rawValue.write(to: &target)
    }
}


extension StringError : CustomDebugStringConvertible {
    
    /// A representation of the string that is suitable for debugging.
    public var debugDescription: String {
        return rawValue.debugDescription
    }
}

extension StringError : CustomStringConvertible {
    
    /// The value of this string.
    ///
    /// Using this property directly is discouraged. Instead, use simple
    /// assignment to create a new constant or variable equal to this string.
    @inlinable public var description: String {
        return rawValue.description
    }
}

extension StringError : BidirectionalCollection {
    
    /// A type that represents the number of steps between two `String.Index`
    /// values, where one value is reachable from the other.
    ///
    /// In Swift, *reachability* refers to the ability to produce one value from
    /// the other through zero or more applications of `index(after:)`.
    public typealias IndexDistance = Int
    
    /// A sequence that represents a contiguous subrange of the collection's
    /// elements.
    ///
    /// This associated type appears as a requirement in the `Sequence`
    /// protocol, but it is restated here with stricter constraints. In a
    /// collection, the subsequence should also conform to `Collection`.
    public typealias SubSequence = Substring
    
    /// A type representing the sequence's elements.
    public typealias Element = Character
    
    /// The position of the first character in a nonempty string.
    ///
    /// In an empty string, `startIndex` is equal to `endIndex`.
    @inlinable public var startIndex: String.Index {
        return rawValue.startIndex
    }
    
    /// A string's "past the end" position---that is, the position one greater
    /// than the last valid subscript argument.
    ///
    /// In an empty string, `endIndex` is equal to `startIndex`.
    @inlinable public var endIndex: String.Index {
        return rawValue.endIndex
    }
    
    /// Returns the position immediately after the given index.
    ///
    /// - Parameter i: A valid index of the collection. `i` must be less than
    ///   `endIndex`.
    /// - Returns: The index value immediately after `i`.
    @inlinable public func index(after i: String.Index) -> String.Index {
        return rawValue.index(after: i)
    }
    
    /// Returns the position immediately before the given index.
    ///
    /// - Parameter i: A valid index of the collection. `i` must be greater than
    ///   `startIndex`.
    /// - Returns: The index value immediately before `i`.
    @inlinable public func index(before i: String.Index) -> String.Index {
        return rawValue.index(before: i)
    }
    
    /// Returns an index that is the specified distance from the given index.
    ///
    /// The following example obtains an index advanced four positions from a
    /// string's starting index and then prints the character at that position.
    ///
    ///     let s = "Swift"
    ///     let i = s.index(s.startIndex, offsetBy: 4)
    ///     print(s[i])
    ///     // Prints "t"
    ///
    /// The value passed as `n` must not offset `i` beyond the bounds of the
    /// collection.
    ///
    /// - Parameters:
    ///   - i: A valid index of the collection.
    ///   - n: The distance to offset `i`.
    /// - Returns: An index offset by `n` from the index `i`. If `n` is positive,
    ///   this is the same value as the result of `n` calls to `index(after:)`.
    ///   If `n` is negative, this is the same value as the result of `-n` calls
    ///   to `index(before:)`.
    ///
    /// - Complexity: O(*n*), where *n* is the absolute value of `n`.
    @inlinable public func index(_ i: String.Index, offsetBy n: String.IndexDistance) -> String.Index {
        return rawValue.index(i, offsetBy: n)
    }
    
    /// Returns an index that is the specified distance from the given index,
    /// unless that distance is beyond a given limiting index.
    ///
    /// The following example obtains an index advanced four positions from a
    /// string's starting index and then prints the character at that position.
    /// The operation doesn't require going beyond the limiting `s.endIndex`
    /// value, so it succeeds.
    ///
    ///     let s = "Swift"
    ///     if let i = s.index(s.startIndex, offsetBy: 4, limitedBy: s.endIndex) {
    ///         print(s[i])
    ///     }
    ///     // Prints "t"
    ///
    /// The next example attempts to retrieve an index six positions from
    /// `s.startIndex` but fails, because that distance is beyond the index
    /// passed as `limit`.
    ///
    ///     let j = s.index(s.startIndex, offsetBy: 6, limitedBy: s.endIndex)
    ///     print(j)
    ///     // Prints "nil"
    ///
    /// The value passed as `n` must not offset `i` beyond the bounds of the
    /// collection, unless the index passed as `limit` prevents offsetting
    /// beyond those bounds.
    ///
    /// - Parameters:
    ///   - i: A valid index of the collection.
    ///   - n: The distance to offset `i`.
    ///   - limit: A valid index of the collection to use as a limit. If `n > 0`,
    ///     a limit that is less than `i` has no effect. Likewise, if `n < 0`, a
    ///     limit that is greater than `i` has no effect.
    /// - Returns: An index offset by `n` from the index `i`, unless that index
    ///   would be beyond `limit` in the direction of movement. In that case,
    ///   the method returns `nil`.
    ///
    /// - Complexity: O(*n*), where *n* is the absolute value of `n`.
    @inlinable public func index(_ i: String.Index, offsetBy n: String.IndexDistance, limitedBy limit: String.Index) -> String.Index? {
        return rawValue.index(i, offsetBy: n, limitedBy: limit)
    }
    
    /// Returns the distance between two indices.
    ///
    /// - Parameters:
    ///   - start: A valid index of the collection.
    ///   - end: Another valid index of the collection. If `end` is equal to
    ///     `start`, the result is zero.
    /// - Returns: The distance between `start` and `end`.
    ///
    /// - Complexity: O(*n*), where *n* is the resulting distance.
    @inlinable public func distance(from start: String.Index, to end: String.Index) -> String.IndexDistance {
        return rawValue.distance(from: start, to: end)
    }
    
    /// Accesses the character at the given position.
    ///
    /// You can use the same indices for subscripting a string and its substring.
    /// For example, this code finds the first letter after the first space:
    ///
    ///     let str = "Greetings, friend! How are you?"
    ///     let firstSpace = str.firstIndex(of: " ") ?? str.endIndex
    ///     let substr = str[firstSpace...]
    ///     if let nextCapital = substr.firstIndex(where: { $0 >= "A" && $0 <= "Z" }) {
    ///         print("Capital after a space: \(str[nextCapital])")
    ///     }
    ///     // Prints "Capital after a space: H"
    ///
    /// - Parameter i: A valid index of the string. `i` must be less than the
    ///   string's end index.
    @inlinable public subscript(i: String.Index) -> Character {
        return rawValue[i]
    }
}

extension StringError : TextOutputStream {
    
    /// Appends the given string to this string.
    ///
    /// - Parameter other: A string to append.
    public mutating func write(_ other: String) {
        rawValue.write(other)
    }
}

extension StringError : CustomReflectable {
    
    /// A mirror that reflects the `String` instance.
    public var customMirror: Mirror {
        return Mirror(reflecting: self)
    }
}

extension StringError : Codable {
    
    /// Creates a new instance by decoding from the given decoder.
    ///
    /// This initializer throws an error if reading from the decoder fails, or
    /// if the data read is corrupted or otherwise invalid.
    ///
    /// - Parameter decoder: The decoder to read data from.
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        rawValue = try container.decode(String.self)
    }
    
    /// Encodes this value into the given encoder.
    ///
    /// This function throws an error if any values are invalid for the given
    /// encoder's format.
    ///
    /// - Parameter encoder: The encoder to write data to.
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}



extension StringError : StringProtocol {
    
    public typealias UTF8View = String.UTF8View
    
    public typealias UTF16View = String.UTF16View
    
    public typealias UnicodeScalarView = String.UnicodeScalarView
    
    public var utf8: String.UTF8View {
        return rawValue.utf8
    }
    
    public var utf16: String.UTF16View {
        return rawValue.utf16
    }
    
    public var unicodeScalars: String.UnicodeScalarView {
        return rawValue.unicodeScalars
    }
    
    public init<C, Encoding>(decoding codeUnits: C, as sourceEncoding: Encoding.Type) where C : Collection, Encoding : _UnicodeEncoding, C.Element == Encoding.CodeUnit {
        rawValue = String(decoding: codeUnits, as: sourceEncoding)
    }
    
    public init(cString nullTerminatedUTF8: UnsafePointer<CChar>) {
        rawValue = String(cString: nullTerminatedUTF8)
    }
    
    public init<Encoding>(decodingCString nullTerminatedCodeUnits: UnsafePointer<Encoding.CodeUnit>, as sourceEncoding: Encoding.Type) where Encoding : _UnicodeEncoding {
        rawValue = String(decodingCString: nullTerminatedCodeUnits, as: sourceEncoding)
    }
    
    public func withCString<Result>(_ body: (UnsafePointer<CChar>) throws -> Result) rethrows -> Result {
        return try rawValue.withCString(body)
    }
    
    public func withCString<Result, Encoding>(encodedAs targetEncoding: Encoding.Type, _ body: (UnsafePointer<Encoding.CodeUnit>) throws -> Result) rethrows -> Result where Encoding : _UnicodeEncoding {
        return try rawValue.withCString(encodedAs: targetEncoding, body)
    }
    
    public func lowercased() -> String {
        return rawValue.lowercased()
    }
    public func uppercased() -> String {
        return rawValue.uppercased()
    }
    
}

extension StringError : RangeReplaceableCollection {
    
    public init() {
        rawValue = ""
    }
    
    /// Creates a string representing the given character repeated the specified
    /// number of times.
    ///
    /// For example, use this initializer to create a string with ten `"0"`
    /// characters in a row.
    ///
    ///     let zeroes = String(repeating: "0" as Character, count: 10)
    ///     print(zeroes)
    ///     // Prints "0000000000"
    ///
    /// - Parameters:
    ///   - repeatedValue: The character to repeat.
    ///   - count: The number of times to repeat `repeatedValue` in the
    ///     resulting string.
    public init(repeating repeatedValue: Character, count: Int) {
        rawValue = String(repeating: repeatedValue, count: count)
    }
    
    /// Creates a new string containing the characters in the given sequence.
    ///
    /// You can use this initializer to create a new string from the result of
    /// one or more collection operations on a string's characters. For example:
    ///
    ///     let str = "The rain in Spain stays mainly in the plain."
    ///
    ///     let vowels: Set<Character> = ["a", "e", "i", "o", "u"]
    ///     let disemvoweled = String(str.lazy.filter { !vowels.contains($0) })
    ///
    ///     print(disemvoweled)
    ///     // Prints "Th rn n Spn stys mnly n th pln."
    ///
    /// - Parameter other: A string instance or another sequence of
    ///   characters.
    public init<S>(_ other: S) where S : LosslessStringConvertible, S : Sequence, S.Element == Character {
        rawValue = String(other)
    }
    
    /// Creates a new string containing the characters in the given sequence.
    ///
    /// You can use this initializer to create a new string from the result of
    /// one or more collection operations on a string's characters. For example:
    ///
    ///     let str = "The rain in Spain stays mainly in the plain."
    ///
    ///     let vowels: Set<Character> = ["a", "e", "i", "o", "u"]
    ///     let disemvoweled = String(str.lazy.filter { !vowels.contains($0) })
    ///
    ///     print(disemvoweled)
    ///     // Prints "Th rn n Spn stys mnly n th pln."
    ///
    /// - Parameter characters: A string instance or another sequence of
    ///   characters.
    public init<S>(_ characters: S) where S : Sequence, S.Element == Character {
        rawValue = String(characters)
    }
    
    /// Reserves enough space in the string's underlying storage to store the
    /// specified number of ASCII characters.
    ///
    /// Because each character in a string can require more than a single ASCII
    /// character's worth of storage, additional allocation may be necessary
    /// when adding characters to a string after a call to
    /// `reserveCapacity(_:)`.
    ///
    /// - Parameter n: The minimum number of ASCII character's worth of storage
    ///   to allocate.
    ///
    /// - Complexity: O(*n*)
    public mutating func reserveCapacity(_ n: Int) {
        rawValue.reserveCapacity(n)
    }
    
    /// Appends the given string to this string.
    ///
    /// The following example builds a customized greeting by using the
    /// `append(_:)` method:
    ///
    ///     var greeting = "Hello, "
    ///     if let name = getUserName() {
    ///         greeting.append(name)
    ///     } else {
    ///         greeting.append("friend")
    ///     }
    ///     print(greeting)
    ///     // Prints "Hello, friend"
    ///
    /// - Parameter other: Another string.
    public mutating func append(_ other: String) {
        rawValue.append(other)
    }
    
    /// Appends the given character to the string.
    ///
    /// The following example adds an emoji globe to the end of a string.
    ///
    ///     var globe = "Globe "
    ///     globe.append("🌍")
    ///     print(globe)
    ///     // Prints "Globe 🌍"
    ///
    /// - Parameter c: The character to append to the string.
    public mutating func append(_ c: Character) {
        rawValue.append(c)
    }
    
    public mutating func append(contentsOf newElements: String) {
        rawValue.append(contentsOf: newElements)
    }
    
    public mutating func append(contentsOf newElements: Substring) {
        rawValue.append(contentsOf: newElements)
    }
    
    /// Appends the characters in the given sequence to the string.
    ///
    /// - Parameter newElements: A sequence of characters.
    public mutating func append<S>(contentsOf newElements: S) where S : Sequence, S.Element == Character {
        rawValue.append(contentsOf: newElements)
    }
    
    /// Replaces the text within the specified bounds with the given characters.
    ///
    /// Calling this method invalidates any existing indices for use with this
    /// string.
    ///
    /// - Parameters:
    ///   - bounds: The range of text to replace. The bounds of the range must be
    ///     valid indices of the string.
    ///   - newElements: The new characters to add to the string.
    ///
    /// - Complexity: O(*m*), where *m* is the combined length of the string and
    ///   `newElements`. If the call to `replaceSubrange(_:with:)` simply
    ///   removes text at the end of the string, the complexity is O(*n*), where
    ///   *n* is equal to `bounds.count`.
    public mutating func replaceSubrange<C>(_ bounds: Range<String.Index>, with newElements: C) where C : Collection, C.Element == Character {
        rawValue.replaceSubrange(bounds, with: newElements)
    }
    
    /// Inserts a new character at the specified position.
    ///
    /// Calling this method invalidates any existing indices for use with this
    /// string.
    ///
    /// - Parameters:
    ///   - newElement: The new character to insert into the string.
    ///   - i: A valid index of the string. If `i` is equal to the string's end
    ///     index, this methods appends `newElement` to the string.
    ///
    /// - Complexity: O(*n*), where *n* is the length of the string.
    public mutating func insert(_ newElement: Character, at i: String.Index) {
        rawValue.insert(newElement, at: i)
    }
    
    /// Inserts a collection of characters at the specified position.
    ///
    /// Calling this method invalidates any existing indices for use with this
    /// string.
    ///
    /// - Parameters:
    ///   - newElements: A collection of `Character` elements to insert into the
    ///     string.
    ///   - i: A valid index of the string. If `i` is equal to the string's end
    ///     index, this methods appends the contents of `newElements` to the
    ///     string.
    ///
    /// - Complexity: O(*n*), where *n* is the combined length of the string and
    ///   `newElements`.
    public mutating func insert<S>(contentsOf newElements: S, at i: String.Index) where S : Collection, S.Element == Character {
        rawValue.insert(contentsOf: newElements, at: i)
    }
    
    /// Removes and returns the character at the specified position.
    ///
    /// All the elements following `i` are moved to close the gap. This example
    /// removes the hyphen from the middle of a string.
    ///
    ///     var nonempty = "non-empty"
    ///     if let i = nonempty.firstIndex(of: "-") {
    ///         nonempty.remove(at: i)
    ///     }
    ///     print(nonempty)
    ///     // Prints "nonempty"
    ///
    /// Calling this method invalidates any existing indices for use with this
    /// string.
    ///
    /// - Parameter i: The position of the character to remove. `i` must be a
    ///   valid index of the string that is not equal to the string's end index.
    /// - Returns: The character that was removed.
    public mutating func remove(at i: String.Index) -> Character {
        return rawValue.remove(at: i)
    }
    
    /// Removes the characters in the given range.
    ///
    /// Calling this method invalidates any existing indices for use with this
    /// string.
    ///
    /// - Parameter bounds: The range of the elements to remove. The upper and
    ///   lower bounds of `bounds` must be valid indices of the string and not
    ///   equal to the string's end index.
    /// - Parameter bounds: The range of the elements to remove. The upper and
    ///   lower bounds of `bounds` must be valid indices of the string.
    public mutating func removeSubrange(_ bounds: Range<String.Index>) {
        rawValue.removeSubrange(bounds)
    }
    
    /// Replaces this string with the empty string.
    ///
    /// Calling this method invalidates any existing indices for use with this
    /// string.
    ///
    /// - Parameter keepCapacity: Pass `true` to prevent the release of the
    ///   string's allocated storage. Retaining the storage can be a useful
    ///   optimization when you're planning to grow the string again. The
    ///   default value is `false`.
    public mutating func removeAll(keepingCapacity keepCapacity: Bool = false) {
        rawValue.removeAll(keepingCapacity: keepCapacity)
    }
}
