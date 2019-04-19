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
    
    // MARK: - enum 枚举(数据库只读模式等)
//    public enum OpenMode: CInt {
//        case readWrite = 0x00000006 // SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE
//        case readOnly  = 0x00000001 // SQLITE_OPEN_READONLY
//    }

    public struct OpenMode: OptionSet, RawRepresentable, ExpressibleByIntegerLiteral {
        
        public static let create = OpenMode(SQLITE_OPEN_CREATE)
        public static let readOnly = OpenMode(SQLITE_OPEN_READONLY)
        public static let readWrite = OpenMode(SQLITE_OPEN_READWRITE)
        public static let readWriteCreate = OpenMode(SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE)
        
        public typealias IntegerLiteralType = CInt
        public typealias RawValue = CInt
        
        public var rawValue: CInt = 0
        public init(rawValue: CInt) {
            self.rawValue = rawValue
        }
        
        public init(integerLiteral value: CInt) {
            rawValue = value
        }
        
        public init(_ value: CInt) {
            rawValue = value
        }
        
        
    }
    
    
}
