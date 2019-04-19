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
    
    open class BindSet<T:DBTableType> {
        
        fileprivate var _stmt:OpaquePointer
        fileprivate var _columns:[T]
        init(_ stmt: OpaquePointer,_ columns:[T]) {
            _stmt = stmt
            _columns = columns
        }
        
        open var bindCount:CInt {
            return sqlite3_bind_parameter_count(_stmt)
        }
        
        @discardableResult
        open func bindClear() -> CInt {
            return sqlite3_clear_bindings(_stmt)
        }
        
        open func bindValue<U>(_ value:U?, column:T) throws {
            if let index = _columns.firstIndex(of: column) {
                if value == nil && column.option.contains(.NotNull) {
                    print("\(column) 不能为Null, 可能导致绑定失败")
                }
                try bindValue(value, index: index + 1)
            } else {
                print("SQL中不存在 列:\(column)")
                throw DBError(domain: "SQL中不存在 列:\(column)", code: -1, userInfo: nil)
            }
        }
        // 泛型绑定
        open func bindValue<U>(_ columnValue:U?, index:Int) throws {
            
            var flag:CInt = SQLITE_ROW
            if let v = columnValue {
                switch v {
                case _ as NSNull:
                    flag = sqlite3_bind_null(_stmt,CInt(index))
                case _ as DataBaseNull:
                    flag = sqlite3_bind_null(_stmt,CInt(index))
                case let value as String:
                    let string:NSString = value as NSString
                    flag = sqlite3_bind_text(_stmt,CInt(index),string.utf8String,-1,nil)
                case let value as Int:
                    flag = sqlite3_bind_int64(_stmt,CInt(index),CLongLong(value))
                case let value as UInt:
                    flag = sqlite3_bind_int64(_stmt,CInt(index),CLongLong(value))
                case let value as Int8:
                    flag = sqlite3_bind_int(_stmt,CInt(index),CInt(value))
                case let value as UInt8:
                    flag = sqlite3_bind_int(_stmt,CInt(index),CInt(value))
                case let value as Int16:
                    flag = sqlite3_bind_int(_stmt,CInt(index),CInt(value))
                case let value as UInt16:
                    flag = sqlite3_bind_int(_stmt,CInt(index),CInt(value))
                case let value as Int32:
                    flag = sqlite3_bind_int(_stmt,CInt(index),CInt(value))
                case let value as UInt32:
                    flag = sqlite3_bind_int64(_stmt,CInt(index),CLongLong(value))
                case let value as Int64:
                    flag = sqlite3_bind_int64(_stmt,CInt(index),CLongLong(value))
                case let value as UInt64:
                    flag = sqlite3_bind_int64(_stmt,CInt(index),CLongLong(value))
                case let value as Float:
                    flag = sqlite3_bind_double(_stmt,CInt(index),CDouble(value))
                case let value as Double:
                    flag = sqlite3_bind_double(_stmt,CInt(index),CDouble(value))
                case let value as Date:
                    flag = sqlite3_bind_double(_stmt,CInt(index),CDouble(value.timeIntervalSince1970))
//                case let value as Date:
//                    return sqlite3_bind_double(_stmt,CInt(index),CDouble(value.timeIntervalSince1970))
                case let value as Data:
                    flag = sqlite3_bind_blob(_stmt,CInt(index),(value as NSData).bytes,-1,nil)
                default:
                    let mirror = Mirror(reflecting: v)
                    if mirror.displayStyle == .optional {
                        let children = mirror.children
                        if children.count == 0 {
                            flag = sqlite3_bind_null(_stmt,CInt(index))
                        } else {
                            try bindValue(children[children.startIndex].value, index: index)
                        }
                    } else {
                        let string:NSString = "\(v)" as NSString
                        flag = sqlite3_bind_text(_stmt,CInt(index),string.utf8String,-1,nil)
                    }
                }
            } else {
                flag = sqlite3_bind_null(_stmt,CInt(index))
            }
            if flag != SQLITE_OK && flag != SQLITE_ROW {
                throw DBError(domain: "批量插入失败", code: Int(flag), userInfo: nil)
            }
        }
    }
    
}
