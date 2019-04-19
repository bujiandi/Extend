//
//  SQLite.swift
//  SQLite
//
//  Created by yFenFen on 16/5/18.
//  Copyright © 2016 yFenFen. All rights reserved.
//

import SQLite3
import Foundation


extension SQLite {
    
    struct KeyedContainer<Key> : KeyedDecodingContainerProtocol where Key : CodingKey {
        
        let row:RowSetBase
        /// The path of coding keys taken to get to this point in decoding.
        public let codingPath:[CodingKey]
        
        init(_ value:RowSetBase, key:CodingKey? = nil, path:[CodingKey] = []) {
            var pathList:[CodingKey] = path
            if let last = key {
                pathList.append(last)
            }
            codingPath = pathList
            row = value
        }
  
        private func index(forKey key: Key) throws -> Int {
            let i = row.getColumnIndex(key.stringValue)
            if i == NSNotFound {
                let path = codingPath + [key]
                let context = DecodingError.Context(codingPath: path, debugDescription: "not contains:\(key)")
                throw DecodingError.keyNotFound(key, context)
            }
            return i
        }
        
        /// All the keys the `Decoder` has for this container.
        ///
        /// Different keyed containers from the same `Decoder` may return different keys here; it is possible to encode with multiple key types which are not convertible to one another. This should report all keys present which are convertible to the requested type.
        var allKeys: [Key] {
            return row._columns.compactMap { Key(stringValue: $0) }
        }
        
        
        /// Returns a Boolean value indicating whether the decoder contains a value associated with the given key.
        ///
        /// The value associated with `key` may be a null value as appropriate for the data format.
        ///
        /// - parameter key: The key to search for.
        /// - returns: Whether the `Decoder` has an entry for the given key.
        func contains(_ key: Key) -> Bool {
            return row._columns.contains(key.stringValue)
        }
        
        /// Decodes a null value for the given key.
        ///
        /// - parameter key: The key that the decoded value is associated with.
        /// - returns: Whether the encountered value was null.
        /// - throws: `DecodingError.keyNotFound` if `self` does not have an entry for the given key.
        func decodeNil(forKey key: Key) throws -> Bool {
            let i = try index(forKey: key)
            let columnType = sqlite3_column_type(row._stmt, CInt(i))
            return columnType == SQLITE_NULL
        }
        
        /// Decodes a value of the given type for the given key.
        ///
        /// - parameter type: The type of value to decode.
        /// - parameter key: The key that the decoded value is associated with.
        /// - returns: A value of the requested type, if present for the given key and convertible to the requested type.
        /// - throws: `DecodingError.typeMismatch` if the encountered encoded value is not convertible to the requested type.
        /// - throws: `DecodingError.keyNotFound` if `self` does not have an entry for the given key.
        /// - throws: `DecodingError.valueNotFound` if `self` has a null entry for the given key.
        func decode(_ type: Bool.Type, forKey key: Key) throws -> Bool {
            let i = try index(forKey: key)
            return row.getBool(i)
        }
        
//        func decode<Number>(_ type: Number.Type, forKey key: Key) throws -> NSNumber {
//            let i = try index(forKey: key)
//            return row.getBool(i)
//
//        }
        
        /// Decodes a value of the given type for the given key.
        ///
        /// - parameter type: The type of value to decode.
        /// - parameter key: The key that the decoded value is associated with.
        /// - returns: A value of the requested type, if present for the given key and convertible to the requested type.
        /// - throws: `DecodingError.typeMismatch` if the encountered encoded value is not convertible to the requested type.
        /// - throws: `DecodingError.keyNotFound` if `self` does not have an entry for the given key.
        /// - throws: `DecodingError.valueNotFound` if `self` has a null entry for the given key.
        func decode(_ type: Int.Type, forKey key: Key) throws -> Int {
            let i = try index(forKey: key)
            return row.getInt(i)
        }
        
        /// Decodes a value of the given type for the given key.
        ///
        /// - parameter type: The type of value to decode.
        /// - parameter key: The key that the decoded value is associated with.
        /// - returns: A value of the requested type, if present for the given key and convertible to the requested type.
        /// - throws: `DecodingError.typeMismatch` if the encountered encoded value is not convertible to the requested type.
        /// - throws: `DecodingError.keyNotFound` if `self` does not have an entry for the given key.
        /// - throws: `DecodingError.valueNotFound` if `self` has a null entry for the given key.
        func decode(_ type: Int8.Type, forKey key: Key) throws -> Int8 {
            let i = try index(forKey: key)
            return row.getInt8(i)
        }
        
        /// Decodes a value of the given type for the given key.
        ///
        /// - parameter type: The type of value to decode.
        /// - parameter key: The key that the decoded value is associated with.
        /// - returns: A value of the requested type, if present for the given key and convertible to the requested type.
        /// - throws: `DecodingError.typeMismatch` if the encountered encoded value is not convertible to the requested type.
        /// - throws: `DecodingError.keyNotFound` if `self` does not have an entry for the given key.
        /// - throws: `DecodingError.valueNotFound` if `self` has a null entry for the given key.
        func decode(_ type: Int16.Type, forKey key: Key) throws -> Int16 {
            let i = try index(forKey: key)
            return row.getInt16(i)
        }
        
        
        /// Decodes a value of the given type for the given key.
        ///
        /// - parameter type: The type of value to decode.
        /// - parameter key: The key that the decoded value is associated with.
        /// - returns: A value of the requested type, if present for the given key and convertible to the requested type.
        /// - throws: `DecodingError.typeMismatch` if the encountered encoded value is not convertible to the requested type.
        /// - throws: `DecodingError.keyNotFound` if `self` does not have an entry for the given key.
        /// - throws: `DecodingError.valueNotFound` if `self` has a null entry for the given key.
        func decode(_ type: Int32.Type, forKey key: Key) throws -> Int32 {
            let i = try index(forKey: key)
            return row.getInt32(i)
        }
        
        /// Decodes a value of the given type for the given key.
        ///
        /// - parameter type: The type of value to decode.
        /// - parameter key: The key that the decoded value is associated with.
        /// - returns: A value of the requested type, if present for the given key and convertible to the requested type.
        /// - throws: `DecodingError.typeMismatch` if the encountered encoded value is not convertible to the requested type.
        /// - throws: `DecodingError.keyNotFound` if `self` does not have an entry for the given key.
        /// - throws: `DecodingError.valueNotFound` if `self` has a null entry for the given key.
        func decode(_ type: Int64.Type, forKey key: Key) throws -> Int64 {
            let i = try index(forKey: key)
            return row.getInt64(i)
        }
        
        /// Decodes a value of the given type for the given key.
        ///
        /// - parameter type: The type of value to decode.
        /// - parameter key: The key that the decoded value is associated with.
        /// - returns: A value of the requested type, if present for the given key and convertible to the requested type.
        /// - throws: `DecodingError.typeMismatch` if the encountered encoded value is not convertible to the requested type.
        /// - throws: `DecodingError.keyNotFound` if `self` does not have an entry for the given key.
        /// - throws: `DecodingError.valueNotFound` if `self` has a null entry for the given key.
        func decode(_ type: UInt.Type, forKey key: Key) throws -> UInt {
            let i = try index(forKey: key)
            return row.getUInt(i)
        }
        
        /// Decodes a value of the given type for the given key.
        ///
        /// - parameter type: The type of value to decode.
        /// - parameter key: The key that the decoded value is associated with.
        /// - returns: A value of the requested type, if present for the given key and convertible to the requested type.
        /// - throws: `DecodingError.typeMismatch` if the encountered encoded value is not convertible to the requested type.
        /// - throws: `DecodingError.keyNotFound` if `self` does not have an entry for the given key.
        /// - throws: `DecodingError.valueNotFound` if `self` has a null entry for the given key.
        func decode(_ type: UInt8.Type, forKey key: Key) throws -> UInt8 {
            let i = try index(forKey: key)
            return row.getUInt8(i)
        }
        
        
        /// Decodes a value of the given type for the given key.
        ///
        /// - parameter type: The type of value to decode.
        /// - parameter key: The key that the decoded value is associated with.
        /// - returns: A value of the requested type, if present for the given key and convertible to the requested type.
        /// - throws: `DecodingError.typeMismatch` if the encountered encoded value is not convertible to the requested type.
        /// - throws: `DecodingError.keyNotFound` if `self` does not have an entry for the given key.
        /// - throws: `DecodingError.valueNotFound` if `self` has a null entry for the given key.
        func decode(_ type: UInt16.Type, forKey key: Key) throws -> UInt16 {
            let i = try index(forKey: key)
            return row.getUInt16(i)
        }
        
        
        /// Decodes a value of the given type for the given key.
        ///
        /// - parameter type: The type of value to decode.
        /// - parameter key: The key that the decoded value is associated with.
        /// - returns: A value of the requested type, if present for the given key and convertible to the requested type.
        /// - throws: `DecodingError.typeMismatch` if the encountered encoded value is not convertible to the requested type.
        /// - throws: `DecodingError.keyNotFound` if `self` does not have an entry for the given key.
        /// - throws: `DecodingError.valueNotFound` if `self` has a null entry for the given key.
        func decode(_ type: UInt32.Type, forKey key: Key) throws -> UInt32 {
            let i = try index(forKey: key)
            return row.getUInt32(i)
        }
        
        /// Decodes a value of the given type for the given key.
        ///
        /// - parameter type: The type of value to decode.
        /// - parameter key: The key that the decoded value is associated with.
        /// - returns: A value of the requested type, if present for the given key and convertible to the requested type.
        /// - throws: `DecodingError.typeMismatch` if the encountered encoded value is not convertible to the requested type.
        /// - throws: `DecodingError.keyNotFound` if `self` does not have an entry for the given key.
        /// - throws: `DecodingError.valueNotFound` if `self` has a null entry for the given key.
        func decode(_ type: UInt64.Type, forKey key: Key) throws -> UInt64 {
            let i = try index(forKey: key)
            return row.getUInt64(i)
        }
        
        /// Decodes a value of the given type for the given key.
        ///
        /// - parameter type: The type of value to decode.
        /// - parameter key: The key that the decoded value is associated with.
        /// - returns: A value of the requested type, if present for the given key and convertible to the requested type.
        /// - throws: `DecodingError.typeMismatch` if the encountered encoded value is not convertible to the requested type.
        /// - throws: `DecodingError.keyNotFound` if `self` does not have an entry for the given key.
        /// - throws: `DecodingError.valueNotFound` if `self` has a null entry for the given key.
        func decode(_ type: Float.Type, forKey key: Key) throws -> Float {
            let i = try index(forKey: key)
            return row.getFloat(i)
        }
        
        /// Decodes a value of the given type for the given key.
        ///
        /// - parameter type: The type of value to decode.
        /// - parameter key: The key that the decoded value is associated with.
        /// - returns: A value of the requested type, if present for the given key and convertible to the requested type.
        /// - throws: `DecodingError.typeMismatch` if the encountered encoded value is not convertible to the requested type.
        /// - throws: `DecodingError.keyNotFound` if `self` does not have an entry for the given key.
        /// - throws: `DecodingError.valueNotFound` if `self` has a null entry for the given key.
        func decode(_ type: Double.Type, forKey key: Key) throws -> Double {
            let i = try index(forKey: key)
            return row.getDouble(i)
        }
        
        /// Decodes a value of the given type for the given key.
        ///
        /// - parameter type: The type of value to decode.
        /// - parameter key: The key that the decoded value is associated with.
        /// - returns: A value of the requested type, if present for the given key and convertible to the requested type.
        /// - throws: `DecodingError.typeMismatch` if the encountered encoded value is not convertible to the requested type.
        /// - throws: `DecodingError.keyNotFound` if `self` does not have an entry for the given key.
        /// - throws: `DecodingError.valueNotFound` if `self` has a null entry for the given key.
        func decode(_ type: String.Type, forKey key: Key) throws -> String {
            let i = try index(forKey: key)
            return row.getString(i) ?? ""
        }
        
        /// Decodes a value of the given type for the given key.
        ///
        /// - parameter type: The type of value to decode.
        /// - parameter key: The key that the decoded value is associated with.
        /// - returns: A value of the requested type, if present for the given key and convertible to the requested type.
        /// - throws: `DecodingError.typeMismatch` if the encountered encoded value is not convertible to the requested type.
        /// - throws: `DecodingError.keyNotFound` if `self` does not have an entry for the given key.
        /// - throws: `DecodingError.valueNotFound` if `self` has a null entry for the given key.
        func decode<T>(_ type: T.Type, forKey key: Key) throws -> T where T : Decodable {
            let decoder = try SQLite.RowDecoder(row, key: key, path: codingPath)
            return try T(from: decoder)
        }
        
        /// Returns the data stored for the given key as represented in a container keyed by the given key type.
        ///
        /// - parameter type: The key type to use for the container.
        /// - parameter key: The key that the nested container is associated with.
        /// - returns: A keyed decoding container view into `self`.
        /// - throws: `DecodingError.typeMismatch` if the encountered stored value is not a keyed container.
        func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: Key) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
            let container = KeyedContainer<NestedKey>(row, key: key, path: codingPath)
            return KeyedDecodingContainer<NestedKey>(container)
        }
        
        /// Returns the data stored for the given key as represented in an unkeyed container.
        ///
        /// - parameter key: The key that the nested container is associated with.
        /// - returns: An unkeyed decoding container view into `self`.
        /// - throws: `DecodingError.typeMismatch` if the encountered stored value is not an unkeyed container.
        func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
            return UnkeyedContainer(row, key: key, path: codingPath)
        }
        
        /// Returns a `Decoder` instance for decoding `super` from the container associated with the default `super` key.
        ///
        /// Equivalent to calling `superDecoder(forKey:)` with `Key(stringValue: "super", intValue: 0)`.
        ///
        /// - returns: A new `Decoder` to pass to `super.init(from:)`.
        /// - throws: `DecodingError.keyNotFound` if `self` does not have an entry for the default `super` key.
        /// - throws: `DecodingError.valueNotFound` if `self` has a null entry for the default `super` key.
        func superDecoder(forKey key: Key) throws -> Decoder {
            return try RowDecoder(row, key: key, path: codingPath)
        }
        
        /// Returns a `Decoder` instance for decoding `super` from the container associated with the given key.
        ///
        /// - parameter key: The key to decode `super` for.
        /// - returns: A new `Decoder` to pass to `super.init(from:)`.
        /// - throws: `DecodingError.keyNotFound` if `self` does not have an entry for the given key.
        /// - throws: `DecodingError.valueNotFound` if `self` has a null entry for the given key.
        func superDecoder() throws -> Decoder {
            return try RowDecoder(row, path: codingPath)
        }
        
    }
}

