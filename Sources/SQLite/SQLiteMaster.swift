//
//  SQLiteMaster.swift
//  SQLite
//
//  Created by bujiandi on 2019/4/23.
//

import DataBase

extension SQLite {
    
    public enum Master:String, DBTableType {
        
        public typealias ColumnType = SQLite.ColumnType
        
        case type
        case name
        case tbl_name
        case rootpage
        case sql
        
        public var type: ColumnType {
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

}
