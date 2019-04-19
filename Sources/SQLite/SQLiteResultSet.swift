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
    
    open class ResultSet<T:DBTableType>: IteratorProtocol, Sequence {
        public typealias Element = RowSet<T>
        
        internal var _stmt:OpaquePointer? = nil
        internal init (_ stmt:OpaquePointer) {
            _stmt = stmt
            let length = sqlite3_column_count(_stmt);
            var columns:[String] = []
            for i:CInt in 0..<length {
                let name:UnsafePointer<CChar> = sqlite3_column_name(_stmt,i)
                
                columns.append(String(cString: name).lowercased())
            }
            //print(columns)
            _columns = columns
        }
        deinit {
            if _stmt != nil {
                sqlite3_finalize(_stmt)
            }
        }
        
        open var row:Int {
            return Int(sqlite3_data_count(_stmt))
        }
        
        open var step:CInt {
            return sqlite3_step(_stmt)
        }
        
        open func reset() {
            sqlite3_reset(_stmt)
        }
        
        open func close() {
            if _stmt != nil {
                sqlite3_finalize(_stmt)
                _stmt = nil
            }
        }
        
        open func next() -> RowSet<T>? {
            return step != SQLITE_ROW ? nil : RowSet<T>(_stmt!, _columns)
        }
        
        open func firstValue() -> Int {
            if step == SQLITE_ROW {
                return Int(sqlite3_column_int(_stmt, 0))
            }
            return 0
        }
        
        fileprivate let _columns:[String]
        open var columnCount:Int { return _columns.count }
        open var isClosed:Bool { return _stmt == nil }
    }

    
}
