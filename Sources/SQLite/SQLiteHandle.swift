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
    
    open class Handle {
        fileprivate var _handle:OpaquePointer?
        internal init (_ handle:OpaquePointer!) { _handle = handle }
        
        deinit { if _handle != nil { sqlite3_close(_handle) } }
        
        var version:Int {
            get {
                var stmt:OpaquePointer? = nil
                if SQLITE_OK == sqlite3_prepare_v2(_handle, "PRAGMA user_version", -1, &stmt, nil) {
                    defer { sqlite3_finalize(stmt) }
                    return SQLITE_ROW == sqlite3_step(stmt) ? Int(sqlite3_column_int(stmt, 0)) : 0
                }
                return -1
            }
            set { sqlite3_exec(_handle, "PRAGMA user_version = \(newValue)", nil, nil, nil) }
        }
        
        open var lastError:DBError {
            let errorCode = sqlite3_errcode(_handle)
            let errorDescription = String(cString: sqlite3_errmsg(_handle))
            return DBError(domain: errorDescription, code: Int(errorCode), userInfo: nil)
        }
        
        fileprivate var _lastSQL:String? //{ didSet { print(_lastSQL ?? "") } }
        open var lastSQL:String { return _lastSQL ?? "" }
        
        // MARK: 执行SQL
        open func exec(_ sql:String) throws {
            _lastSQL = sql
            let flag = sqlite3_exec(_handle, sql, nil, nil, nil)
            if flag != SQLITE_OK { throw lastError }
        }
        open func exec(_ sql:SQLBase) throws {
            try exec(sql.description)
        }
        
        fileprivate func query(_ sql:String) throws -> OpaquePointer {
            var stmt:OpaquePointer? = nil
            _lastSQL = sql
            if SQLITE_OK != sqlite3_prepare_v2(_handle, sql, -1, &stmt, nil) {
                sqlite3_finalize(stmt)
                throw lastError
            }
            return stmt! //DBRowSet(stmt)
        }
        
        open var lastErrorMessage:String {
            return String(cString: sqlite3_errmsg(_handle))
        }
        open var lastInsertRowID:Int64 {
            return sqlite3_last_insert_rowid(_handle)
        }
        
        public func transaction(_ operate: () -> TransactionResult) {
            // 开启事务
            sqlite3_exec(_handle,"BEGIN TRANSACTION",nil,nil,nil)
            
            // 执行事务内容
            let result = operate()
            
            // 执行事务结果
            switch result {
            case .rollback: // 回滚
                sqlite3_exec(_handle,"ROLLBACK TRANSACTION",nil,nil,nil)
            case .commit:   // 提交
                sqlite3_exec(_handle,"COMMIT TRANSACTION",nil,nil,nil)
            }
            
        }

    }

    
}

extension SQLite {
    
    public enum TransactionResult {
        case commit
        case rollback
    }
    
}

extension SQLite.Handle {
    
    // 单表查询
    public func query<T>(_ sql:SQL<T>) throws -> SQLite.ResultSet<T> {
        return SQLite.ResultSet<T>(try query(sql.description))
    }
    
    // 双表查询
    public func query<T1, T2>(_ sql:SQL2<T1, T2>) throws -> SQLite.ResultSet<T1> {
        return SQLite.ResultSet<T1>(try query(sql.description))
    }
    
    // 清空表
    public func truncateTable<T:DBTableType>(_:T.Type) throws {
        try exec(DELETE.FROM(T.self))
        try exec(UPDATE(SQLiteSequence.self).SET[.seq == 0].WHERE(.name == T.table_name))
    }
    
    // 创建表
    public func createTable<T:DBTableType>(_:T.Type) throws {
        try  createTable(T.self, otherSQL:"")
    }
    public func createTableIfNotExists<T:DBTableType>(_:T.Type) {
        try! createTable(T.self, otherSQL:" IF NOT EXISTS")
    }
    fileprivate func createTable<T:DBTableType>(_:T.Type, otherSQL:String) throws {
        var columns:[T] = []
        var primaryKeys:[T] = []
        for column in T.allCases where !column.option.contains(.DeletedKey) {
            if column.option.contains(.PrimaryKey) {
                primaryKeys.append(column)
            }
            columns.append(column)
        }
        
        var params:String = columns.map({
            if let value = $0.defaultValue?.description {
                return "\($0) \($0.type)\($0.option.descriptionBy(primaryKeys.count > 1)) DEFAULT \(value)"
            }
            return "\($0) \($0.type)\($0.option.descriptionBy(primaryKeys.count > 1))"
        }).joined(separator: ", ")
        
        
        if primaryKeys.count > 1 {
            let keys = primaryKeys.map({ "\($0)" }).joined(separator: ", ")
            params.append(", PRIMARY KEY (\(keys))")
        }
        
        try exec("CREATE TABLE\(otherSQL) \(T.table_name) (\(params))")
    }
}
