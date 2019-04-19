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
    
    struct ValueContainer : SingleValueDecodingContainer {
        
        let row:RowSetBase
        
        private let i:Int
        /// The path of coding keys taken to get to this point in encoding.
        public let codingPath:[CodingKey]
        
        init(_ value:RowSetBase, columnIndex:Int, path:[CodingKey] = []) throws {
            codingPath = path
            row = value
            i = columnIndex
            let count = sqlite3_column_count(row._stmt)
            if i == NSNotFound || i < 0 || i > count {
                let context = DecodingError.Context(codingPath: path, debugDescription: "not contains:\(i)")
                throw DecodingError.valueNotFound(String.self, context)
            }
        }
        
        init(_ value:RowSetBase, key:CodingKey, path:[CodingKey] = []) throws {
            codingPath = path
            row = value
            i = row.getColumnIndex(key.stringValue)
            if i == NSNotFound || i >= row._columns.count {
                let context = DecodingError.Context(codingPath: path, debugDescription: "not contains:\(key)")
                throw DecodingError.keyNotFound(key, context)
            }
        }
        // MARK: - SingleValueDecodingContainer
        
        /// Decodes a null value.
        ///
        /// - returns: Whether the encountered value was null.
        public func decodeNil() -> Bool {
            let columnType = sqlite3_column_type(row._stmt, CInt(i))
            return columnType == SQLITE_NULL
        }
        
        /// Decodes a single value of the given type.
        ///
        /// - parameter type: The type to decode as.
        /// - returns: A value of the requested type.
        /// - throws: `DecodingError.typeMismatch` if the encountered encoded value cannot be converted to the requested type.
        /// - throws: `DecodingError.valueNotFound` if the encountered encoded value is null.
        public func decode(_ type: Bool.Type) throws -> Bool {
            return row.getBool(i)
        }
        
        /// Decodes a single value of the given type.
        ///
        /// - parameter type: The type to decode as.
        /// - returns: A value of the requested type.
        /// - throws: `DecodingError.typeMismatch` if the encountered encoded value cannot be converted to the requested type.
        /// - throws: `DecodingError.valueNotFound` if the encountered encoded value is null.
        public func decode(_ type: Int.Type) throws -> Int {
            return row.getInt(i)
        }
        
        /// Decodes a single value of the given type.
        ///
        /// - parameter type: The type to decode as.
        /// - returns: A value of the requested type.
        /// - throws: `DecodingError.typeMismatch` if the encountered encoded value cannot be converted to the requested type.
        /// - throws: `DecodingError.valueNotFound` if the encountered encoded value is null.
        public func decode(_ type: Int8.Type) throws -> Int8 {
            return row.getInt8(i)
        }
        
        /// Decodes a single value of the given type.
        ///
        /// - parameter type: The type to decode as.
        /// - returns: A value of the requested type.
        /// - throws: `DecodingError.typeMismatch` if the encountered encoded value cannot be converted to the requested type.
        /// - throws: `DecodingError.valueNotFound` if the encountered encoded value is null.
        public func decode(_ type: Int16.Type) throws -> Int16 {
            return row.getInt16(i)
        }
        
        /// Decodes a single value of the given type.
        ///
        /// - parameter type: The type to decode as.
        /// - returns: A value of the requested type.
        /// - throws: `DecodingError.typeMismatch` if the encountered encoded value cannot be converted to the requested type.
        /// - throws: `DecodingError.valueNotFound` if the encountered encoded value is null.
        public func decode(_ type: Int32.Type) throws -> Int32 {
            return row.getInt32(i)
        }
        
        /// Decodes a single value of the given type.
        ///
        /// - parameter type: The type to decode as.
        /// - returns: A value of the requested type.
        /// - throws: `DecodingError.typeMismatch` if the encountered encoded value cannot be converted to the requested type.
        /// - throws: `DecodingError.valueNotFound` if the encountered encoded value is null.
        public func decode(_ type: Int64.Type) throws -> Int64 {
            return row.getInt64(i)
        }
        
        /// Decodes a single value of the given type.
        ///
        /// - parameter type: The type to decode as.
        /// - returns: A value of the requested type.
        /// - throws: `DecodingError.typeMismatch` if the encountered encoded value cannot be converted to the requested type.
        /// - throws: `DecodingError.valueNotFound` if the encountered encoded value is null.
        public func decode(_ type: UInt.Type) throws -> UInt {
            return row.getUInt(i)
        }
        
        /// Decodes a single value of the given type.
        ///
        /// - parameter type: The type to decode as.
        /// - returns: A value of the requested type.
        /// - throws: `DecodingError.typeMismatch` if the encountered encoded value cannot be converted to the requested type.
        /// - throws: `DecodingError.valueNotFound` if the encountered encoded value is null.
        public func decode(_ type: UInt8.Type) throws -> UInt8 {
            return row.getUInt8(i)
        }
        
        /// Decodes a single value of the given type.
        ///
        /// - parameter type: The type to decode as.
        /// - returns: A value of the requested type.
        /// - throws: `DecodingError.typeMismatch` if the encountered encoded value cannot be converted to the requested type.
        /// - throws: `DecodingError.valueNotFound` if the encountered encoded value is null.
        public func decode(_ type: UInt16.Type) throws -> UInt16 {
            return row.getUInt16(i)
        }
        
        /// Decodes a single value of the given type.
        ///
        /// - parameter type: The type to decode as.
        /// - returns: A value of the requested type.
        /// - throws: `DecodingError.typeMismatch` if the encountered encoded value cannot be converted to the requested type.
        /// - throws: `DecodingError.valueNotFound` if the encountered encoded value is null.
        public func decode(_ type: UInt32.Type) throws -> UInt32 {
            return row.getUInt32(i)
        }
        
        /// Decodes a single value of the given type.
        ///
        /// - parameter type: The type to decode as.
        /// - returns: A value of the requested type.
        /// - throws: `DecodingError.typeMismatch` if the encountered encoded value cannot be converted to the requested type.
        /// - throws: `DecodingError.valueNotFound` if the encountered encoded value is null.
        public func decode(_ type: UInt64.Type) throws -> UInt64 {
            return row.getUInt64(i)
        }
        
        /// Decodes a single value of the given type.
        ///
        /// - parameter type: The type to decode as.
        /// - returns: A value of the requested type.
        /// - throws: `DecodingError.typeMismatch` if the encountered encoded value cannot be converted to the requested type.
        /// - throws: `DecodingError.valueNotFound` if the encountered encoded value is null.
        public func decode(_ type: Float.Type) throws -> Float {
            return row.getFloat(i)
        }
        
        /// Decodes a single value of the given type.
        ///
        /// - parameter type: The type to decode as.
        /// - returns: A value of the requested type.
        /// - throws: `DecodingError.typeMismatch` if the encountered encoded value cannot be converted to the requested type.
        /// - throws: `DecodingError.valueNotFound` if the encountered encoded value is null.
        public func decode(_ type: Double.Type) throws -> Double {
            return row.getDouble(i)
        }
        
        /// Decodes a single value of the given type.
        ///
        /// - parameter type: The type to decode as.
        /// - returns: A value of the requested type.
        /// - throws: `DecodingError.typeMismatch` if the encountered encoded value cannot be converted to the requested type.
        /// - throws: `DecodingError.valueNotFound` if the encountered encoded value is null.
        public func decode(_ type: String.Type) throws -> String {
            return row.getString(i) ?? ""
        }
        
        /// Decodes a single value of the given type.
        ///
        /// - parameter type: The type to decode as.
        /// - returns: A value of the requested type.
        /// - throws: `DecodingError.typeMismatch` if the encountered encoded value cannot be converted to the requested type.
        /// - throws: `DecodingError.valueNotFound` if the encountered encoded value is null.
        public func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
            let decoder = try RowDecoder(row, path: codingPath)
            return try T(from: decoder)
        }
        
    }
}

