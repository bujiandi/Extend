//
//  DBResultSet.swift
//  DataBase
//
//  Created by bujiandi on 2019/4/22.
//

import Foundation

public protocol DBResultSet: IteratorProtocol, Sequence {
    
    associatedtype Table: DBTableType
    
    var row:Int { get }

    var step:CInt { get }

    func reset()

    func close()

    func firstValue() -> Int

    var columnCount:Int { get }
    var isClosed:Bool { get }
}
