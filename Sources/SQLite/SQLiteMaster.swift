//
//  SQLiteMaster.swift
//  SQLite
//
//  Created by bujiandi on 2019/4/23.
//

import DataBase

public enum SQLiteMaster:String, DBTableType {
    
    public typealias ColumnType = SQLiteColumnType
    
    case type
    case name
    case tbl_name
    case rootpage
    case sql
    
    public var type: SQLiteColumnType {
        switch self {
        case .rootpage: return .integer
        default : return .text
        }
    }
    public var option: DBColumnOptions {
        return .NotNull
    }
    public static let table_name:String = "sqlite_master"
}
