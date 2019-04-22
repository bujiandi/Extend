//
//  DBHandle.swift
//  DataBase
//
//  Created by bujiandi on 2019/4/22.
//

import Foundation

public protocol DBHandle {
    
    var version:Int { get }
    
    var lastError:DBError { get }
    var lastSQL:String { get }
    
    // MARK: 执行SQL
    func exec(_ sql:String) throws
    func exec(_ sql:SQLBase) throws
    
    func query(_ sql:String) throws -> OpaquePointer
    
    var lastErrorMessage:String { get }
    var lastInsertRowID:Int64 { get }

    func beginTransaction(_ block:(DBTransaction) -> Void)
}


// MARK: - base execute sql function
extension DBHandle {
//    // 单表查询
//    public func query<Table, ResultSet>(_ sql:SQL<Table>) throws -> ResultSet where Table : DBTableType, ResultSet : DBResultSet, ResultSet.Table == Table {
//        return DBResultSet<T>(try query(sql.description))
//    }
//
//    // 双表查询
//    public func query<T1, T2>(_ sql:SQL2<T1, T2>) throws -> DBResultSet<T1> {
//        return DBResultSet<T1>(try query(sql.description))
//    }
    
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

// MARK: - transaction 事务
extension DBHandle {
    // MARK: 开启事务 BEGIN TRANSACTION
//    @discardableResult
//    func beginTransaction() -> CInt {
//        return sqlite3_exec(_handle,"BEGIN TRANSACTION",nil,nil,nil)
//    }
//    // MARK: 提交事务 COMMIT TRANSACTION
//    @discardableResult
//    func commitTransaction() -> CInt {
//        return sqlite3_exec(_handle,"COMMIT TRANSACTION",nil,nil,nil)
//    }
//    // MARK: 回滚事务 ROLLBACK TRANSACTION
//    @discardableResult
//    func rollbackTransaction() -> CInt {
//        return sqlite3_exec(_handle,"ROLLBACK TRANSACTION",nil,nil,nil)
//    }
}
