//
//  JSON+Decoder.swift
//  TestJSON
//
//  Created by 李招利 on 2019/1/7.
//  Copyright © 2019 jwl. All rights reserved.
//

import Foundation


extension JSON {
    
    /// Decodes a top-level value of the given type from the given JSON representation.
    ///
    /// - parameter type: The type of the value to decode.
    /// - returns: A value of the requested type.
    /// - throws: `DecodingError.dataCorrupted` if values requested from the payload are corrupted, or if the given data is not valid JSON.
    /// - throws: An error if any value throws an error during decoding.
    public func decode<T : Decodable>(_ type: T.Type) throws -> T {
        return try Decoder().decode(type, from: self)
    }
}

extension JSON {
    
    public class Decoder {
        
        /// The strategy to use in decoding dates. Defaults to `.deferredToDate`.
        open var dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = DefaultStrategy.date
        
        /// The strategy to use in decoding binary data. Defaults to `.base64`.
        open var dataDecodingStrategy: JSONDecoder.DataDecodingStrategy = DefaultStrategy.data
        
        /// The strategy to use in decoding non-conforming numbers. Defaults to `.throw`.
        open var nonConformingFloatDecodingStrategy: JSONDecoder.NonConformingFloatDecodingStrategy = DefaultStrategy.nonConformingFloat
        
        /// The strategy to use for decoding keys. Defaults to `.useDefaultKeys`.
        open var keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = DefaultStrategy.key
        
        /// The strategy to number overflow. Defaults to `.ignore`.
        open var numberOverflowDecodingStrategy: JSONDecoder.NumberOverflowDecodingStrategy = DefaultStrategy.numberOverflow
        
        /// The strategy to url if lose host relative base. Defaults to `.throw`.
        open var urlDecodingStrategy: JSONDecoder.URLDecodingStrategy = DefaultStrategy.url
        
        /// The strategy to array if null. Defaults to `.ignore`.
        open var arrayNullDecodingStrategy: JSONDecoder.ArrayNullDecodingStrategy = DefaultStrategy.arrayNull
        
        /// Contextual user-provided information for use during decoding.
        open var userInfo: [CodingUserInfoKey : Any] = DefaultStrategy.userInfo
        
        /// JSON default decoding strategy
        public struct DefaultStrategy {
            
            /// The strategy to use in decoding dates. Defaults to `.deferredToDate`.
            public static var date: JSONDecoder.DateDecodingStrategy = .millisecondsSince1970
            
            /// The strategy to use in decoding binary data. Defaults to `.base64`.
            public static var data: JSONDecoder.DataDecodingStrategy = .base64
            
            /// The strategy to use for decoding keys. Defaults to `.useDefaultKeys`.
            public static var key: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys
            #if DEBUG
            /// The strategy to use in decoding non-conforming numbers. Defaults to `.throw`.
            public static var nonConformingFloat: JSONDecoder.NonConformingFloatDecodingStrategy = .throw
            
            /// The strategy to number overflow. Defaults to `.ignore`.
            public static var numberOverflow: JSONDecoder.NumberOverflowDecodingStrategy = .throw
            #else
            /// The strategy to use in decoding non-conforming numbers. Defaults to `.throw`.
            public static var nonConformingFloat: JSONDecoder.NonConformingFloatDecodingStrategy = .convertFromString(positiveInfinity: "∞", negativeInfinity: "-∞", nan: "NaN")
            
            /// The strategy to number overflow. Defaults to `.ignore`.
            public static var numberOverflow: JSONDecoder.NumberOverflowDecodingStrategy = .ignore
            #endif
            /// The strategy to url if lose host relative base. Defaults to `.throw`.
            public static var url: JSONDecoder.URLDecodingStrategy = .throw
            
            /// The strategy to array if null. Defaults to `.ignore`.
            public static var arrayNull: JSONDecoder.ArrayNullDecodingStrategy = .ignore
            
            /// Contextual user-provided information for use during decoding.
            public static var userInfo: [CodingUserInfoKey : Any] = [:]
        }

        /// Options set on the top-level encoder to pass down the decoding hierarchy.
        fileprivate struct _Options {
            let dateDecodingStrategy: JSONDecoder.DateDecodingStrategy
            let dataDecodingStrategy: JSONDecoder.DataDecodingStrategy
            let nonConformingFloatDecodingStrategy: JSONDecoder.NonConformingFloatDecodingStrategy
            let keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy
            let numberOverflowDecodingStrategy: JSONDecoder.NumberOverflowDecodingStrategy
            let urlDecodingStrategy: JSONDecoder.URLDecodingStrategy
            let arrayNullDecodingStrategy: JSONDecoder.ArrayNullDecodingStrategy
            let userInfo: [CodingUserInfoKey : Any]
        }
        
        /// The options set on the top-level decoder.
        fileprivate var options: _Options {
            return _Options(dateDecodingStrategy: dateDecodingStrategy,
                            dataDecodingStrategy: dataDecodingStrategy,
                            nonConformingFloatDecodingStrategy: nonConformingFloatDecodingStrategy,
                            keyDecodingStrategy: keyDecodingStrategy,
                            numberOverflowDecodingStrategy: numberOverflowDecodingStrategy,
                            urlDecodingStrategy: urlDecodingStrategy,
                            arrayNullDecodingStrategy: arrayNullDecodingStrategy,
                            userInfo: userInfo)
        }

        
        // MARK: - Constructing a JSON Decoder
        
        /// Initializes `self` with default strategies.
        public init() {}
        
        // MARK: - Decoding Values
        
        /// Decodes a top-level value of the given type from the given JSON representation.
        ///
        /// - parameter type: The type of the value to decode.
        /// - parameter data: The data to decode from.
        /// - returns: A value of the requested type.
        /// - throws: `DecodingError.dataCorrupted` if values requested from the payload are corrupted, or if the given data is not valid JSON.
        /// - throws: An error if any value throws an error during decoding.
        open func decode<T : Decodable>(_ type: T.Type, from data: Data) throws -> T {
            let topLevel: JSON
            do {
                topLevel = try data.parseJSON(options: [.allowFragments])
            } catch {
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "The given data was not valid JSON.", underlyingError: error))
            }
            return try decode(type, from: topLevel)
        }
        
        /// Decodes a top-level value of the given type from the given JSON representation.
        ///
        /// - parameter type: The type of the value to decode.
        /// - parameter json: The JSON to decode from.
        /// - returns: A value of the requested type.
        /// - throws: `DecodingError.dataCorrupted` if values requested from the payload are corrupted, or if the given data is not valid JSON.
        /// - throws: An error if any value throws an error during decoding.
        open func decode<T : Decodable>(_ type: T.Type, from json: JSON) throws -> T {
            
            let decoder = _JSONDecoder(referencing: json, options: options)
            guard let value = try decoder.unbox(json, as: type) else {
                throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: [], debugDescription: "The given data did not contain a top-level value."))
            }
            
            return value
        }
    }
    
}

extension DecodingError {
    
    fileprivate static func _typeMismatch<T>(at codingPath:[CodingKey], expectation type:T.Type, reality json:JSON) -> DecodingError {
        let context = DecodingError.Context(codingPath: codingPath, debugDescription: "\(type) can't from \(json.debugDescription)")
        return DecodingError.typeMismatch(type, context)
    }
}

// MARK: - _JSONDecoder

fileprivate class _JSONDecoder : Decoder {
    // MARK: Properties
    
    /// The decoder's storage.
    fileprivate var storage: _JSONDecodingStorage
    
    /// Options set on the top-level decoder.
    fileprivate let options: JSON.Decoder._Options
    
    /// The path to the current point in encoding.
    fileprivate(set) public var codingPath: [CodingKey]
    
    /// Contextual user-provided information for use during encoding.
    public var userInfo: [CodingUserInfoKey : Any] {
        return options.userInfo
    }
    
    // MARK: - Initialization
    
    /// Initializes `self` with the given top-level container and options.
    fileprivate init(referencing container: JSON, at codingPath: [CodingKey] = [], options: JSON.Decoder._Options) {
        self.storage = _JSONDecodingStorage()
        self.storage.push(container: container)
        self.codingPath = codingPath
        self.options = options
    }
    
    // MARK: - Decoder Methods
    
    public func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> {
        guard !storage.topContainer.isNull else {
            throw DecodingError.valueNotFound(KeyedDecodingContainer<Key>.self,
                                              DecodingError.Context(codingPath: codingPath,
                                                                    debugDescription: "Cannot get keyed decoding container -- found null value instead."))
        }
        
        // FIXME:
        guard case .object(let obj) = storage.topContainer else {
            throw DecodingError._typeMismatch(at: codingPath, expectation: JSON.Object.self, reality: storage.topContainer)
        }
        
        let container = _JSONKeyedDecodingContainer<Key>(referencing: self, wrapping: obj)
        return KeyedDecodingContainer(container)
    }
    
    public func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        let value = storage.topContainer
        switch value {
        case .null:
            switch options.arrayNullDecodingStrategy {
            case .ignore:
                return _JSONUnkeyedDecodingContainer(referencing: self, wrapping: [])
            case .throw: break
            }
            fallthrough
        case .error:
            throw DecodingError.valueNotFound(UnkeyedDecodingContainer.self,
                                              DecodingError.Context(codingPath: codingPath,
                                                                    debugDescription: "Cannot get unkeyed decoding container -- found null value instead."))
        case .array(let list):
            return _JSONUnkeyedDecodingContainer(referencing: self, wrapping: list)
        default:
            throw DecodingError._typeMismatch(at: codingPath, expectation: JSON.Array.self, reality: value)
        }
//        if value.isNull {
//            value = JSON.array([])
//        }
//
//        guard !value.isError else {
//            throw DecodingError.valueNotFound(UnkeyedDecodingContainer.self,
//                                              DecodingError.Context(codingPath: codingPath,
//                                                                    debugDescription: "Cannot get unkeyed decoding container -- found null value instead."))
//        }
//
//        guard case .array(let list) = value else {
//            throw DecodingError._typeMismatch(at: codingPath, expectation: JSON.Array.self, reality: value)
//        }
//
//        return _JSONUnkeyedDecodingContainer(referencing: self, wrapping: list)
    }
    
    public func singleValueContainer() throws -> SingleValueDecodingContainer {
        return self
    }
}

extension _JSONDecoder {
    
    fileprivate static func _convertFromSnakeCase(_ stringKey: String) -> String {
        guard !stringKey.isEmpty else { return stringKey }
        
        // Find the first non-underscore character
        guard let firstNonUnderscore = stringKey.firstIndex(where: { $0 != "_" }) else {
            // Reached the end without finding an _
            return stringKey
        }
        
        // Find the last non-underscore character
        var lastNonUnderscore = stringKey.index(before: stringKey.endIndex)
        while lastNonUnderscore > firstNonUnderscore && stringKey[lastNonUnderscore] == "_" {
            stringKey.formIndex(before: &lastNonUnderscore)
        }
        
        let keyRange = firstNonUnderscore...lastNonUnderscore
        let leadingUnderscoreRange = stringKey.startIndex..<firstNonUnderscore
        let trailingUnderscoreRange = stringKey.index(after: lastNonUnderscore)..<stringKey.endIndex
        
        let components = stringKey[keyRange].split(separator: "_")
        let joinedString : String
        if components.count == 1 {
            // No underscores in key, leave the word as is - maybe already camel cased
            joinedString = String(stringKey[keyRange])
        } else {
            joinedString = ([components[0].lowercased()] + components[1...].map { $0.capitalized }).joined()
        }
        
        // Do a cheap isEmpty check before creating and appending potentially empty strings
        let result : String
        if (leadingUnderscoreRange.isEmpty && trailingUnderscoreRange.isEmpty) {
            result = joinedString
        } else if (!leadingUnderscoreRange.isEmpty && !trailingUnderscoreRange.isEmpty) {
            // Both leading and trailing underscores
            result = String(stringKey[leadingUnderscoreRange]) + joinedString + String(stringKey[trailingUnderscoreRange])
        } else if (!leadingUnderscoreRange.isEmpty) {
            // Just leading
            result = String(stringKey[leadingUnderscoreRange]) + joinedString
        } else {
            // Just trailing
            result = joinedString + String(stringKey[trailingUnderscoreRange])
        }
        return result
    }
    
}


// MARK: - Decoding Storage

fileprivate struct _JSONDecodingStorage {
    // MARK: Properties
    
    /// The container stack.
    /// Elements may be any one of the JSON types (NSNull, NSNumber, String, Array, [String : Any]).
    private(set) fileprivate var containers: JSON.Array = []
    
    // MARK: - Initialization
    
    /// Initializes `self` with no containers.
    fileprivate init() {}
    
    // MARK: - Modifying the Stack
    
    fileprivate var count: Int {
        return self.containers.count
    }
    
    fileprivate var topContainer: JSON {
        precondition(!self.containers.isEmpty, "Empty container stack.")
        return self.containers.last!
    }
    
    fileprivate mutating func push(container: JSON) {
        self.containers.append(container)
    }
    
    fileprivate mutating func popContainer() {
        precondition(!self.containers.isEmpty, "Empty container stack.")
        self.containers.removeLast()
    }
}


// MARK: Decoding Containers

fileprivate struct _JSONKeyedDecodingContainer<K : CodingKey> : KeyedDecodingContainerProtocol {
    typealias Key = K
    
    // MARK: Properties
    
    /// A reference to the decoder we're reading from.
    private let decoder: _JSONDecoder
    
    /// A reference to the container we're reading from.
    private let container: JSON.Object
    
    private let convertDict: [String: JSON]
    
    private let _contains:(Key) -> Bool
    
    private let _jsonValue:(String) -> JSON?
    
    /// The path of coding keys taken to get to this point in decoding.
    private(set) public var codingPath: [CodingKey]
    
    // MARK: - Initialization
    
    /// Initializes `self` by referencing the given decoder and container.
    fileprivate init(referencing decoder: _JSONDecoder, wrapping container: JSON.Object) {
        self.decoder = decoder
        self.container = container
        switch decoder.options.keyDecodingStrategy {
        case .convertFromSnakeCase:
            // Convert the snake case keys in the container to camel case.
            // If we hit a duplicate key after conversion, then we'll use the first one we saw. Effectively an undefined behavior with JSON dictionaries.
            let dict = Dictionary(container.map {
                key, value in (_JSONDecoder._convertFromSnakeCase(key), value)
            }, uniquingKeysWith: { (first, _) in first })
            self.convertDict = dict
            self._contains = { dict[$0.stringValue] != nil || container._keys.contains($0.stringValue) }
            self._jsonValue = { dict[$0] ?? container._map[$0] }
        case .custom(let converter):
            let dict = Dictionary(container.map {
                key, value in (converter(decoder.codingPath + [_JSONKey(stringValue: key, intValue: nil)]).stringValue, value)
            }, uniquingKeysWith: { (first, _) in first })
            self.convertDict = dict
            self._contains = { dict[$0.stringValue] != nil || container._keys.contains($0.stringValue) }
            self._jsonValue = { dict[$0] ?? container._map[$0] }
        case .useDefaultKeys:
            fallthrough
        @unknown default:
            self.convertDict = [:]
            self._contains = { container._keys.contains($0.stringValue) }
            self._jsonValue = { container._map[$0] }
        }
        self.codingPath = decoder.codingPath
    }
    
    // MARK: - KeyedDecodingContainerProtocol Methods
    
    public var allKeys: [Key] {
        return container._keys.compactMap { Key(stringValue: $0) }
    }
    
    public func contains(_ key: Key) -> Bool {
        return _contains(key)
    }
    
    private func _errorDescription(of key: CodingKey) -> String {
        switch decoder.options.keyDecodingStrategy {
        case .convertFromSnakeCase:
            // In this case we can attempt to recover the original value by reversing the transform
            let original = key.stringValue
            let converted = _JSONDecoder._convertFromSnakeCase(original)
            if converted == original {
                return "\(key) (\"\(original)\")"
            } else {
                return "\(key) (\"\(original)\"), converted to \(converted)"
            }
        default:
            // Otherwise, just report the converted string
            return "\(key) (\"\(key.stringValue)\")"
        }
    }
    
    public func decodeNil(forKey key: Key) throws -> Bool {
        let entry = _jsonValue(key.stringValue) ?? JSON.null
//        guard let entry = self.container[key.stringValue] else {
//            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "No value associated with key \(_errorDescription(of: key))."))
//        }
        
        return entry.isNull
    }
    
    public func decode(_ type: Bool.Type, forKey key: Key) throws -> Bool {
        guard let entry = _jsonValue(key.stringValue) else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "No value associated with key \(_errorDescription(of: key))."))
        }
        
        decoder.codingPath.append(key)
        defer { decoder.codingPath.removeLast() }
        
        guard let value = try decoder.unbox(entry, as: Bool.self) else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Expected \(type) value but found null instead."))
        }
        
        return value
    }
    
    public func decode(_ type: Int.Type, forKey key: Key) throws -> Int {
        guard let entry = _jsonValue(key.stringValue) else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "No value associated with key \(_errorDescription(of: key))."))
        }
        
        decoder.codingPath.append(key)
        defer { decoder.codingPath.removeLast() }
        
        guard let value = try decoder.unbox(entry, as: Int.self) else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Expected \(type) value but found null instead."))
        }
        
        return value
    }
    
    public func decode(_ type: Int8.Type, forKey key: Key) throws -> Int8 {
        guard let entry = _jsonValue(key.stringValue) else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "No value associated with key \(_errorDescription(of: key))."))
        }
        
        decoder.codingPath.append(key)
        defer { decoder.codingPath.removeLast() }
        
        guard let value = try decoder.unbox(entry, as: Int8.self) else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Expected \(type) value but found null instead."))
        }
        
        return value
    }
    
    public func decode(_ type: Int16.Type, forKey key: Key) throws -> Int16 {
        guard let entry = _jsonValue(key.stringValue) else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "No value associated with key \(_errorDescription(of: key))."))
        }
        
        decoder.codingPath.append(key)
        defer { decoder.codingPath.removeLast() }
        
        guard let value = try decoder.unbox(entry, as: Int16.self) else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Expected \(type) value but found null instead."))
        }
        
        return value
    }
    
    public func decode(_ type: Int32.Type, forKey key: Key) throws -> Int32 {
        guard let entry = _jsonValue(key.stringValue) else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "No value associated with key \(_errorDescription(of: key))."))
        }
        
        decoder.codingPath.append(key)
        defer { decoder.codingPath.removeLast() }
        
        guard let value = try decoder.unbox(entry, as: Int32.self) else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Expected \(type) value but found null instead."))
        }
        
        return value
    }
    
    public func decode(_ type: Int64.Type, forKey key: Key) throws -> Int64 {
        guard let entry = _jsonValue(key.stringValue) else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "No value associated with key \(_errorDescription(of: key))."))
        }
        
        decoder.codingPath.append(key)
        defer { decoder.codingPath.removeLast() }
        
        guard let value = try decoder.unbox(entry, as: Int64.self) else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Expected \(type) value but found null instead."))
        }
        
        return value
    }
    
    public func decode(_ type: UInt.Type, forKey key: Key) throws -> UInt {
        guard let entry = _jsonValue(key.stringValue) else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "No value associated with key \(_errorDescription(of: key))."))
        }
        
        decoder.codingPath.append(key)
        defer { decoder.codingPath.removeLast() }
        
        guard let value = try decoder.unbox(entry, as: UInt.self) else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Expected \(type) value but found null instead."))
        }
        
        return value
    }
    
    public func decode(_ type: UInt8.Type, forKey key: Key) throws -> UInt8 {
        guard let entry = _jsonValue(key.stringValue) else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "No value associated with key \(_errorDescription(of: key))."))
        }
        
        decoder.codingPath.append(key)
        defer { decoder.codingPath.removeLast() }
        
        guard let value = try decoder.unbox(entry, as: UInt8.self) else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Expected \(type) value but found null instead."))
        }
        
        return value
    }
    
    public func decode(_ type: UInt16.Type, forKey key: Key) throws -> UInt16 {
        guard let entry = _jsonValue(key.stringValue) else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "No value associated with key \(_errorDescription(of: key))."))
        }
        
        decoder.codingPath.append(key)
        defer { decoder.codingPath.removeLast() }
        
        guard let value = try decoder.unbox(entry, as: UInt16.self) else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Expected \(type) value but found null instead."))
        }
        
        return value
    }
    
    public func decode(_ type: UInt32.Type, forKey key: Key) throws -> UInt32 {
        guard let entry = _jsonValue(key.stringValue) else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "No value associated with key \(_errorDescription(of: key))."))
        }
        
        decoder.codingPath.append(key)
        defer { decoder.codingPath.removeLast() }
        
        guard let value = try decoder.unbox(entry, as: UInt32.self) else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Expected \(type) value but found null instead."))
        }
        
        return value
    }
    
    public func decode(_ type: UInt64.Type, forKey key: Key) throws -> UInt64 {
        guard let entry = _jsonValue(key.stringValue) else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "No value associated with key \(_errorDescription(of: key))."))
        }
        
        decoder.codingPath.append(key)
        defer { decoder.codingPath.removeLast() }
        
        guard let value = try decoder.unbox(entry, as: UInt64.self) else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Expected \(type) value but found null instead."))
        }
        
        return value
    }
    
    public func decode(_ type: Float.Type, forKey key: Key) throws -> Float {
        guard let entry = _jsonValue(key.stringValue) else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "No value associated with key \(_errorDescription(of: key))."))
        }
        
        decoder.codingPath.append(key)
        defer { decoder.codingPath.removeLast() }
        
        guard let value = try decoder.unbox(entry, as: Float.self) else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Expected \(type) value but found null instead."))
        }
        
        return value
    }
    
    public func decode(_ type: Double.Type, forKey key: Key) throws -> Double {
        guard let entry = _jsonValue(key.stringValue) else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "No value associated with key \(_errorDescription(of: key))."))
        }
        
        decoder.codingPath.append(key)
        defer { decoder.codingPath.removeLast() }
        
        guard let value = try decoder.unbox(entry, as: Double.self) else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Expected \(type) value but found null instead."))
        }
        
        return value
    }
    
    public func decode(_ type: String.Type, forKey key: Key) throws -> String {
        guard let entry = _jsonValue(key.stringValue) else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "No value associated with key \(_errorDescription(of: key))."))
        }
        
        decoder.codingPath.append(key)
        defer { decoder.codingPath.removeLast() }
        
        guard let value = try decoder.unbox(entry, as: String.self) else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Expected \(type) value but found null instead."))
        }
        
        return value
    }
 
    
    public func decode<T : Decodable>(_ type: T.Type, forKey key: Key) throws -> T {

        decoder.codingPath.append(key)
        defer { decoder.codingPath.removeLast() }

        guard let value = try decoder.unbox(_jsonValue(key.stringValue) ?? .null, as: type) else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Expected \(type) value but found null instead."))
        }

        return value
    }
    
    public func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: Key) throws -> KeyedDecodingContainer<NestedKey> {
        decoder.codingPath.append(key)
        defer { decoder.codingPath.removeLast() }
        
        guard let value = _jsonValue(key.stringValue) else {
            throw DecodingError.keyNotFound(key,
                                            DecodingError.Context(codingPath: codingPath,
                                                                  debugDescription: "Cannot get \(KeyedDecodingContainer<NestedKey>.self) -- no value found for key \(_errorDescription(of: key))"))
        }
        
        guard case .object(let obj) = value else {
            throw DecodingError._typeMismatch(at: codingPath, expectation: JSON.Object.self, reality: value)
        }
        
        let container = _JSONKeyedDecodingContainer<NestedKey>(referencing: decoder, wrapping: obj)
        return KeyedDecodingContainer(container)
    }
    
    public func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
        decoder.codingPath.append(key)
        defer { decoder.codingPath.removeLast() }
        
//        guard let value = _jsonValue(key.stringValue) else {
//            throw DecodingError.keyNotFound(key,
//                                            DecodingError.Context(codingPath: codingPath,
//                                                                  debugDescription: "Cannot get UnkeyedDecodingContainer -- no value found for key \(_errorDescription(of: key))"))
//        }
        
        let value = _jsonValue(key.stringValue) ?? JSON.array([])
        
        guard !value.isError else {
            throw DecodingError.keyNotFound(key,
                                            DecodingError.Context(codingPath: codingPath,
                                                                  debugDescription: "Cannot get UnkeyedDecodingContainer -- no value found for key \(_errorDescription(of: key))"))
        }
        
        guard case .array(let list) = value else {
            throw DecodingError._typeMismatch(at: codingPath, expectation: JSON.Array.self, reality: value)
        }
        
        return _JSONUnkeyedDecodingContainer(referencing: decoder, wrapping: list)
    }
    
    private func _superDecoder(forKey key: CodingKey) throws -> Decoder {
        decoder.codingPath.append(key)
        defer { decoder.codingPath.removeLast() }
        
        let value: JSON = _jsonValue(key.stringValue) ?? JSON.null
        return _JSONDecoder(referencing: value, at: decoder.codingPath, options: decoder.options)
    }
    
    public func superDecoder() throws -> Decoder {
        return try _superDecoder(forKey: _JSONKey.super)
    }
    
    public func superDecoder(forKey key: Key) throws -> Decoder {
        return try _superDecoder(forKey: key)
    }
}

fileprivate struct _JSONUnkeyedDecodingContainer : UnkeyedDecodingContainer {
    // MARK: Properties
    
    /// A reference to the decoder we're reading from.
    private let decoder: _JSONDecoder
    
    /// A reference to the container we're reading from.
    private let container: JSON.Array
    
    /// The path of coding keys taken to get to this point in decoding.
    private(set) public var codingPath: [CodingKey]
    
    /// The index of the element we're about to decode.
    private(set) public var currentIndex: Int
    
    // MARK: - Initialization
    
    /// Initializes `self` by referencing the given decoder and container.
    fileprivate init(referencing decoder: _JSONDecoder, wrapping container: JSON.Array) {
        self.decoder = decoder
        self.container = container
        self.codingPath = decoder.codingPath
        self.currentIndex = 0
    }
    
    // MARK: - UnkeyedDecodingContainer Methods
    
    public var count: Int? {
        return container.count
    }
    
    public var isAtEnd: Bool {
        return currentIndex >= count!
    }
    
    public mutating func decodeNil() throws -> Bool {
        guard !isAtEnd else {
            throw DecodingError.valueNotFound(Any?.self, DecodingError.Context(codingPath: decoder.codingPath + [_JSONKey(index: currentIndex)], debugDescription: "Unkeyed container is at end."))
        }
        
        if container[currentIndex].isNullOrError {
            currentIndex += 1
            return true
        } else {
            return false
        }
    }
    
    public mutating func decode(_ type: Bool.Type) throws -> Bool {
        guard !isAtEnd else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: decoder.codingPath + [_JSONKey(index: currentIndex)], debugDescription: "Unkeyed container is at end."))
        }
        
        decoder.codingPath.append(_JSONKey(index: currentIndex))
        defer { decoder.codingPath.removeLast() }
        
        guard let decoded = try decoder.unbox(container[currentIndex], as: Bool.self) else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: decoder.codingPath + [_JSONKey(index: currentIndex)], debugDescription: "Expected \(type) but found null instead."))
        }
        
        currentIndex += 1
        return decoded
    }
    
    public mutating func decode(_ type: Int.Type) throws -> Int {
        guard !isAtEnd else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: decoder.codingPath + [_JSONKey(index: currentIndex)], debugDescription: "Unkeyed container is at end."))
        }
        
        decoder.codingPath.append(_JSONKey(index: currentIndex))
        defer { decoder.codingPath.removeLast() }
        
        guard let decoded = try decoder.unbox(container[currentIndex], as: Int.self) else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: decoder.codingPath + [_JSONKey(index: currentIndex)], debugDescription: "Expected \(type) but found null instead."))
        }
        
        currentIndex += 1
        return decoded
    }
    
    public mutating func decode(_ type: Int8.Type) throws -> Int8 {
        guard !isAtEnd else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: decoder.codingPath + [_JSONKey(index: currentIndex)], debugDescription: "Unkeyed container is at end."))
        }
        
        decoder.codingPath.append(_JSONKey(index: currentIndex))
        defer { decoder.codingPath.removeLast() }
        
        guard let decoded = try decoder.unbox(container[currentIndex], as: Int8.self) else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: decoder.codingPath + [_JSONKey(index: currentIndex)], debugDescription: "Expected \(type) but found null instead."))
        }
        
        currentIndex += 1
        return decoded
    }
    
    public mutating func decode(_ type: Int16.Type) throws -> Int16 {
        guard !isAtEnd else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: decoder.codingPath + [_JSONKey(index: currentIndex)], debugDescription: "Unkeyed container is at end."))
        }
        
        decoder.codingPath.append(_JSONKey(index: currentIndex))
        defer { decoder.codingPath.removeLast() }
        
        guard let decoded = try decoder.unbox(container[currentIndex], as: Int16.self) else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: decoder.codingPath + [_JSONKey(index: currentIndex)], debugDescription: "Expected \(type) but found null instead."))
        }
        
        currentIndex += 1
        return decoded
    }
    
    public mutating func decode(_ type: Int32.Type) throws -> Int32 {
        guard !isAtEnd else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: decoder.codingPath + [_JSONKey(index: currentIndex)], debugDescription: "Unkeyed container is at end."))
        }
        
        decoder.codingPath.append(_JSONKey(index: currentIndex))
        defer { decoder.codingPath.removeLast() }
        
        guard let decoded = try decoder.unbox(container[currentIndex], as: Int32.self) else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: decoder.codingPath + [_JSONKey(index: currentIndex)], debugDescription: "Expected \(type) but found null instead."))
        }
        
        currentIndex += 1
        return decoded
    }
    
    public mutating func decode(_ type: Int64.Type) throws -> Int64 {
        guard !isAtEnd else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: decoder.codingPath + [_JSONKey(index: currentIndex)], debugDescription: "Unkeyed container is at end."))
        }
        
        decoder.codingPath.append(_JSONKey(index: currentIndex))
        defer { decoder.codingPath.removeLast() }
        
        guard let decoded = try decoder.unbox(container[currentIndex], as: Int64.self) else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: decoder.codingPath + [_JSONKey(index: currentIndex)], debugDescription: "Expected \(type) but found null instead."))
        }
        
        currentIndex += 1
        return decoded
    }
    
    public mutating func decode(_ type: UInt.Type) throws -> UInt {
        guard !isAtEnd else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: decoder.codingPath + [_JSONKey(index: currentIndex)], debugDescription: "Unkeyed container is at end."))
        }
        
        decoder.codingPath.append(_JSONKey(index: currentIndex))
        defer { decoder.codingPath.removeLast() }
        
        guard let decoded = try decoder.unbox(container[currentIndex], as: UInt.self) else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: decoder.codingPath + [_JSONKey(index: currentIndex)], debugDescription: "Expected \(type) but found null instead."))
        }
        
        currentIndex += 1
        return decoded
    }
    
    public mutating func decode(_ type: UInt8.Type) throws -> UInt8 {
        guard !isAtEnd else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: decoder.codingPath + [_JSONKey(index: currentIndex)], debugDescription: "Unkeyed container is at end."))
        }
        
        decoder.codingPath.append(_JSONKey(index: currentIndex))
        defer { decoder.codingPath.removeLast() }
        
        guard let decoded = try decoder.unbox(container[currentIndex], as: UInt8.self) else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: decoder.codingPath + [_JSONKey(index: currentIndex)], debugDescription: "Expected \(type) but found null instead."))
        }
        
        currentIndex += 1
        return decoded
    }
    
    public mutating func decode(_ type: UInt16.Type) throws -> UInt16 {
        guard !isAtEnd else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: decoder.codingPath + [_JSONKey(index: currentIndex)], debugDescription: "Unkeyed container is at end."))
        }
        
        decoder.codingPath.append(_JSONKey(index: currentIndex))
        defer { decoder.codingPath.removeLast() }
        
        guard let decoded = try decoder.unbox(container[currentIndex], as: UInt16.self) else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: decoder.codingPath + [_JSONKey(index: currentIndex)], debugDescription: "Expected \(type) but found null instead."))
        }
        
        currentIndex += 1
        return decoded
    }
    
    public mutating func decode(_ type: UInt32.Type) throws -> UInt32 {
        guard !isAtEnd else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: decoder.codingPath + [_JSONKey(index: currentIndex)], debugDescription: "Unkeyed container is at end."))
        }
        
        decoder.codingPath.append(_JSONKey(index: currentIndex))
        defer { decoder.codingPath.removeLast() }
        
        guard let decoded = try decoder.unbox(container[currentIndex], as: UInt32.self) else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: decoder.codingPath + [_JSONKey(index: currentIndex)], debugDescription: "Expected \(type) but found null instead."))
        }
        
        currentIndex += 1
        return decoded
    }
    
    public mutating func decode(_ type: UInt64.Type) throws -> UInt64 {
        guard !isAtEnd else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: decoder.codingPath + [_JSONKey(index: currentIndex)], debugDescription: "Unkeyed container is at end."))
        }
        
        decoder.codingPath.append(_JSONKey(index: currentIndex))
        defer { decoder.codingPath.removeLast() }
        
        guard let decoded = try decoder.unbox(container[currentIndex], as: UInt64.self) else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: decoder.codingPath + [_JSONKey(index: currentIndex)], debugDescription: "Expected \(type) but found null instead."))
        }
        
        currentIndex += 1
        return decoded
    }
    
    public mutating func decode(_ type: Float.Type) throws -> Float {
        guard !isAtEnd else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: decoder.codingPath + [_JSONKey(index: currentIndex)], debugDescription: "Unkeyed container is at end."))
        }
        
        decoder.codingPath.append(_JSONKey(index: currentIndex))
        defer { decoder.codingPath.removeLast() }
        
        guard let decoded = try decoder.unbox(container[currentIndex], as: Float.self) else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: decoder.codingPath + [_JSONKey(index: currentIndex)], debugDescription: "Expected \(type) but found null instead."))
        }
        
        currentIndex += 1
        return decoded
    }
    
    public mutating func decode(_ type: Double.Type) throws -> Double {
        guard !isAtEnd else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: decoder.codingPath + [_JSONKey(index: currentIndex)], debugDescription: "Unkeyed container is at end."))
        }
        
        decoder.codingPath.append(_JSONKey(index: currentIndex))
        defer { decoder.codingPath.removeLast() }
        
        guard let decoded = try decoder.unbox(container[currentIndex], as: Double.self) else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: decoder.codingPath + [_JSONKey(index: currentIndex)], debugDescription: "Expected \(type) but found null instead."))
        }
        
        currentIndex += 1
        return decoded
    }
    
    public mutating func decode(_ type: String.Type) throws -> String {
        guard !isAtEnd else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: decoder.codingPath + [_JSONKey(index: currentIndex)], debugDescription: "Unkeyed container is at end."))
        }
        
        decoder.codingPath.append(_JSONKey(index: currentIndex))
        defer { decoder.codingPath.removeLast() }
        
        guard let decoded = try decoder.unbox(container[currentIndex], as: String.self) else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: decoder.codingPath + [_JSONKey(index: currentIndex)], debugDescription: "Expected \(type) but found null instead."))
        }
        
        currentIndex += 1
        return decoded
    }
    
    public mutating func decode<T : Decodable>(_ type: T.Type) throws -> T {
        guard !isAtEnd else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: decoder.codingPath + [_JSONKey(index: currentIndex)], debugDescription: "Unkeyed container is at end."))
        }
        
        decoder.codingPath.append(_JSONKey(index: currentIndex))
        defer { decoder.codingPath.removeLast() }
        
        guard let decoded = try decoder.unbox(container[currentIndex], as: type) else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: decoder.codingPath + [_JSONKey(index: currentIndex)], debugDescription: "Expected \(type) but found null instead."))
        }
        
        currentIndex += 1
        return decoded
    }
    
    public mutating func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> {
        
        decoder.codingPath.append(_JSONKey(index: currentIndex))
        defer { decoder.codingPath.removeLast() }
        
        guard !isAtEnd else {
            throw DecodingError.valueNotFound(KeyedDecodingContainer<NestedKey>.self,
                                              DecodingError.Context(codingPath: codingPath,
                                                                    debugDescription: "Cannot get nested keyed container -- unkeyed container is at end."))
        }
        
        let value = self.container[currentIndex]
        guard !value.isNull else {
            throw DecodingError.valueNotFound(KeyedDecodingContainer<NestedKey>.self,
                                              DecodingError.Context(codingPath: codingPath,
                                                                    debugDescription: "Cannot get keyed decoding container -- found null value instead."))
        }
        
        guard case .object(let obj) = value else {
            throw DecodingError._typeMismatch(at: codingPath, expectation: JSON.Object.self, reality: value)
        }
        
        currentIndex += 1
        let container = _JSONKeyedDecodingContainer<NestedKey>(referencing: decoder, wrapping: obj)
        return KeyedDecodingContainer(container)
    }
    
    public mutating func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
        
        decoder.codingPath.append(_JSONKey(index: currentIndex))
        defer { decoder.codingPath.removeLast() }
        
        guard !isAtEnd else {
            throw DecodingError.valueNotFound(UnkeyedDecodingContainer.self,
                                              DecodingError.Context(codingPath: codingPath,
                                                                    debugDescription: "Cannot get nested keyed container -- unkeyed container is at end."))
        }
        
        var value = container[currentIndex]
        if value.isNull {
            value = JSON.array([])
        }
        guard !value.isError else {
            throw DecodingError.valueNotFound(UnkeyedDecodingContainer.self,
                                              DecodingError.Context(codingPath: codingPath,
                                                                    debugDescription: "Cannot get keyed decoding container -- found null value instead."))
        }
        
        guard case .array(let list) = value else {
            throw DecodingError._typeMismatch(at: codingPath, expectation: JSON.Array.self, reality: value)
        }
        
        currentIndex += 1
        return _JSONUnkeyedDecodingContainer(referencing: decoder, wrapping: list)
    }
    
    public mutating func superDecoder() throws -> Decoder {
        
        decoder.codingPath.append(_JSONKey(index: currentIndex))
        defer { decoder.codingPath.removeLast() }
        
        guard !isAtEnd else {
            throw DecodingError.valueNotFound(Decoder.self,
                                              DecodingError.Context(codingPath: codingPath,
                                                                    debugDescription: "Cannot get superDecoder() -- unkeyed container is at end."))
        }
        
        let value = container[currentIndex]
        currentIndex += 1
        return _JSONDecoder(referencing: value, at: decoder.codingPath, options: decoder.options)
    }
}

extension _JSONDecoder : SingleValueDecodingContainer {
    // MARK: SingleValueDecodingContainer Methods
    
    private func expectNonNull<T>(_ type: T.Type) throws {
        guard !self.decodeNil() else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.codingPath, debugDescription: "Expected \(type) but found null value instead."))
        }
    }
    
    public func decodeNil() -> Bool {
        return storage.topContainer.isNullOrError
    }
    
    public func decode(_ type: Bool.Type) throws -> Bool {
        try expectNonNull(type)
        return try unbox(storage.topContainer, as: type)!
    }
    
    public func decode(_ type: Int.Type) throws -> Int {
        try expectNonNull(type)
        return try unbox(storage.topContainer, as: type)!
    }
    
    public func decode(_ type: Int8.Type) throws -> Int8 {
        try expectNonNull(type)
        return try unbox(storage.topContainer, as: type)!
    }
    
    public func decode(_ type: Int16.Type) throws -> Int16 {
        try expectNonNull(type)
        return try unbox(storage.topContainer, as: type)!
    }
    
    public func decode(_ type: Int32.Type) throws -> Int32 {
        try expectNonNull(type)
        return try unbox(storage.topContainer, as: type)!
    }
    
    public func decode(_ type: Int64.Type) throws -> Int64 {
        try expectNonNull(type)
        return try unbox(storage.topContainer, as: type)!
    }
    
    public func decode(_ type: UInt.Type) throws -> UInt {
        try expectNonNull(type)
        return try unbox(storage.topContainer, as: type)!
    }
    
    public func decode(_ type: UInt8.Type) throws -> UInt8 {
        try expectNonNull(type)
        return try unbox(storage.topContainer, as: type)!
    }
    
    public func decode(_ type: UInt16.Type) throws -> UInt16 {
        try expectNonNull(type)
        return try unbox(storage.topContainer, as: type)!
    }
    
    public func decode(_ type: UInt32.Type) throws -> UInt32 {
        try expectNonNull(type)
        return try unbox(storage.topContainer, as: type)!
    }
    
    public func decode(_ type: UInt64.Type) throws -> UInt64 {
        try expectNonNull(type)
        return try unbox(storage.topContainer, as: type)!
    }
    
    public func decode(_ type: Float.Type) throws -> Float {
        try expectNonNull(type)
        return try unbox(storage.topContainer, as: type)!
    }
    
    public func decode(_ type: Double.Type) throws -> Double {
        try expectNonNull(type)
        return try unbox(storage.topContainer, as: type)!
    }
    
    public func decode(_ type: String.Type) throws -> String {
        try expectNonNull(type)
        return try unbox(storage.topContainer, as: type)!
    }
    
    public func decode<T : Decodable>(_ type: T.Type) throws -> T {
        try expectNonNull(type)
        return try unbox(storage.topContainer, as: type)!
    }
}

// MARK: - Concrete Value Representations

extension _JSONDecoder {
    /// Returns the given value unboxed from a container.
    fileprivate func unbox(_ value: JSON, as type: Bool.Type) throws -> Bool? {
        switch value {
        case .null:                                                 return nil
        case .number(let aNum):                                     return aNum.boolValue
        case .string(let text) where ["true","1"].contains(text):   return true
        case .string(let text) where ["false","0"].contains(text):  return false
        default:
            throw DecodingError._typeMismatch(at: codingPath, expectation: type, reality: value)
        }
    }
    
//    @inline(__always)
    fileprivate func unbox(_ value: JSON, as type: JSON.Number.Type) throws -> JSON.Number? {
        switch value {
        case .null:             return nil
        case .number(let aNum): return aNum
        case .string(let text):
            if let aNum = try? text.parseJSONNumber() {
                return aNum
            } else if case let .convertFromString(posInfString, negInfString, nanString) = options.nonConformingFloatDecodingStrategy {
                switch text {
                case posInfString:  return JSON.Number.infinity
                case negInfString:  return -JSON.Number.infinity
                case nanString:     return JSON.Number.nan
                default:            break
                }
            }
            fallthrough
        default:
            throw DecodingError._typeMismatch(at: codingPath, expectation: type, reality: value)
        }
    }
    
//    @inline(__always)
    fileprivate func checkInteger<T:BinaryInteger>(number:JSON.Number, and value:T) throws -> T {
        if case .ignore = options.numberOverflowDecodingStrategy {
            return value
        }
        let temp:JSON.Number
        if T.isSigned {
            let value:Int64 = Int64(exactly: value) ?? Int64(clamping: value)
            temp = JSON.Number(value)
        } else {
            let value:UInt64 = UInt64(exactly: value) ?? UInt64(clamping: value)
            temp = JSON.Number(value)
        }
        guard temp == number else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: self.codingPath, debugDescription: "Parsed JSON number <\(number)> does not fit in \(type(of: T.self))."))
        }
        return value
    }
    
    
    fileprivate func unbox(_ value: JSON, as type: Int.Type) throws -> Int? {
        guard let number = try unbox(value, as: JSON.Number.self) else { return nil }
        return try checkInteger(number: number, and: number.intValue)
    }
    
    fileprivate func unbox(_ value: JSON, as type: Int8.Type) throws -> Int8? {
        guard let number = try unbox(value, as: JSON.Number.self) else { return nil }
        return try checkInteger(number: number, and: number.int8Value)
    }
    
    fileprivate func unbox(_ value: JSON, as type: Int16.Type) throws -> Int16? {
        guard let number = try unbox(value, as: JSON.Number.self) else { return nil }
        return try checkInteger(number: number, and: number.int16Value)
    }
    
    fileprivate func unbox(_ value: JSON, as type: Int32.Type) throws -> Int32? {
        guard let number = try unbox(value, as: JSON.Number.self) else { return nil }
        return try checkInteger(number: number, and: number.int32Value)
    }
    
    fileprivate func unbox(_ value: JSON, as type: Int64.Type) throws -> Int64? {
        guard let number = try unbox(value, as: JSON.Number.self) else { return nil }
        return try checkInteger(number: number, and: number.int64Value)
    }
    
    fileprivate func unbox(_ value: JSON, as type: UInt.Type) throws -> UInt? {
        guard let number = try unbox(value, as: JSON.Number.self) else { return nil }
        return try checkInteger(number: number, and: number.uintValue)
    }
    
    fileprivate func unbox(_ value: JSON, as type: UInt8.Type) throws -> UInt8? {
        guard let number = try unbox(value, as: JSON.Number.self) else { return nil }
        return try checkInteger(number: number, and: number.uint8Value)
    }
    
    fileprivate func unbox(_ value: JSON, as type: UInt16.Type) throws -> UInt16? {
        guard let number = try unbox(value, as: JSON.Number.self) else { return nil }
        return try checkInteger(number: number, and: number.uint16Value)
    }
    
    fileprivate func unbox(_ value: JSON, as type: UInt32.Type) throws -> UInt32? {
        guard let number = try unbox(value, as: JSON.Number.self) else { return nil }
        return try checkInteger(number: number, and: number.uint32Value)
    }
    
    fileprivate func unbox(_ value: JSON, as type: UInt64.Type) throws -> UInt64? {
        guard let number = try unbox(value, as: JSON.Number.self) else { return nil }
        return try checkInteger(number: number, and: number.uint64Value)
    }
    
    fileprivate func unbox(_ value: JSON, as type: Float.Type) throws -> Float? {
        
        guard let number = try unbox(value, as: JSON.Number.self) else { return nil }
        
        if number.isFinite {
            let double = number.doubleValue
            guard abs(double) <= Double(Float.greatestFiniteMagnitude) else {
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: codingPath, debugDescription: "Parsed JSON number \(number) does not fit in \(type)."))
            }
            
            return Float(double)
        } else if case .string(let text) = value,
            case let .convertFromString(posInfString, negInfString, nanString) = options.nonConformingFloatDecodingStrategy {
            switch text {
            case posInfString:  return Float.infinity
            case negInfString:  return -Float.infinity
            case nanString:     return Float.nan
            default:            break
            }
        }
        throw DecodingError._typeMismatch(at: codingPath, expectation: type, reality: value)
    }
    
    fileprivate func unbox(_ value: JSON, as type: Double.Type) throws -> Double? {
        guard let number = try unbox(value, as: JSON.Number.self) else { return nil }

        if number.isFinite {
            return number.doubleValue
        } else if case .string(let text) = value,
            case let .convertFromString(posInfString, negInfString, nanString) = options.nonConformingFloatDecodingStrategy {
            switch text {
            case posInfString:  return Double.infinity
            case negInfString:  return -Double.infinity
            case nanString:     return Double.nan
            default:            break
            }
        }
        throw DecodingError._typeMismatch(at: codingPath, expectation: type, reality: value)
    }
    
    fileprivate func unbox(_ value: JSON, as type: String.Type) throws -> String? {
        switch value {
        case .null:             return nil
        case .bool(let value):  return value.description
        case .number(let num):  return num.rawValue
        case .string(let txt):  return txt
        default: throw DecodingError._typeMismatch(at: codingPath, expectation: type, reality: value)
        }
    }
    
    fileprivate func unbox(_ value: JSON, as type: Date.Type) throws -> Date? {
        guard !value.isNullOrError else { return nil }
        
        switch options.dateDecodingStrategy {
        case .secondsSince1970:
            let double = try unbox(value, as: Double.self)!
            return Date(timeIntervalSince1970: double)
            
        case .millisecondsSince1970:
            let double = try unbox(value, as: Double.self)!
            return Date(timeIntervalSince1970: double / 1000.0)
            
        case .iso8601:
            if #available(macOS 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *) {
                let string = try unbox(value, as: String.self)!
                guard let date = _iso8601Formatter.date(from: string) else {
                    throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: codingPath, debugDescription: "Expected date string to be ISO8601-formatted."))
                }
                
                return date
            } else {
                fatalError("ISO8601DateFormatter is unavailable on this platform.")
            }
            
        case .formatted(let formatter):
            let string = try unbox(value, as: String.self)!
            guard let date = formatter.date(from: string) else {
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: codingPath, debugDescription: "Date string does not match format expected by formatter."))
            }
            
            return date
            
        case .custom(let closure):
            self.storage.push(container: value)
            defer { self.storage.popContainer() }
            return try closure(self)
        case .deferredToDate:
            fallthrough
        @unknown default:
            storage.push(container: value)
            defer { storage.popContainer() }
            return try Date(from: self)
        }
    }
    
    fileprivate func unbox(_ value: JSON, as type: Data.Type) throws -> Data? {
        guard !value.isNullOrError else { return nil }
        
        switch options.dataDecodingStrategy {
            
        case .base64:
            guard case .string(let string) = value else {
                throw DecodingError._typeMismatch(at: codingPath, expectation: type, reality: value)
            }
            
            guard let data = Data(base64Encoded: string) else {
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: codingPath, debugDescription: "Encountered Data is not valid Base64."))
            }
            
            return data
            
        case .custom(let closure):
            self.storage.push(container: value)
            defer { self.storage.popContainer() }
            return try closure(self)
        case .deferredToData:
            fallthrough
        @unknown default:
            
            self.storage.push(container: value)
            defer { self.storage.popContainer() }
            return try Data(from: self)
        }
    }
    
    fileprivate func unbox(_ value: JSON, as type: Decimal.Type) throws -> Decimal? {
        if let doubleValue = try unbox(value, as: Double.self) {
            return Decimal(doubleValue)
        } else {
            return try unbox(value, as: JSON.Number.self)?.decimalValue
        }
    }
    
    
    fileprivate func unbox<T : Decodable>(_ value: JSON, as type: T.Type) throws -> T? {
        if case .null = value {
            // 防止数组给空或其他允许为空的类型崩溃
            self.storage.push(container: value)
            defer { self.storage.popContainer() }
            return try type.init(from: self)
//            return nil
        }
        
        let decoded: T
        
        #if DEPLOYMENT_RUNTIME_SWIFT
        // Bridging differences require us to split implementations here
        if T.self == JSON.self {
            decoded = value as! T
        } else if T.self == Date.self {
            guard let date = try unbox(value, as: Date.self) else { return nil }
            decoded = date as! T
        } else if T.self == Data.self {
            guard let data = try unbox(value, as: Data.self) else { return nil }
            decoded = data as! T
        } else if T.self == URL.self, case .string(let text) = value {
            
            switch options.urlDecodingStrategy {
            case .throw:
                guard let url = URL(string: text) else {
                    throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: self.codingPath, debugDescription: "Invalid URL string."))
                }
                decoded = url as! T
            case .relative(let relative):
                guard let url = URL(string: text, relativeTo: relative) else {
                    throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: self.codingPath, debugDescription: "Invalid URL string."))
                }
                decoded = url as! T
            case .custom(let closure):
                let url = try closure(text)
                decoded = url as! T
            }
            
        } else if T.self == Decimal.self {
            guard let decimal = try unbox(value, as: Decimal.self) else { return nil }
            decoded = decimal as! T
        } else if T.self == JSON.Number.self, case .number(let number) = value {
            decoded = number as! T
        } else if T.self == JSON.Object.self, case .object(let object) = value {
            decoded = object as! T
        } else if T.self == JSON.Array.self, case .array(let list) = value {
            decoded = list as! T
        } else if T.self == [String:JSON].self, case .object(let object) = value {
            decoded = object._map as! T
        } else if T.self == [JSON].self, case .array(let list) = value {
            decoded = list.rawValue as! T
        } else {
            self.storage.push(container: value)
            defer { self.storage.popContainer() }
            return try type.init(from: self)
        }
        #else
        
        if T.self == JSON.self {
            decoded = value as! T
        } else if type == Date.self || type == NSDate.self {
            return try unbox(value, as: Date.self) as? T
        } else if type == Data.self || type == NSData.self {
            return try unbox(value, as: Data.self) as? T
        } else if type == URL.self || type == NSURL.self, case .string(let text) = value {
            
            switch options.urlDecodingStrategy {
            case .throw:
                guard let url = URL(string: text) else {
                    throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: codingPath, debugDescription: "Invalid URL string."))
                }
                decoded = url as! T
            case .relative(let relative):
                guard let url = URL(string: text, relativeTo: relative) else {
                    throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: codingPath, debugDescription: "Invalid URL string."))
                }
                decoded = url as! T
            case .custom(let closure):
                let url = try closure(text)
                decoded = url as! T
            }
            
        } else if type == Decimal.self || type == NSDecimalNumber.self {
            return try unbox(value, as: Decimal.self) as? T
        } else if T.self == JSON.Number.self, case .number(let number) = value {
            decoded = number as! T
        } else if T.self == JSON.Object.self, case .object(let object) = value {
            decoded = object as! T
        } else if T.self == JSON.Array.self, case .array(let list) = value {
            decoded = list as! T
        }  else if T.self == JSON.Array.self, case .null = value {
            decoded = [] as! T
        } else if T.self == [String:JSON].self, case .object(let object) = value {
            decoded = object._map as! T
        } else if T.self == [JSON].self, case .array(let list) = value {
            decoded = list.rawValue as! T
        } else if T.self == [JSON].self, case .null = value {
            decoded = [] as! T
        } else {
            self.storage.push(container: value)
            defer { self.storage.popContainer() }
            return try type.init(from: self)
        }
        #endif
        
        return decoded
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
