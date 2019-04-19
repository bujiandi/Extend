//
//  SQLite.swift
//  SQLite
//
//  Created by yFenFen on 16/5/18.
//  Copyright © 2016 yFenFen. All rights reserved.
//

import SQLite3
import Foundation


open class DBError : NSError {}


// MARK: - SQLite
open class SQLite {
    fileprivate var _path:String
    fileprivate var _onVersionUpdate:(_ db:Handle, _ oldVersion:Int, _ newVersion:Int) -> Bool
    fileprivate var _version:Int
    
    open var fullPath:String { return _path }
    public init(version:Int, name:String, onVersionUpdate:@escaping (_ db:Handle, _ oldVersion:Int, _ newVersion:Int) -> Bool) {
        let document = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
        _path = document.appendingPathComponent(name)
        _version = version
        _onVersionUpdate = onVersionUpdate
    }
    public init(version:Int, path:String, onVersionUpdate:@escaping (_ db:Handle, _ oldVersion:Int, _ newVersion:Int) -> Bool) {
        _path = path
        _version = version
        _onVersionUpdate = onVersionUpdate
    }
    
    open func open(_ mode:OpenMode = .readWriteCreate) throws -> Handle {
        var handle:OpaquePointer? = nil
        let dbPath:NSString = fullPath as NSString
        let dirPath = dbPath.deletingLastPathComponent
        let fileManager:FileManager = FileManager.default
        var isDir:ObjCBool = false
        
        if !fileManager.fileExists(atPath: dirPath, isDirectory: &isDir) || !isDir.boolValue {
            try fileManager.createDirectory(atPath: dirPath, withIntermediateDirectories: true, attributes: nil)
        }
//        sqlite3_shutdown();
//        sqlite3_config(SQLITE_CONFIG_SERIALIZED);
//        sqlite3_initialize();
        
        let result = sqlite3_open_v2(dbPath.utf8String, &handle, mode.rawValue, nil)
        if result != SQLITE_OK {
            let errorDescription = String(cString: sqlite3_errmsg(handle)) 
            sqlite3_close(handle)
            throw DBError(domain: errorDescription, code: Int(result), userInfo: nil)
        }
        let db = Handle(handle)
        let oldVersion = db.version
        if _version != oldVersion {
            if _onVersionUpdate(db, oldVersion, _version) {
                db.version = _version
            } else { print("未更新数据库版本:\(_version) old:\(oldVersion)") }
        }
        return db
    }
}




