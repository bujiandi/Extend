//
//  SQLiteTransaction.swift
//  SQLite
//
//  Created by bujiandi on 2019/4/23.
//

import SQLite3
import DataBase

extension SQLite.Handle {
    
    open func beginTransaction(_ block:(DBTransaction) throws -> Void) rethrows {
        // 开启事务
        sqlite3_exec(_handle,"BEGIN TRANSACTION",nil,nil,nil)
        
        let transaction = SQLite.Transaction()
        
        try block(transaction)
        
        switch transaction.result {
        case .commit:
            sqlite3_exec(_handle,"COMMIT TRANSACTION",nil,nil,nil)
        case .rollback:
            sqlite3_exec(_handle,"ROLLBACK TRANSACTION",nil,nil,nil)
        }
    }
    
}

extension SQLite {
    
    fileprivate enum TransactionResult {
        case commit
        case rollback
    }
    
    fileprivate class Transaction: DBTransaction {
        
        var result:TransactionResult = .commit
        
        func commit() throws {
            result = .commit
        }
        
        func rollback() throws {
            result = .rollback
        }
        
    }
    
}
