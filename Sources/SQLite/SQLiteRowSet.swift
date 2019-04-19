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
    
    open class RowSetBase {
        internal var _stmt:OpaquePointer? = nil
        internal let _columns:[String]
        
        internal init (_ stmt:OpaquePointer,_ columns:[String]) {
            _stmt = stmt
            _columns = columns
        }
        
        open func getDictionary() -> [String:Any] {
            var dict:[String:Any] = [:]
            for i in 0..<_columns.count {
                let index = CInt(i)
                let type = sqlite3_column_type(_stmt, index);
                let key:String = _columns[i]
                var value:Any? = nil
                switch type {
                case SQLITE_INTEGER:
                    value = Int64(sqlite3_column_int64(_stmt, index))
                case SQLITE_FLOAT:
                    value = Double(sqlite3_column_double(_stmt, index))
                case SQLITE_TEXT:
                    let text:UnsafePointer<UInt8> = sqlite3_column_text(_stmt, index)
                    value = String(cString: text)
                case SQLITE_BLOB:
                    let data:UnsafeRawPointer = sqlite3_column_blob(_stmt, index)
                    let size:CInt = sqlite3_column_bytes(_stmt, index)
                    value = Data(bytes: data, count: Int(size))
                case SQLITE_NULL:   fallthrough     //下降关键字 执行下一 CASE
                default :           break           //什么都不执行
                }
                dict[key] = value
//                //如果出现重名则
//                if i != columnNames.indexOfObject(key) {
//                    //取变量类型
//                    //let tableName = String.fromCString(sqlite3_column_table_name(stmt, index))
//                    //dict["\(tableName).\(key)"] = value
//                    dict["\(key).\(i)"] = value
//                } else {
//                    dict[key] = value
//                }
            }
            
            return dict
        }
        open func getInt64(_ columnIndex:Int) -> Int64 {
            return sqlite3_column_int64(_stmt, CInt(columnIndex))
        }
        open func getUInt64(_ columnIndex:Int) -> UInt64 {
            return UInt64(bitPattern: getInt64(columnIndex))
        }
        open func getInt(_ columnIndex:Int) -> Int {
            return Int(truncatingIfNeeded: getInt64(columnIndex))
        }
        open func getUInt(_ columnIndex:Int) -> UInt {
            return UInt(truncatingIfNeeded: getInt64(columnIndex))
        }
        open func getInt8(_ columnIndex:Int) -> Int8 {
            return Int8(truncatingIfNeeded: getInt64(columnIndex))
        }
        open func getUInt8(_ columnIndex:Int) -> UInt8 {
            return UInt8(truncatingIfNeeded: getInt64(columnIndex))
        }
        open func getInt16(_ columnIndex:Int) -> Int16 {
            return Int16(truncatingIfNeeded: getInt64(columnIndex))
        }
        open func getUInt16(_ columnIndex:Int) -> UInt16 {
            return UInt16(truncatingIfNeeded: getInt64(columnIndex))
        }
        open func getInt32(_ columnIndex:Int) -> Int32 {
            return Int32(truncatingIfNeeded: getInt64(columnIndex))
        }
        open func getUInt32(_ columnIndex:Int) -> UInt32 {
            return UInt32(truncatingIfNeeded: getInt64(columnIndex))
        }
        open func getBool(_ columnIndex:Int) -> Bool {
            return getInt64(columnIndex) != 0
        }
        open func getFloat(_ columnIndex:Int) -> Float {
            return Float(sqlite3_column_double(_stmt, CInt(columnIndex)))
        }
        open func getDouble(_ columnIndex:Int) -> Double {
            return sqlite3_column_double(_stmt, CInt(columnIndex))
        }
        open func getString(_ columnIndex:Int) -> String? {
            guard let result = sqlite3_column_text(_stmt, CInt(columnIndex)) else {
                return nil
            }
            return String(cString: result)
        }
        
        open func getColumnIndex(_ columnName: String) -> Int {
            return _columns.firstIndex(where: { $0 == columnName.lowercased() }) ?? NSNotFound
        }
        
        open var columnCount:Int { return _columns.count }
    }
    
    open class RowSet<T:DBTableType>: RowSetBase {
        internal override init(_ stmt: OpaquePointer,_ columns:[String]) {
            super.init(stmt, columns)
        }
        
        public init <U>(_ rs:RowSet<U>) {
            super.init(rs._stmt!, rs._columns)
        }
        
        open func getColumnIndex(_ column: T) -> Int {
            return _columns.firstIndex(where: { $0 == "\(column)".lowercased() }) ?? NSNotFound
        }
        
        
        open func getUInt(_ column: T) -> UInt {
            return UInt(truncatingIfNeeded: getInt64(column))
        }
        open func getBool(_ column: T) -> Bool {
            return getInt64(column) != 0
        }
        open func getInt(_ column: T) -> Int {
            return Int(truncatingIfNeeded: getInt64(column))
        }
        open func getInt64(_ column: T) -> Int64 {
            guard let index = _columns.firstIndex(where: { $0 == "\(column)".lowercased() }) else {
                return 0
            }
            return sqlite3_column_int64(_stmt, CInt(index))
        }
        open func getDouble(_ column: T) -> Double {
            guard let index = _columns.firstIndex(where: { $0 == "\(column)".lowercased() }) else {
                return 0
            }
            return sqlite3_column_double(_stmt, CInt(index))
        }
        open func getFloat(_ column: T) -> Float {
            return Float(getDouble(column))
        }
        open func getString(_ column: T) -> String! {
            guard let index = _columns.firstIndex(where: { $0 == "\(column)".lowercased() }) else {
                return nil
            }
            guard let data = sqlite3_column_text(_stmt, CInt(index)) else {
                return nil
            }
            return String(cString: data)
        }
        open func getData(_ column: T) -> Data! {
            guard let index = _columns.firstIndex(where: { $0 == "\(column)".lowercased() }) else {
                return nil
            }
            let data:UnsafeRawPointer = sqlite3_column_blob(_stmt, CInt(index))
            let size:CInt = sqlite3_column_bytes(_stmt, CInt(index))
            return Data(bytes: data, count: Int(size))
        }
        open func getDate(_ column: T) -> Date! {
            guard let index = _columns.firstIndex(where: { $0 == "\(column)".lowercased() }) else {
                return nil
            }
            let columnType = sqlite3_column_type(_stmt, CInt(index))
            
            switch columnType {
            case SQLITE_INTEGER:
                fallthrough
            case SQLITE_FLOAT:
                let time = sqlite3_column_double(_stmt, CInt(index))
                return Date(timeIntervalSince1970: time)
            case SQLITE_TEXT:
                let date = String(cString: sqlite3_column_text(_stmt, CInt(index)))
                let formater = DateFormatter()
                formater.dateFormat = "yyyy-MM-dd HH:mm:ss"
                //formater.calendar = NSCalendar.currentCalendar()
                return formater.date(from: date)
            default:
                return nil
            }
            
        }
    }
}

extension SQLite.RowSetBase {
    /// Decodes a top-level value of the given type from the given JSON representation.
    ///
    /// - parameter type: The type of the value to decode.
    /// - parameter data: The data to decode from.
    /// - returns: A value of the requested type.
    /// - throws: `DecodingError.dataCorrupted` if values requested from the payload are corrupted, or if the given data is not valid JSON.
    /// - throws: An error if any value throws an error during decoding.
    public func decode<T>(_ :T.Type) throws -> T where T : Decodable {
        return try T(from: SQLite.RowDecoder(self))
    }
}
