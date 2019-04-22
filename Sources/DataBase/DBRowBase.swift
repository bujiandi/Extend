//
//  DBRowBase.swift
//  DataBase
//
//  Created by bujiandi on 2019/4/22.
//

import Foundation

public protocol DBRowBase {
    
    func getInt64(_ columnIndex:Int) -> Int64
    func getUInt64(_ columnIndex:Int) -> UInt64
    func getInt(_ columnIndex:Int) -> Int
    func getUInt(_ columnIndex:Int) -> UInt
    func getInt8(_ columnIndex:Int) -> Int8
    func getUInt8(_ columnIndex:Int) -> UInt8
    func getInt32(_ columnIndex:Int) -> Int32
    func getUInt32(_ columnIndex:Int) -> UInt32
    func getBool(_ columnIndex:Int) -> Bool
    func getFloat(_ columnIndex:Int) -> Float
    func getDouble(_ columnIndex:Int) -> Double
    func getString(_ columnIndex:Int) -> String?
    func getData(_ columnIndex:Int) -> Data?
    func getDate(_ columnIndex:Int) -> Date?
    func getColumnIndex(_ columnName: String) -> Int
    
    var columnCount:Int { get }
    var row:Int { get }
    var step:CInt { get }
    var isClosed:Bool { get }
    func close()
    func reset()
    func firstValue() -> Int

}
