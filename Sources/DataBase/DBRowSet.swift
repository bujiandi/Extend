//
//  DBRowSet.swift
//  DataBase
//
//  Created by bujiandi on 2019/4/22.
//

import Foundation

protocol DBRowSet: IteratorProtocol, Sequence {
    
    associatedtype Table: DBTableType
    
//    func map<T:DBTableType>(_: T.Type) -> T

    func getColumnIndex(_ column: Table) -> Int

    func getUInt(_ column: Table) -> UInt
    func getBool(_ column: Table) -> Bool
    func getInt(_ column: Table) -> Int
    func getInt64(_ column: Table) -> Int64
    func getDouble(_ column: Table) -> Double
    func getFloat(_ column: Table) -> Float
    func getString(_ column: Table) -> String!
    func getData(_ column: Table) -> Data!
    func getDate(_ column: Table) -> Date!

}
