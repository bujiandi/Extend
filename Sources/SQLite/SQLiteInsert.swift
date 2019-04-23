//
//  SQLiteInsert.swift
//  SQLite
//
//  Created by bujiandi on 2019/4/23.
//

import SQLite3
import DataBase

extension SQLInsert {
    
    open func VALUES<U>(_ values:[U], into db:DBHandle, binds:(_ id:Int64, _ value:U, _ bindSet:SQLite.BindSet<T>) throws -> () ) throws {
        if values.count == 0 {  return  }
        // 如果列字段为 * 则 遍历此表所有列
        if columns.isEmpty {
            for column in T.allCases where !column.option.contains(.DeletedKey)  {
                columns.append(column)
            }
        }
        let texts = [String](repeating: "?", count: columns.count).joined(separator: ", ")
//        handle.sql.append("VALUES(\(texts))")
        handle.add("VALUES(\(texts))")
        // TODO: 批量插入
        //print(_handle.sql.joinWithSeparator(" "))
        let stmt = try db.query(handle.description)
        //print(db.lastSQL)
        // 方法完成后释放 数据操作句柄
        //defer { sqlite3_finalize(stmt);print("释放插入句柄") }
        let bindSet = SQLite.BindSet<T>(stmt, columns)

        var lastInsertID:Int64 = 0
        var flag:CInt = SQLITE_ERROR
        // 获取最后一次插入的ID
        try db.beginTransaction { (transaction) in
            for i:Int in 0 ..< columns.count {
                let columnOption = columns[i].option
                let value:Int? = columnOption.contains(.NotNull) ? 1 : nil
                if !columnOption.contains(.PrimaryKey) {
                    try bindSet.bindValue(value, index: i + 1)
                } else if !columnOption.contains(.Autoincrement) {
                    try bindSet.bindValue(1, index: i + 1)
                }
            }
            flag = sqlite3_step(stmt)
            lastInsertID = max(db.lastInsertRowID, 1)       //sqlite3_last_insert_rowid(db.handle)
            try transaction.rollback()
        }
        
        // 获取最后一次插入的ID
//        db.beginTransaction()
//        var flag:CInt = SQLITE_ERROR
//        for i:Int in 0 ..< columns.count {
//            let columnOption = columns[i].option
//            let value:Int? = columnOption.contains(.NotNull) ? 1 : nil
//            if !columnOption.contains(.PrimaryKey) {
//                try bindSet.bindValue(value, index: i + 1)
//            } else if !columnOption.contains(.Autoincrement) {
//                try bindSet.bindValue(1, index: i + 1)
//            }
//        }
//        flag = sqlite3_step(stmt)
//        var lastInsertID = max(db.lastInsertRowID, 1)       //sqlite3_last_insert_rowid(db.handle)
//        db.rollbackTransaction()
        if flag == SQLITE_CONSTRAINT {
            // 不符合字段约束
            throw DBError(code: Int(flag), "Abort due to constraint violation \nSQL:\(handle)")
//                NSError(domain: "Abort due to constraint violation", code: Int(flag), userInfo: ["sql":_handle.sql.joined(separator: " ")])
        }
        sqlite3_reset(stmt)
        
        // 插入数据
        try db.beginTransaction { (transaction) in
            for value in values {
                // 推测本条数据插入ID为最后一条插入数据的ID + 1
                try binds(lastInsertID, value, bindSet)
                flag = sqlite3_step(stmt)
                if flag != SQLITE_OK && flag != SQLITE_DONE {
                    #if DEBUG
//                    fatalError("无法绑定数据[\(dict)] 到[\(columnFields)]")
                    #endif
                    bindSet.bindClear()     //如果失败则绑定下一组
                } else {
                    sqlite3_reset(stmt)
                    if lastInsertID == db.lastInsertRowID {
                        lastInsertID += 1
                    }
                }
            }
            sqlite3_finalize(stmt)
            if flag == SQLITE_OK || flag == SQLITE_DONE {
                flag = SQLITE_OK
                try transaction.commit()
            } else {
                try transaction.rollback()
                let errorDescription = db.lastErrorMessage
                print(db.lastSQL)
                throw DBError(code: Int(flag), errorDescription)
            }
        }


//        db.beginTransaction()

        
    }

    
}
