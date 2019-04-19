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
    struct UnkeyedContainer : UnkeyedDecodingContainer {
        
        internal let _stmt:OpaquePointer?
        fileprivate let _columns:[String]

        /// The path of coding keys taken to get to this point in encoding.
        public let codingPath:[CodingKey]
        
        init(_ value:RowSetBase, key:CodingKey? = nil, path:[CodingKey] = []) {
            var pathList:[CodingKey] = path
            if let last = key {
                pathList.append(last)
            }
            
            codingPath = pathList
            _stmt = value._stmt
            
            var columns:[String] = []
            let length = sqlite3_column_count(_stmt);
            columns.reserveCapacity(Int(length))
            for i:CInt in 0..<length {
                let name:UnsafePointer<CChar> = sqlite3_column_name(_stmt,i)
                
                columns.append(String(cString: name).lowercased())
            }
            //print(columns)
            _columns = columns
        }
        
        var index:Int = 0
        var isEnd:Bool = false
        
        mutating func next() throws -> RowSetBase? {
            defer { index += 1 }
            isEnd = sqlite3_step(_stmt) != SQLITE_ROW
            return isEnd ? nil : RowSetBase(_stmt!, _columns)
        }
        
        // MARK: - UnkeyedDecodingContainer
        
        /// The number of elements contained within this container.
        ///
        /// If the number of elements is unknown, the value is `nil`.
        public var count: Int? { return nil }
        
        /// A Boolean value indicating whether there are no more elements left to be decoded in the container.
        public var isAtEnd: Bool { return isEnd }
        
        /// The current decoding index of the container (i.e. the index of the next element to be decoded.)
        /// Incremented after every successful decode call.
        public var currentIndex: Int { return index }
        
        /// Decodes a null value.
        ///
        /// If the value is not null, does not increment currentIndex.
        ///
        /// - returns: Whether the encountered value was null.
        /// - throws: `DecodingError.valueNotFound` if there are no more values to decode.
        public mutating func decodeNil() throws -> Bool {
            let columnType = sqlite3_column_type(_stmt, 0)
            return columnType == SQLITE_NULL
        }
        
        /// Decodes a value of the given type.
        ///
        /// - parameter type: The type of value to decode.
        /// - returns: A value of the requested type, if present for the given key and convertible to the requested type.
        /// - throws: `DecodingError.typeMismatch` if the encountered encoded value is not convertible to the requested type.
        /// - throws: `DecodingError.valueNotFound` if the encountered encoded value is null, or of there are no more values to decode.
        public mutating func decode(_ type: Bool.Type) throws -> Bool {
            return sqlite3_column_int(_stmt, 0) != 0
        }
        
        /// Decodes a value of the given type.
        ///
        /// - parameter type: The type of value to decode.
        /// - returns: A value of the requested type, if present for the given key and convertible to the requested type.
        /// - throws: `DecodingError.typeMismatch` if the encountered encoded value is not convertible to the requested type.
        /// - throws: `DecodingError.valueNotFound` if the encountered encoded value is null, or of there are no more values to decode.
        public mutating func decode(_ type: Int.Type) throws -> Int {
            let value = sqlite3_column_int64(_stmt, 0)
            return Int(truncatingIfNeeded: value)
        }
        
        /// Decodes a value of the given type.
        ///
        /// - parameter type: The type of value to decode.
        /// - returns: A value of the requested type, if present for the given key and convertible to the requested type.
        /// - throws: `DecodingError.typeMismatch` if the encountered encoded value is not convertible to the requested type.
        /// - throws: `DecodingError.valueNotFound` if the encountered encoded value is null, or of there are no more values to decode.
        public mutating func decode(_ type: Int8.Type) throws -> Int8 {
            let value = sqlite3_column_int(_stmt, 0)
            return Int8(truncatingIfNeeded: value)
        }
        
        /// Decodes a value of the given type.
        ///
        /// - parameter type: The type of value to decode.
        /// - returns: A value of the requested type, if present for the given key and convertible to the requested type.
        /// - throws: `DecodingError.typeMismatch` if the encountered encoded value is not convertible to the requested type.
        /// - throws: `DecodingError.valueNotFound` if the encountered encoded value is null, or of there are no more values to decode.
        public mutating func decode(_ type: Int16.Type) throws -> Int16 {
            let value = sqlite3_column_int(_stmt, 0)
            return Int16(truncatingIfNeeded: value)
        }
        
        /// Decodes a value of the given type.
        ///
        /// - parameter type: The type of value to decode.
        /// - returns: A value of the requested type, if present for the given key and convertible to the requested type.
        /// - throws: `DecodingError.typeMismatch` if the encountered encoded value is not convertible to the requested type.
        /// - throws: `DecodingError.valueNotFound` if the encountered encoded value is null, or of there are no more values to decode.
        public mutating func decode(_ type: Int32.Type) throws -> Int32 {
            return sqlite3_column_int(_stmt, 0)
        }
        
        /// Decodes a value of the given type.
        ///
        /// - parameter type: The type of value to decode.
        /// - returns: A value of the requested type, if present for the given key and convertible to the requested type.
        /// - throws: `DecodingError.typeMismatch` if the encountered encoded value is not convertible to the requested type.
        /// - throws: `DecodingError.valueNotFound` if the encountered encoded value is null, or of there are no more values to decode.
        public mutating func decode(_ type: Int64.Type) throws -> Int64 {
            return sqlite3_column_int64(_stmt, 0)
        }
        
        /// Decodes a value of the given type.
        ///
        /// - parameter type: The type of value to decode.
        /// - returns: A value of the requested type, if present for the given key and convertible to the requested type.
        /// - throws: `DecodingError.typeMismatch` if the encountered encoded value is not convertible to the requested type.
        /// - throws: `DecodingError.valueNotFound` if the encountered encoded value is null, or of there are no more values to decode.
        public mutating func decode(_ type: UInt.Type) throws -> UInt {
            let value = sqlite3_column_int64(_stmt, 0)
            return UInt(truncatingIfNeeded: value)
        }
        
        /// Decodes a value of the given type.
        ///
        /// - parameter type: The type of value to decode.
        /// - returns: A value of the requested type, if present for the given key and convertible to the requested type.
        /// - throws: `DecodingError.typeMismatch` if the encountered encoded value is not convertible to the requested type.
        /// - throws: `DecodingError.valueNotFound` if the encountered encoded value is null, or of there are no more values to decode.
        public mutating func decode(_ type: UInt8.Type) throws -> UInt8 {
            let value = sqlite3_column_int(_stmt, 0)
            return UInt8(truncatingIfNeeded: value)
        }
        
        /// Decodes a value of the given type.
        ///
        /// - parameter type: The type of value to decode.
        /// - returns: A value of the requested type, if present for the given key and convertible to the requested type.
        /// - throws: `DecodingError.typeMismatch` if the encountered encoded value is not convertible to the requested type.
        /// - throws: `DecodingError.valueNotFound` if the encountered encoded value is null, or of there are no more values to decode.
        public mutating func decode(_ type: UInt16.Type) throws -> UInt16 {
            let value = sqlite3_column_int(_stmt, 0)
            return UInt16(truncatingIfNeeded: value)
        }
        
        /// Decodes a value of the given type.
        ///
        /// - parameter type: The type of value to decode.
        /// - returns: A value of the requested type, if present for the given key and convertible to the requested type.
        /// - throws: `DecodingError.typeMismatch` if the encountered encoded value is not convertible to the requested type.
        /// - throws: `DecodingError.valueNotFound` if the encountered encoded value is null, or of there are no more values to decode.
        public mutating func decode(_ type: UInt32.Type) throws -> UInt32 {
            let value = sqlite3_column_int64(_stmt, 0)
            return UInt32(truncatingIfNeeded: value)
        }
        
        /// Decodes a value of the given type.
        ///
        /// - parameter type: The type of value to decode.
        /// - returns: A value of the requested type, if present for the given key and convertible to the requested type.
        /// - throws: `DecodingError.typeMismatch` if the encountered encoded value is not convertible to the requested type.
        /// - throws: `DecodingError.valueNotFound` if the encountered encoded value is null, or of there are no more values to decode.
        public mutating func decode(_ type: UInt64.Type) throws -> UInt64 {
            let value = sqlite3_column_int64(_stmt, 0)
            return UInt64(truncatingIfNeeded: value)
        }
        
        /// Decodes a value of the given type.
        ///
        /// - parameter type: The type of value to decode.
        /// - returns: A value of the requested type, if present for the given key and convertible to the requested type.
        /// - throws: `DecodingError.typeMismatch` if the encountered encoded value is not convertible to the requested type.
        /// - throws: `DecodingError.valueNotFound` if the encountered encoded value is null, or of there are no more values to decode.
        public mutating func decode(_ type: Float.Type) throws -> Float {
            let value = sqlite3_column_double(_stmt, 0)
            return Float(exactly: value) ?? Float(value)
        }
        
        /// Decodes a value of the given type.
        ///
        /// - parameter type: The type of value to decode.
        /// - returns: A value of the requested type, if present for the given key and convertible to the requested type.
        /// - throws: `DecodingError.typeMismatch` if the encountered encoded value is not convertible to the requested type.
        /// - throws: `DecodingError.valueNotFound` if the encountered encoded value is null, or of there are no more values to decode.
        public mutating func decode(_ type: Double.Type) throws -> Double {
            return sqlite3_column_double(_stmt, 0)
        }
        
        /// Decodes a value of the given type.
        ///
        /// - parameter type: The type of value to decode.
        /// - returns: A value of the requested type, if present for the given key and convertible to the requested type.
        /// - throws: `DecodingError.typeMismatch` if the encountered encoded value is not convertible to the requested type.
        /// - throws: `DecodingError.valueNotFound` if the encountered encoded value is null, or of there are no more values to decode.
        public mutating func decode(_ type: String.Type) throws -> String {
            guard let result = sqlite3_column_text(_stmt, 0) else {
                return ""
            }
            return String(cString: result)
        }
        
        /// Decodes a value of the given type.
        ///
        /// - parameter type: The type of value to decode.
        /// - returns: A value of the requested type, if present for the given key and convertible to the requested type.
        /// - throws: `DecodingError.typeMismatch` if the encountered encoded value is not convertible to the requested type.
        /// - throws: `DecodingError.valueNotFound` if the encountered encoded value is null, or of there are no more values to decode.
        public mutating func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
            guard let row = try next() else {
                let context = DecodingError.Context(codingPath: codingPath, debugDescription: "out of range")
                throw DecodingError.valueNotFound(type, context)
            }
            let decoder = try RowDecoder(row, path: codingPath)
            return try T(from: decoder)
        }
        
        /// Decodes a nested container keyed by the given type.
        ///
        /// - parameter type: The key type to use for the container.
        /// - returns: A keyed decoding container view into `self`.
        /// - throws: `DecodingError.typeMismatch` if the encountered stored value is not a keyed container.
        public mutating func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
            
            guard let row = try next() else {
                let context = DecodingError.Context(codingPath: codingPath, debugDescription: "out of range")
                throw DecodingError.valueNotFound(type, context)
            }
            let container = KeyedContainer<NestedKey>(row, path: codingPath)
            return KeyedDecodingContainer<NestedKey>(container)
        }
        
        /// Decodes an unkeyed nested container.
        ///
        /// - returns: An unkeyed decoding container view into `self`.
        /// - throws: `DecodingError.typeMismatch` if the encountered stored value is not an unkeyed container.
        public mutating func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
            guard let row = try next() else {
                let context = DecodingError.Context(codingPath: codingPath, debugDescription: "out of range")
                throw DecodingError.dataCorrupted(context)
            }
            return UnkeyedContainer(row, path: codingPath)
        }
        
        /// Decodes a nested container and returns a `Decoder` instance for decoding `super` from that container.
        ///
        /// - returns: A new `Decoder` to pass to `super.init(from:)`.
        /// - throws: `DecodingError.valueNotFound` if the encountered encoded value is null, or of there are no more values to decode.
        public mutating func superDecoder() throws -> Decoder {
            guard let row = try next() else {
                let context = DecodingError.Context(codingPath: codingPath, debugDescription: "out of range")
                throw DecodingError.dataCorrupted(context)
            }
            return try RowDecoder(row, path: codingPath)
        }
    }

}

