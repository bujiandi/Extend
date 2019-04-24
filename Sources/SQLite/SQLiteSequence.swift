//
//  SQLiteSequence.swift
//  SQLite
//
//  Created by bujiandi on 2019/4/23.
//

import DataBase

// MARK: - SQLite 默认序列表
extension SQLite {
    
    public enum Sequence:String, DBTableType {
        
        public typealias ColumnType = SQLite.ColumnType
        
        case name
        case seq
        
        public var type: ColumnType {
            switch self {
            case .name: return .text
            case .seq : return .integer
            }
        }
        public var option: DBColumnOptions {
            switch self {
            case .name: return .PrimaryKey
            default:    return .NotNull
            }
        }
        public static let table_name:String = "sqlite_sequence"
    }
    
    
}
