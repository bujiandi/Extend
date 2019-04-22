//
//  DBTransaction.swift
//  DataBase
//
//  Created by bujiandi on 2019/4/22.
//

public protocol DBTransaction {
    func commit() throws
    func rollback() throws
}
