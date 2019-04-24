//
//  SQLiteColumn.swift
//  SQLite
//
//  Created by 李招利 on 2019/4/23.
//

import DataBase

extension SQLite {
    
    public enum ColumnType : CInt, DBColumnTypeProtocol, CustomStringConvertible {
        case integer = 1
        case float
        case text
        case blob
        case null
        
        public var description:String {
            switch self {
            case .integer:  return "INTEGER"
            case .float:    return "FLOAT"
            case .text:     return "TEXT"
            case .blob:     return "BLOB"
            case .null:     return "NULL"
            }
        }
    }
}


