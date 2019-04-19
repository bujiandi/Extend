//
//  JSON+Encoder.swift
//  TestJSON
//
//  Created by 李招利 on 2019/1/9.
//  Copyright © 2019 jwl. All rights reserved.
//

import Foundation

extension JSON {
    
    open class Encoder {
        
        /// The strategy to use in encoding dates. Defaults to `.deferredToDate`.
        open var dateEncodingStrategy: JSONEncoder.DateEncodingStrategy = DefaultStrategy.date
        
        /// The strategy to use in encoding binary data. Defaults to `.base64`.
        open var dataEncodingStrategy: JSONEncoder.DataEncodingStrategy = DefaultStrategy.data
        
        /// The strategy to use in encoding non-conforming numbers. Defaults to `.throw`.
        open var nonConformingFloatEncodingStrategy: JSONEncoder.NonConformingFloatEncodingStrategy = DefaultStrategy.nonConformingFloat
        
        /// The strategy to use for encoding keys. Defaults to `.useDefaultKeys`.
        open var keyEncodingStrategy: JSONEncoder.KeyEncodingStrategy = DefaultStrategy.key
        
        /// Contextual user-provided information for use during encoding.
        open var userInfo: [CodingUserInfoKey : Any] = DefaultStrategy.userInfo
        
        /// JSON default encoding strategy
        public struct DefaultStrategy {
            
            /// The strategy to use in encoding dates. Defaults to `.deferredToDate`.
            public static var date: JSONEncoder.DateEncodingStrategy = .millisecondsSince1970
            
            /// The strategy to use in encoding binary data. Defaults to `.base64`.
            public static var data: JSONEncoder.DataEncodingStrategy = .base64
            
            /// The strategy to use in encoding non-conforming numbers. Defaults to `.throw`.
            public static var nonConformingFloat: JSONEncoder.NonConformingFloatEncodingStrategy = .throw
            
            /// The strategy to use for encoding keys. Defaults to `.useDefaultKeys`.
            public static var key: JSONEncoder.KeyEncodingStrategy = .useDefaultKeys
            
            /// Contextual user-provided information for use during encoding.
            public static var userInfo: [CodingUserInfoKey : Any] = [:]
        }
        
        /// Options set on the top-level encoder to pass down the encoding hierarchy.
        fileprivate struct _Options {
            let dateEncodingStrategy: JSONEncoder.DateEncodingStrategy
            let dataEncodingStrategy: JSONEncoder.DataEncodingStrategy
            let nonConformingFloatEncodingStrategy: JSONEncoder.NonConformingFloatEncodingStrategy
            let keyEncodingStrategy: JSONEncoder.KeyEncodingStrategy
            let userInfo: [CodingUserInfoKey : Any]
        }
        
        /// The options set on the top-level encoder.
        fileprivate var options: _Options {
            return _Options(dateEncodingStrategy: dateEncodingStrategy,
                            dataEncodingStrategy: dataEncodingStrategy,
                            nonConformingFloatEncodingStrategy: nonConformingFloatEncodingStrategy,
                            keyEncodingStrategy: keyEncodingStrategy,
                            userInfo: userInfo)
        }
        
        // MARK: - Constructing a JSON Encoder
        
        /// Initializes `self` with default strategies.
        public init() {}
        
        // MARK: - Encoding Values
        
        /// Encodes the given top-level value and returns its JSON representation.
        ///
        /// - parameter value: The value to encode.
        /// - returns: A new `Data` value containing the encoded JSON data.
        /// - throws: `EncodingError.invalidValue` if a non-conforming floating-point value is encountered during encoding, and the encoding strategy is `.throw`.
        /// - throws: An error if any value throws an error during encoding.
        open func encode<T : Encodable>(_ value: T) throws -> JSON {
            let encoder = _JSONEncoder(options: options)
            
            guard let topLevel = try encoder.box_(value) else {
                throw EncodingError.invalidValue(value, EncodingError.Context(codingPath: [], debugDescription: "Top-level \(T.self) did not encode any values."))
            }
           
            switch topLevel {
            case .null:
                throw EncodingError.invalidValue(value, EncodingError.Context(codingPath: [], debugDescription: "Top-level \(T.self) encoded as null JSON fragment."))
            case .number:
                throw EncodingError.invalidValue(value, EncodingError.Context(codingPath: [], debugDescription: "Top-level \(T.self) encoded as number JSON fragment."))
            case .string:
                throw EncodingError.invalidValue(value, EncodingError.Context(codingPath: [], debugDescription: "Top-level \(T.self) encoded as string JSON fragment."))
            default: break
            }
            
            return topLevel
            
        }
        
    }
    
}


// MARK: - _JSONEncoder

fileprivate class _JSONEncoder : Encoder {
    // MARK: Properties
    
    /// The encoder's storage.
    fileprivate var storage: _JSONEncodingStorage
    
    /// Options set on the top-level encoder.
    fileprivate let options: JSON.Encoder._Options
    
    /// The path to the current point in encoding.
    public var codingPath: [CodingKey]
    
    /// Contextual user-provided information for use during encoding.
    public var userInfo: [CodingUserInfoKey : Any] {
        return options.userInfo
    }
    
    // MARK: - Initialization
    
    /// Initializes `self` with the given top-level encoder options.
    fileprivate init(options: JSON.Encoder._Options, codingPath: [CodingKey] = []) {
        self.options = options
        self.storage = _JSONEncodingStorage()
        self.codingPath = codingPath
    }
    
    /// Returns whether a new element can be encoded at this coding path.
    ///
    /// `true` if an element has not yet been encoded at this coding path; `false` otherwise.
    fileprivate var canEncodeNewValue: Bool {
        // Every time a new value gets encoded, the key it's encoded for is pushed onto the coding path (even if it's a nil key from an unkeyed container).
        // At the same time, every time a container is requested, a new value gets pushed onto the storage stack.
        // If there are more values on the storage stack than on the coding path, it means the value is requesting more than one container, which violates the precondition.
        //
        // This means that anytime something that can request a new container goes onto the stack, we MUST push a key onto the coding path.
        // Things which will not request containers do not need to have the coding path extended for them (but it doesn't matter if it is, because they will not reach here).
        
        return storage.count == codingPath.count
    }
    
    // MARK: - Encoder Methods
    public func container<Key>(keyedBy: Key.Type) -> KeyedEncodingContainer<Key> {
        // If an existing keyed container was already requested, return that one.
        let topContainer: JSON.Object
        if canEncodeNewValue {
            // We haven't yet pushed a container at this level; do so here.
            topContainer = storage.pushKeyedContainer()
        } else {
            guard case .object(let container)? = storage.containers.last else {
                preconditionFailure("Attempt to push new keyed encoding container when already previously encoded at this path.")
            }
            
            topContainer = container
        }
        
        let container = _JSONKeyedEncodingContainer<Key>(referencing: self, codingPath: self.codingPath, wrapping: topContainer)
        return KeyedEncodingContainer(container)
    }
    
    public func unkeyedContainer() -> UnkeyedEncodingContainer {
        // If an existing unkeyed container was already requested, return that one.
        let topContainer: JSON.Array
        if canEncodeNewValue {
            // We haven't yet pushed a container at this level; do so here.
            topContainer = storage.pushUnkeyedContainer()
        } else {
            guard case .array(let list)? = storage.containers.last else {
                preconditionFailure("Attempt to push new unkeyed encoding container when already previously encoded at this path.")
            }
            
            topContainer = list
        }
        
        return _JSONUnkeyedEncodingContainer(referencing: self, codingPath: codingPath, wrapping: topContainer)
    }
    
    public func singleValueContainer() -> SingleValueEncodingContainer {
        return self
    }
}

// MARK: - Encoding Storage and Containers

fileprivate struct _JSONEncodingStorage {
    // MARK: Properties
    
    /// The container stack.
    /// Elements may be any one of the JSON types (NSNull, NSNumber, NSString, NSArray, NSDictionary).
    private(set) fileprivate var containers: [JSON] = []
    
    // MARK: - Initialization
    
    /// Initializes `self` with no containers.
    fileprivate init() {}
    
    // MARK: - Modifying the Stack
    
    fileprivate var count: Int {
        return containers.count
    }
    
    fileprivate mutating func pushKeyedContainer() -> JSON.Object {
        let dictionary = JSON.Object()
        containers.append(.object(dictionary))
        return dictionary
    }
    
    fileprivate mutating func pushUnkeyedContainer() -> JSON.Array {
        let array = JSON.Array() //[JSON]()
        containers.append(.array(array))
        return array
    }
    
    fileprivate mutating func push(container: JSON) {
        containers.append(container)
    }
    
    fileprivate mutating func popContainer() -> JSON {
        precondition(!containers.isEmpty, "Empty container stack.")
        return containers.popLast()!
    }
}

// MARK: - Encoding Containers

fileprivate struct _JSONKeyedEncodingContainer<K : CodingKey> : KeyedEncodingContainerProtocol {
    typealias Key = K
    
    // MARK: Properties
    
    /// A reference to the encoder we're writing to.
    private let encoder: _JSONEncoder
    
    /// A reference to the container we're writing to.
    private let container: JSON.Object
    
    /// The path of coding keys taken to get to this point in encoding.
    private(set) public var codingPath: [CodingKey]
    
    // MARK: - Initialization
    
    /// Initializes `self` with the given references.
    fileprivate init(referencing encoder: _JSONEncoder, codingPath: [CodingKey], wrapping container: JSON.Object) {
        self.encoder = encoder
        self.codingPath = codingPath
        self.container = container
        
    }
    
    // MARK: - KeyedEncodingContainerProtocol Methods
    
    public mutating func encodeNil(forKey key: Key)               throws { container.append(value: JSON.null, for: key.stringValue) }
    public mutating func encode(_ value: Bool, forKey key: Key)   throws { container.append(value: encoder.box(value), for: key.stringValue) }
    public mutating func encode(_ value: Int, forKey key: Key)    throws { container.append(value: encoder.box(value), for: key.stringValue) }
    public mutating func encode(_ value: Int8, forKey key: Key)   throws { container.append(value: encoder.box(value), for: key.stringValue) }
    public mutating func encode(_ value: Int16, forKey key: Key)  throws { container.append(value: encoder.box(value), for: key.stringValue) }
    public mutating func encode(_ value: Int32, forKey key: Key)  throws { container.append(value: encoder.box(value), for: key.stringValue) }
    public mutating func encode(_ value: Int64, forKey key: Key)  throws { container.append(value: encoder.box(value), for: key.stringValue) }
    public mutating func encode(_ value: UInt, forKey key: Key)   throws { container.append(value: encoder.box(value), for: key.stringValue) }
    public mutating func encode(_ value: UInt8, forKey key: Key)  throws { container.append(value: encoder.box(value), for: key.stringValue) }
    public mutating func encode(_ value: UInt16, forKey key: Key) throws { container.append(value: encoder.box(value), for: key.stringValue) }
    public mutating func encode(_ value: UInt32, forKey key: Key) throws { container.append(value: encoder.box(value), for: key.stringValue) }
    public mutating func encode(_ value: UInt64, forKey key: Key) throws { container.append(value: encoder.box(value), for: key.stringValue) }
    public mutating func encode(_ value: String, forKey key: Key) throws { container.append(value: encoder.box(value), for: key.stringValue) }
    
    public mutating func encode(_ value: Float, forKey key: Key)  throws {
        // Since the float may be invalid and throw, the coding path needs to contain this key.
        encoder.codingPath.append(key)
        defer { encoder.codingPath.removeLast() }
        container.append(value: try encoder.box(value), for: key.stringValue)
    }
    
    public mutating func encode(_ value: Double, forKey key: Key) throws {
        // Since the double may be invalid and throw, the coding path needs to contain this key.
        encoder.codingPath.append(key)
        defer { encoder.codingPath.removeLast() }
        container.append(value: try encoder.box(value), for: key.stringValue)
    }
    
    public mutating func encode<T : Encodable>(_ value: T, forKey key: Key) throws {
        encoder.codingPath.append(key)
        defer { encoder.codingPath.removeLast() }
        container.append(value: try encoder.box(value), for: key.stringValue)
    }
    
    public mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: Key) -> KeyedEncodingContainer<NestedKey> {
        let dictionary = JSON.Object()
        self.container.append(value: JSON.object(dictionary), for: key.stringValue)
        
        codingPath.append(key)
        defer { codingPath.removeLast() }
        
        let container = _JSONKeyedEncodingContainer<NestedKey>(referencing: encoder, codingPath: codingPath, wrapping: dictionary)
        return KeyedEncodingContainer(container)
    }
    
    public mutating func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
        let array = JSON.Array()
        container.append(value: JSON.array(array), for: key.stringValue)
        
        self.codingPath.append(key)
        defer { self.codingPath.removeLast() }
        return _JSONUnkeyedEncodingContainer(referencing: encoder, codingPath: codingPath, wrapping: array)
    }
    
    public mutating func superEncoder() -> Encoder {
        return _JSONReferencingEncoder(referencing: encoder, at: _JSONKey.super, wrapping: container)
    }
    
    public mutating func superEncoder(forKey key: Key) -> Encoder {
        return _JSONReferencingEncoder(referencing: encoder, at: key, wrapping: container)
    }
}

fileprivate struct _JSONUnkeyedEncodingContainer : UnkeyedEncodingContainer {
    // MARK: Properties
    
    /// A reference to the encoder we're writing to.
    private let encoder: _JSONEncoder
    
    /// A reference to the container we're writing to.
    private var container: JSON.Array //[JSON]
    
    
    /// The path of coding keys taken to get to this point in encoding.
    private(set) public var codingPath: [CodingKey]
    
    /// The number of elements encoded into the container.
    public var count: Int {
        return container.count
    }
    
    // MARK: - Initialization
    
    /// Initializes `self` with the given references.
    fileprivate init(referencing encoder: _JSONEncoder, codingPath: [CodingKey], wrapping container: JSON.Array) {
        self.encoder = encoder
        self.codingPath = codingPath
        self.container = container
    }
    
    // MARK: - UnkeyedEncodingContainer Methods
    
    public mutating func encodeNil()             throws { container.append(JSON.null) }
    public mutating func encode(_ value: Bool)   throws { container.append(encoder.box(value)) }
    public mutating func encode(_ value: Int)    throws { container.append(encoder.box(value)) }
    public mutating func encode(_ value: Int8)   throws { container.append(encoder.box(value)) }
    public mutating func encode(_ value: Int16)  throws { container.append(encoder.box(value)) }
    public mutating func encode(_ value: Int32)  throws { container.append(encoder.box(value)) }
    public mutating func encode(_ value: Int64)  throws { container.append(encoder.box(value)) }
    public mutating func encode(_ value: UInt)   throws { container.append(encoder.box(value)) }
    public mutating func encode(_ value: UInt8)  throws { container.append(encoder.box(value)) }
    public mutating func encode(_ value: UInt16) throws { container.append(encoder.box(value)) }
    public mutating func encode(_ value: UInt32) throws { container.append(encoder.box(value)) }
    public mutating func encode(_ value: UInt64) throws { container.append(encoder.box(value)) }
    public mutating func encode(_ value: String) throws { container.append(encoder.box(value)) }
    
    public mutating func encode(_ value: Float)  throws {
        // Since the float may be invalid and throw, the coding path needs to contain this key.
        encoder.codingPath.append(_JSONKey(index: count))
        defer { encoder.codingPath.removeLast() }
        container.append(try encoder.box(value))
    }
    
    public mutating func encode(_ value: Double) throws {
        // Since the double may be invalid and throw, the coding path needs to contain this key.
        encoder.codingPath.append(_JSONKey(index: count))
        defer { encoder.codingPath.removeLast() }
        container.append(try encoder.box(value))
    }
    
    public mutating func encode<T : Encodable>(_ value: T) throws {
        encoder.codingPath.append(_JSONKey(index: count))
        defer { encoder.codingPath.removeLast() }
        container.append(try encoder.box(value))
    }
    
    public mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> {
        codingPath.append(_JSONKey(index: count))
        defer { codingPath.removeLast() }
        
        let dictionary = JSON.Object()
        self.container.append(JSON.object(dictionary))
        
        let container = _JSONKeyedEncodingContainer<NestedKey>(referencing: encoder, codingPath: codingPath, wrapping: dictionary)
        return KeyedEncodingContainer(container)
    }
    
    public mutating func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        self.codingPath.append(_JSONKey(index: count))
        defer { self.codingPath.removeLast() }
        
        let array = JSON.Array() //NSMutableArray()
        
        self.container.append(JSON.array(array))
        return _JSONUnkeyedEncodingContainer(referencing: encoder, codingPath: codingPath, wrapping: array)
    }
    
    public mutating func superEncoder() -> Encoder {
        return _JSONReferencingEncoder(referencing: encoder, at: container.count, wrapping: container)
    }
}

extension _JSONEncoder : SingleValueEncodingContainer {
    // MARK: - SingleValueEncodingContainer Methods
    
    fileprivate func assertCanEncodeNewValue() {
        precondition(canEncodeNewValue, "Attempt to encode value through single value container when previously value already encoded.")
    }
    
    public func encodeNil() throws {
        assertCanEncodeNewValue()
        self.storage.push(container: JSON.null)
    }
    
    public func encode(_ value: Bool) throws {
        assertCanEncodeNewValue()
        storage.push(container: box(value))
    }
    
    public func encode(_ value: Int) throws {
        assertCanEncodeNewValue()
        storage.push(container: box(value))
    }
    
    public func encode(_ value: Int8) throws {
        assertCanEncodeNewValue()
        storage.push(container: box(value))
    }
    
    public func encode(_ value: Int16) throws {
        assertCanEncodeNewValue()
        storage.push(container: box(value))
    }
    
    public func encode(_ value: Int32) throws {
        assertCanEncodeNewValue()
        storage.push(container: box(value))
    }
    
    public func encode(_ value: Int64) throws {
        assertCanEncodeNewValue()
        storage.push(container: box(value))
    }
    
    public func encode(_ value: UInt) throws {
        assertCanEncodeNewValue()
        storage.push(container: box(value))
    }
    
    public func encode(_ value: UInt8) throws {
        assertCanEncodeNewValue()
        storage.push(container: box(value))
    }
    
    public func encode(_ value: UInt16) throws {
        assertCanEncodeNewValue()
        storage.push(container: box(value))
    }
    
    public func encode(_ value: UInt32) throws {
        assertCanEncodeNewValue()
        storage.push(container: box(value))
    }
    
    public func encode(_ value: UInt64) throws {
        assertCanEncodeNewValue()
        storage.push(container: box(value))
    }
    
    public func encode(_ value: String) throws {
        assertCanEncodeNewValue()
        storage.push(container: box(value))
    }
    
    public func encode(_ value: Float) throws {
        assertCanEncodeNewValue()
        try storage.push(container: box(value))
    }
    
    public func encode(_ value: Double) throws {
        assertCanEncodeNewValue()
        try storage.push(container: box(value))
    }
    
    public func encode<T : Encodable>(_ value: T) throws {
        assertCanEncodeNewValue()
        try storage.push(container: box(value))
    }
}

// MARK: - Concrete Value Representations

extension _JSONEncoder {
    /// Returns the given value boxed in a container appropriate for pushing onto the container stack.
    fileprivate func box(_ value: Bool)   -> JSON { return JSON.bool(value) }
    fileprivate func box(_ value: Int)    -> JSON { return JSON.int(value) }
    fileprivate func box(_ value: Int8)   -> JSON { return JSON.int8(value) }
    fileprivate func box(_ value: Int16)  -> JSON { return JSON.int16(value) }
    fileprivate func box(_ value: Int32)  -> JSON { return JSON.int32(value) }
    fileprivate func box(_ value: Int64)  -> JSON { return JSON.int64(value) }
    fileprivate func box(_ value: UInt)   -> JSON { return JSON.uint(value) }
    fileprivate func box(_ value: UInt8)  -> JSON { return JSON.uint8(value) }
    fileprivate func box(_ value: UInt16) -> JSON { return JSON.uint16(value) }
    fileprivate func box(_ value: UInt32) -> JSON { return JSON.uint32(value) }
    fileprivate func box(_ value: UInt64) -> JSON { return JSON.uint64(value) }
    fileprivate func box(_ value: String) -> JSON { return JSON.string(value) }
    
    fileprivate func box(_ float: Float) throws -> JSON {
        guard !float.isInfinite && !float.isNaN else {
            guard case let .convertToString(positiveInfinity: posInfString,
                                            negativeInfinity: negInfString,
                                            nan: nanString) = options.nonConformingFloatEncodingStrategy else {
                                                throw EncodingError._invalidFloatingPointValue(float, at: codingPath)
            }
            
            if float == Float.infinity {
                return JSON.string(posInfString)
            } else if float == -Float.infinity {
                return JSON.string(negInfString)
            } else {
                return JSON.string(nanString)
            }
        }
        
        return JSON.float(float)
    }
    
    fileprivate func box(_ double: Double) throws -> JSON {
        guard !double.isInfinite && !double.isNaN else {
            guard case let .convertToString(positiveInfinity: posInfString,
                                            negativeInfinity: negInfString,
                                            nan: nanString) = self.options.nonConformingFloatEncodingStrategy else {
                                                throw EncodingError._invalidFloatingPointValue(double, at: codingPath)
            }
            
            if double == Double.infinity {
                return JSON.string(posInfString)
            } else if double == -Double.infinity {
                return JSON.string(negInfString)
            } else {
                return JSON.string(nanString)
            }
        }
        
        return JSON.double(double)
    }
    
    fileprivate func box(_ date: Date) throws -> JSON {
        switch options.dateEncodingStrategy {
        case .secondsSince1970:
            return JSON.double(date.timeIntervalSince1970)
            
        case .millisecondsSince1970:
            return JSON.double(1000.0 * date.timeIntervalSince1970)
            
        case .iso8601:
            if #available(macOS 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *) {
                return JSON.string(_iso8601Formatter.string(from: date))
            } else {
                fatalError("ISO8601DateFormatter is unavailable on this platform.")
            }
            
        case .formatted(let formatter):
            return JSON.string(formatter.string(from: date))
            
        case .custom(let closure):
            let depth = storage.count
            do {
                try closure(date, self)
            } catch {
                // If the value pushed a container before throwing, pop it back off to restore state.
                if storage.count > depth {
                    let _ = storage.popContainer()
                }
                throw error
            }
            
            guard storage.count > depth else {
                // The closure didn't encode anything. Return the default keyed container.
                return JSON.object([:])
            }
            
            // We can pop because the closure encoded something.
            return storage.popContainer()
        case .deferredToDate:
            fallthrough
        @unknown default:
            // Must be called with a surrounding with(pushedKey:) call.
            // Dates encode as single-value objects; this can't both throw and push a container, so no need to catch the error.
            try date.encode(to: self)
            return storage.popContainer()
        }
    }
    
    fileprivate func box(_ data: Data) throws -> JSON {
        switch self.options.dataEncodingStrategy {
            
        case .base64:
            return JSON.string(data.base64EncodedString()) //NSString(string: data.base64EncodedString())
            
        case .custom(let closure):
            let depth = storage.count
            do {
                try closure(data, self)
            } catch {
                // If the value pushed a container before throwing, pop it back off to restore state.
                if storage.count > depth {
                    let _ = storage.popContainer()
                }
                throw error
            }
            
            guard storage.count > depth else {
                // The closure didn't encode anything. Return the default keyed container.
                return JSON.object([:])
            }
            // We can pop because the closure encoded something.
            return storage.popContainer()
        case .deferredToData:
            fallthrough
        @unknown default:
            // Must be called with a surrounding with(pushedKey:) call.
            let depth = storage.count
            do {
                try data.encode(to: self)
            } catch {
                // If the value pushed a container before throwing, pop it back off to restore state.
                // This shouldn't be possible for Data (which encodes as an array of bytes), but it can't hurt to catch a failure.
                if storage.count > depth {
                    let _ = storage.popContainer()
                }
                throw error
            }
            return storage.popContainer()
        }
    }
    
    fileprivate func box<T : Encodable>(_ value: T) throws -> JSON {
        return try box_(value) ?? JSON.object([:])
    }
    
    // This method is called "box_" instead of "box" to disambiguate it from the overloads. Because the return type here is different from all of the "box" overloads (and is more general), any "box" calls in here would call back into "box" recursively instead of calling the appropriate overload, which is not what we want.
    fileprivate func box_<T : Encodable>(_ value: T) throws -> JSON? {
        #if DEPLOYMENT_RUNTIME_SWIFT
        if T.self == JSON.self {
            return (value as! JSON)
        } else if T.self == JSON.Number.self {
            return JSON.number(value as! JSON.Number)
        } else if T.self == JSON.Object.self {
            return JSON.object(value as! JSON.Object)
        } else if T.self == [String:JSON].self {
            let object = JSON.Object()
            object._map = value as! [String:JSON]
            object._keys = object._map.keys.map { $0 }
            return JSON.object(object)
        } else if T.self == JSON.Array.self {
            return JSON.array(value as! JSON.Array)
        } else if T.self == [JSON].self {
            return JSON.array(JSON.Array(value as! [JSON]))
        } else if T.self == NSNull.self {
            return JSON.null
        } else if T.self == Date.self {
            // Respect Date encoding strategy
            return try self.box((value as! Date))
        } else if T.self == Data.self {
            // Respect Data encoding strategy
            return try self.box((value as! Data))
        } else if T.self == URL.self {
            // Encode URLs as single strings.
            return self.box((value as! URL).absoluteString)
        } else if T.self == Decimal.self {
            // On Darwin we get ((value as! Decimal) as NSDecimalNumber) since JSONSerialization can consume NSDecimalNumber values.
            // FIXME: Attempt to create a Decimal value if JSONSerialization on Linux consume one.
            let doubleValue = (value as! Decimal).doubleValue
            return try self.box(doubleValue)
        }
        
        #else
        if T.self == JSON.self {
            return (value as! JSON)
        } else if T.self == JSON.Number.self {
            return JSON.number(value as! JSON.Number)
        } else if T.self == JSON.Object.self {
            return JSON.object(value as! JSON.Object)
        } else if T.self == [String:JSON].self {
            let object = JSON.Object()
            object._map = value as! [String:JSON]
            object._keys = object._map.keys.map { $0 }
            return JSON.object(object)
        } else if T.self == JSON.Array.self {
            return JSON.array(value as! JSON.Array)
        } else if T.self == [JSON].self {
            return JSON.array(JSON.Array(value as! [JSON]))
        } else if T.self == NSNull.self {
            return JSON.null
        } else if T.self == Date.self || T.self == NSDate.self {
            // Respect Date encoding strategy
            return try box((value as! Date))
        } else if T.self == Data.self || T.self == NSData.self {
            // Respect Data encoding strategy
            return try box((value as! Data))
        } else if T.self == URL.self || T.self == NSURL.self {
            // Encode URLs as single strings.
            return box((value as! URL).absoluteString)
        } else if T.self == Decimal.self {
            // On Darwin we get ((value as! Decimal) as NSDecimalNumber) since JSONSerialization can consume NSDecimalNumber values.
            // FIXME: Attempt to create a Decimal value if JSONSerialization on Linux consume one.
            let doubleValue = (value as! Decimal).doubleValue
            return try box(doubleValue)
        }
        #endif
        
        // The value should request a container from the _JSONEncoder.
        let depth = storage.count
        do {
            try value.encode(to: self)
        } catch {
            // If the value pushed a container before throwing, pop it back off to restore state.
            if storage.count > depth {
                let _ = storage.popContainer()
            }
            throw error
        }
        
        // The top container should be a new container.
        guard storage.count > depth else {
            return nil
        }
        
        return storage.popContainer()
    }
}

// MARK: - _JSONReferencingEncoder

/// _JSONReferencingEncoder is a special subclass of _JSONEncoder which has its own storage, but references the contents of a different encoder.
/// It's used in superEncoder(), which returns a new encoder for encoding a superclass -- the lifetime of the encoder should not escape the scope it's created in, but it doesn't necessarily know when it's done being used (to write to the original container).
fileprivate class _JSONReferencingEncoder : _JSONEncoder {
    // MARK: Reference types.
    
    /// The type of container we're referencing.
    private enum Reference {
        /// Referencing a specific index in an array container.
        case array(JSON.Array, Int)
        
        /// Referencing a specific key in a dictionary container.
        case dictionary(JSON.Object, String)
    }
    
    // MARK: - Properties
    
    /// The encoder we're referencing.
    fileprivate let encoder: _JSONEncoder
    
    /// The container reference itself.
    private let reference: Reference
    
    // MARK: - Initialization
    
    /// Initializes `self` by referencing the given array container in the given encoder.
    fileprivate init(referencing encoder: _JSONEncoder, at index: Int, wrapping array: JSON.Array) {
        self.encoder = encoder
        self.reference = .array(array, index)
        super.init(options: encoder.options, codingPath: encoder.codingPath)
        
        self.codingPath.append(_JSONKey(index: index))
    }
    
    /// Initializes `self` by referencing the given dictionary container in the given encoder.
    fileprivate init(referencing encoder: _JSONEncoder, at key: CodingKey, wrapping dictionary: JSON.Object) {
        self.encoder = encoder
        self.reference = .dictionary(dictionary, key.stringValue)
        super.init(options: encoder.options, codingPath: encoder.codingPath)
        
        self.codingPath.append(key)
    }
    
    // MARK: - Coding Path Operations
    
    fileprivate override var canEncodeNewValue: Bool {
        // With a regular encoder, the storage and coding path grow together.
        // A referencing encoder, however, inherits its parents coding path, as well as the key it was created for.
        // We have to take this into account.
        return storage.count == codingPath.count - encoder.codingPath.count - 1
    }
    
    // MARK: - Deinitialization
    
    // Finalizes `self` by writing the contents of our storage to the referenced encoder's storage.
    deinit {
        let value: JSON
        switch storage.count {
        case 0: value = JSON.object([:])
        case 1: value = storage.popContainer()
        default: fatalError("Referencing encoder deallocated with multiple containers on stack.")
        }
        
        switch reference {
        case .array(var array, let index):
            array.insert(value, at: index)
            
        case .dictionary(let dictionary, let key):
//            dictionary[NSString(string: key)] = value
            dictionary.append(value: value, for: key)
        }
    }
}



//===----------------------------------------------------------------------===//
// Shared ISO8601 Date Formatter
//===----------------------------------------------------------------------===//

// NOTE: This value is implicitly lazy and _must_ be lazy. We're compiled against the latest SDK (w/ ISO8601DateFormatter), but linked against whichever Foundation the user has. ISO8601DateFormatter might not exist, so we better not hit this code path on an older OS.
@available(macOS 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *)
fileprivate var _iso8601Formatter: ISO8601DateFormatter = {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = .withInternetDateTime
    return formatter
}()

//===----------------------------------------------------------------------===//
// Error Utilities
//===----------------------------------------------------------------------===//

extension EncodingError {
    /// Returns a `.invalidValue` error describing the given invalid floating-point value.
    ///
    ///
    /// - parameter value: The value that was invalid to encode.
    /// - parameter path: The path of `CodingKey`s taken to encode this value.
    /// - returns: An `EncodingError` with the appropriate path and debug description.
    fileprivate static func _invalidFloatingPointValue<T : FloatingPoint>(_ value: T, at codingPath: [CodingKey]) -> EncodingError {
        let valueDescription: String
        if value == T.infinity {
            valueDescription = "\(T.self).infinity"
        } else if value == -T.infinity {
            valueDescription = "-\(T.self).infinity"
        } else {
            valueDescription = "\(T.self).nan"
        }
        
        let debugDescription = "Unable to encode \(valueDescription) directly in JSON. Use JSONEncoder.NonConformingFloatEncodingStrategy.convertToString to specify how the value should be encoded."
        return .invalidValue(value, EncodingError.Context(codingPath: codingPath, debugDescription: debugDescription))
    }
}


extension JSON {
    
    public init(_ any:Any?) {
        self = JSON.from(any)
    }
    
    public init(_ date:Date) {
        self = JSON.from(date: date)
    }
    
    public init<T : Decodable>(_ value:T?) {
        self = JSON.from(decodable: value)
    }
    
    internal static func from(data:Data) -> JSON {
        switch Encoder.DefaultStrategy.data {
        case .custom(let closure):
            let options = Encoder._Options(dateEncodingStrategy: Encoder.DefaultStrategy.date,
                                           dataEncodingStrategy: Encoder.DefaultStrategy.data,
                                           nonConformingFloatEncodingStrategy: Encoder.DefaultStrategy.nonConformingFloat,
                                           keyEncodingStrategy: Encoder.DefaultStrategy.key,
                                           userInfo: Encoder.DefaultStrategy.userInfo)
            let encoder = _JSONEncoder(options: options)
            try! closure(data, encoder)
            return encoder.storage.containers.last!
        case .base64:
            return JSON.string(data.base64EncodedString()) //NSString(string: data.base64EncodedString())
        case .deferredToData:
            fallthrough
        @unknown default:
            let options = Encoder._Options(dateEncodingStrategy: Encoder.DefaultStrategy.date,
                                           dataEncodingStrategy: Encoder.DefaultStrategy.data,
                                           nonConformingFloatEncodingStrategy: Encoder.DefaultStrategy.nonConformingFloat,
                                           keyEncodingStrategy: Encoder.DefaultStrategy.key,
                                           userInfo: Encoder.DefaultStrategy.userInfo)
            let encoder = _JSONEncoder(options: options)
            try! data.encode(to: encoder)
            return encoder.storage.containers.last!
        }
    }
    
    internal static func from(date:Date) -> JSON {
        switch Encoder.DefaultStrategy.date {
        case .millisecondsSince1970:
            return JSON.number(Number(date.timeIntervalSince1970 * 1000))
        case .secondsSince1970:
            return JSON.number(Number(date.timeIntervalSince1970))
        case .iso8601:
            if #available(macOS 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *) {
                return JSON.string(_iso8601Formatter.string(from: date))
            } else {
                fatalError("ISO8601DateFormatter is unavailable on this platform.")
            }
        case .formatted(let formatter):
            return JSON.string(formatter.string(from: date))
        case .custom(let closure):
            let options = Encoder._Options(dateEncodingStrategy: Encoder.DefaultStrategy.date,
                                           dataEncodingStrategy: Encoder.DefaultStrategy.data,
                                           nonConformingFloatEncodingStrategy: Encoder.DefaultStrategy.nonConformingFloat,
                                           keyEncodingStrategy: Encoder.DefaultStrategy.key,
                                           userInfo: Encoder.DefaultStrategy.userInfo)
            let encoder = _JSONEncoder(options: options)
            try! closure(date, encoder)
            return encoder.storage.containers.last!
        case .deferredToDate:
            fallthrough
        @unknown default:
            let options = Encoder._Options(dateEncodingStrategy: Encoder.DefaultStrategy.date,
                                           dataEncodingStrategy: Encoder.DefaultStrategy.data,
                                           nonConformingFloatEncodingStrategy: Encoder.DefaultStrategy.nonConformingFloat,
                                           keyEncodingStrategy: Encoder.DefaultStrategy.key,
                                           userInfo: Encoder.DefaultStrategy.userInfo)
            let encoder = _JSONEncoder(options: options)
            try! date.encode(to: encoder)
            return encoder.storage.containers.last!
        }
    }
    
    internal static func from<T : Decodable>(decodable value:T?) -> JSON {
        #if DEPLOYMENT_RUNTIME_SWIFT
        if value == nil {
            return JSON.null
        } else if T.self == String.self {
            return JSON.string(value as! String)
        } else if T.self == Int.self {
            return JSON.number(Number(value as! Int))
        } else if T.self == UInt.self {
            return JSON.number(Number(value as! UInt))
        } else if T.self == Double.self {
            return JSON.number(Number(value as! Double))
        } else if T.self == Float.self {
            return JSON.number(Number(value as! Float))
        } else if T.self == Object.self {
            return JSON.object(value as! Object)
        } else if T.self == Array.self {
            return JSON.array(value as! Array)
        } else if T.self == Number.self {
            return JSON.number(value as! Number)
        } else if T.self == [JSON].self {
            return JSON.array(Array(value as! [JSON]))
        } else if T.self == Object.self {
            return JSON.object(value as! Object)
        } else if T.self == [String:JSON].self {
            let object = Object()
            object._map = value as! [String:JSON]
            object._keys = object._map.keys.map { $0 }
            return JSON.object(object)
        } else if T.self == NSNull.self {
            return JSON.null
        } else if T.self == Int8.self {
            return JSON.number(Number(value as! Int8))
        } else if T.self == Int16.self {
            return JSON.number(Number(value as! Int16))
        } else if T.self == Int32.self {
            return JSON.number(Number(value as! Int32))
        } else if T.self == Int64.self {
            return JSON.number(Number(value as! Int64))
        } else if T.self == UInt8.self {
            return JSON.number(Number(value as! UInt8))
        } else if T.self == UInt16.self {
            return JSON.number(Number(value as! UInt16))
        } else if T.self == UInt32.self {
            return JSON.number(Number(value as! UInt32))
        } else if T.self == UInt64.self {
            return JSON.number(Number(value as! UInt64))
        } else if T.self == Decimal.self {
            return JSON.number(Number(value as! Decimal))
        } else if T.self == Date.self {
            return from(value as! Date)
        } else if T.self == URL.self {
            return JSON.string((value as! URL).absoluteString)
        } else if T.self == Data.self {
            return from(value as! Data)
        } else {
            return JSON.from(value)
        }
        #else
        if value == nil {
            return JSON.null
        } else if T.self == String.self || T.self == NSString.self {
            return JSON.string(value as! String)
        } else if T.self == Int.self {
            return JSON.number(Number(value as! Int))
        } else if T.self == UInt.self {
            return JSON.number(Number(value as! UInt))
        } else if T.self == Double.self {
            return JSON.number(Number(value as! Double))
        } else if T.self == Float.self {
            return JSON.number(Number(value as! Float))
        } else if T.self == Object.self {
            return JSON.object(value as! Object)
        } else if T.self == Array.self {
            return JSON.array(value as! Array)
        } else if T.self == Number.self {
            return JSON.number(value as! Number)
        } else if T.self == [JSON].self {
            return JSON.array(Array(value as! [JSON]))
        } else if T.self == Object.self {
            return JSON.object(value as! Object)
        } else if T.self == [String:JSON].self {
            let object = Object()
            object._map = value as! [String:JSON]
            object._keys = object._map.keys.map { $0 }
            return JSON.object(object)
        } else if T.self == NSArray.self || T.self == NSMutableArray.self {
            return JSON.array(Array((value as! NSArray).map({ JSON.from($0) })))
        } else if T.self == NSDictionary.self || T.self == NSMutableDictionary.self {
            return JSON.object(Object(value as! NSDictionary))
        } else if T.self == NSNull.self {
            return JSON.null
        } else if T.self == Int8.self {
            return JSON.number(Number(value as! Int8))
        } else if T.self == Int16.self {
            return JSON.number(Number(value as! Int16))
        } else if T.self == Int32.self {
            return JSON.number(Number(value as! Int32))
        } else if T.self == Int64.self {
            return JSON.number(Number(value as! Int64))
        } else if T.self == UInt8.self {
            return JSON.number(Number(value as! UInt8))
        } else if T.self == UInt16.self {
            return JSON.number(Number(value as! UInt16))
        } else if T.self == UInt32.self {
            return JSON.number(Number(value as! UInt32))
        } else if T.self == UInt64.self {
            return JSON.number(Number(value as! UInt64))
        } else if T.self == Decimal.self || T.self == NSDecimalNumber.self {
            return JSON.number(Number(value as! Decimal))
        } else if T.self == Date.self || T.self == NSDate.self {
            return from(value as! Date)
        } else if T.self == URL.self || T.self == NSURL.self {
            return JSON.string((value as! URL).absoluteString)
        } else if T.self == Data.self || T.self == NSData.self {
            return from(value as! Data)
        } else {
            return JSON.from(value)
        }
        #endif
    }
    
    internal static func from(_ any:Any?) -> JSON {
        switch any {
        case (let v as String):
            return .string(v)
        case (_ as NSNull):
            return .null
        case (let v as Object):
            return .object(v)
        case (let v as Array):
            return .array(v)
        case (let v as Number):
            return .number(v)
        case (let v as JSON) where any is JSON:
            return v
        case (let v as NSDictionary):
            return .object(JSON.Object(v))
        case (let v as NSArray):
            return .array(Array(v.map({ JSON.from($0) })))
        case (let v as NSNumber):
            return .number(Number(v))
        case (let v as Bool):
            return .bool(v)
        case (_ as NSNull):
            return .null
        case (let v as Double):
            return .number(Number(v))
        case (let v as Float):
            return .number(Number(v))
        case (let v as Int64):
            return .number(Number(v))
        case (let v as UInt64):
            return .number(Number(v))
        case (let v as Int):
            return .number(Number(v))
        case (let v as UInt):
            return .number(Number(v))
        case (let v as Int32):
            return .number(Number(v))
        case (let v as UInt32):
            return .number(Number(v))
        case (let v as Int16):
            return .number(Number(v))
        case (let v as UInt16):
            return .number(Number(v))
        case (let v as Int8):
            return .number(Number(v))
        case (let v as UInt8):
            return .number(Number(v))
        default:
//            if any is JSON {
//                return any as! JSON
//            }
            let mirror = Mirror(reflecting: any as Any)
            if  mirror.displayStyle == .optional,
                mirror.children.count == 0 {
                return .null
            }
        }
        return .error(.typeMismatch("unknow json value:\(String(describing: any))"), ignore: [])
    }
    
}
