//
//  SQLiteSequence.swift
//  SQLite
//
//  Created by bujiandi on 2019/4/23.
//

import DataBase

// MARK: - SQLite 默认序列表
public enum SQLiteSequence:String, DBTableType {
    
    public typealias ColumnType = SQLiteColumnType
    
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


extension DBHandle {
    
    // 清空表
    public func truncateTable<T:DBTableType>(_:T.Type) throws {
        try exec(DELETE.FROM(T.self))
        try exec(UPDATE(SQLiteSequence.self).SET[.seq == 0].WHERE(.name == T.table_name))
    }
}
