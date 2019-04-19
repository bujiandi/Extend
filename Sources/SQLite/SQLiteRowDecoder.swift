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
    
    struct RowDecoder :Decoder {
        
        let row:RowSetBase
        
        /// The path of coding keys taken to get to this point in encoding.
        public let codingPath:[CodingKey]
        
        init(_ value:RowSetBase, key:CodingKey? = nil, path:[CodingKey] = []) throws {
            var list:[CodingKey] = path
            if let last = key {
                list.append(last)
            }
            codingPath = list
            row = value
        }
        
        /// Any contextual information set by the user for encoding.
        public var userInfo: [CodingUserInfoKey : Any] { return [:] }
        
        /// Returns the data stored in this decoder as represented in a container appropriate for holding values with no keys.
        ///
        /// - returns: An unkeyed container view into this decoder.
        /// - throws: `DecodingError.typeMismatch` if the encountered stored value is not an unkeyed container.
        public func unkeyedContainer() throws -> UnkeyedDecodingContainer {
            
            return UnkeyedContainer(row, path: codingPath)
        }
        
        /// Returns the data stored in this decoder as represented in a container appropriate for holding a single primitive value.
        ///
        /// - returns: A single value container view into this decoder.
        /// - throws: `DecodingError.typeMismatch` if the encountered stored value is not a single value container.
        public func singleValueContainer() throws -> SingleValueDecodingContainer {
            if let last = codingPath.last {
                var list = codingPath
                list.removeLast()
                return try ValueContainer.init(row, key: last, path: list)
            }
            return try ValueContainer(row, columnIndex: 0, path: codingPath)
        }
        
        /// Returns the data stored in this decoder as represented in a container keyed by the given key type.
        ///
        /// - parameter type: The key type to use for the container.
        /// - returns: A keyed decoding container view into this decoder.
        /// - throws: `DecodingError.typeMismatch` if the encountered stored value is not a keyed container.
        public func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
            return KeyedDecodingContainer<Key>(KeyedContainer<Key>(row, path: codingPath))
        }
        
        
    }

}

