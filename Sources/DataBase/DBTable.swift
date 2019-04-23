//
//  DBTable.swift
//  DataBase
//
//  Created by bujiandi on 2019/4/22.
//

//import Foundation


// MARK: - protocols 接口(创建数据表需用枚举实现以下接口)
/// 注: enum OneTable: String, DBTableType
public protocol DBTableType: RawRepresentable, CaseIterable, Hashable {
    
    associatedtype ColumnType : DBColumnTypeProtocol
//    associatedtype ColumnOptions : DBColumnOptionsProtocol
    
    static var table_name:String { get }
    
    var type: ColumnType { get }
    var option: DBColumnOptions { get }
    var defaultValue:CustomStringConvertible? { get }
}

// MARK: - 遍历枚举
extension DBTableType {
    
    public var defaultValue:CustomStringConvertible? { return nil }
    
    fileprivate static func enumerateEnum<T: Hashable>(_: T.Type) -> AnyIterator<T> {
        var i = 0
        return AnyIterator {
            let next = withUnsafePointer(to: &i) { p in
                p.withMemoryRebound(to: T.self, capacity: 1) { $0.pointee }
            }
            defer { i += 1 }
            return next.hashValue == i ? next : nil
        }
    }
    
    public static func enumerate() -> AnyIterator<Self> {
        return enumerateEnum(Self.self)
    }
}
