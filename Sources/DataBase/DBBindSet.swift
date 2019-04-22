//
//  DBBindSet.swift
//  DataBase
//
//  Created by bujiandi on 2019/4/22.
//

import Foundation

public protocol DBBindSet {
    
    associatedtype Table: DBTableType

    var bindCount:CInt { get }
    
    @discardableResult
    func bindClear() -> CInt
    
    func bindValue<U>(_ value:U?, column:Table) throws
    // 泛型绑定
    func bindValue<U>(_ columnValue:U?, index:Int) throws
}
