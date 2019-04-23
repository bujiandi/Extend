//
//  DBColumnOptions.swift
//  DataBase
//
//  Created by bujiandi on 2019/4/23.
//

public protocol DBColumnOptionsProtocol : OptionSet, CustomStringConvertible {
    
}

// MARK: - ColumnState 头附加状态
public struct DBColumnOptions : OptionSet, DBColumnOptionsProtocol, CustomStringConvertible {
    
    public let rawValue: Int
    public init(rawValue value: Int) { rawValue = value }
    
    public static let None                  = DBColumnOptions(rawValue: 0)
    public static let PrimaryKey            = DBColumnOptions(rawValue: 1 << 0)
    public static let Autoincrement         = DBColumnOptions(rawValue: 1 << 1)
    public static let PrimaryKeyAutoincrement:DBColumnOptions = [PrimaryKey, Autoincrement]
    public static let NotNull               = DBColumnOptions(rawValue: 1 << 2)
    public static let Unique                = DBColumnOptions(rawValue: 1 << 3)
    public static let Check                 = DBColumnOptions(rawValue: 1 << 4)
    public static let ForeignKey            = DBColumnOptions(rawValue: 1 << 5)
    public static let DeletedKey            = DBColumnOptions(rawValue: 1 << 6)
    
    @inlinable public var description:String {
        return descriptionBy(false)
    }
    
    @inlinable public func descriptionBy(_ morePrimaryKey:Bool) -> String {
        var result = ""
        
        if !morePrimaryKey && contains(.PrimaryKey) { result.append(" PRIMARY KEY") }
        if contains(.Autoincrement) { result.append(" AUTOINCREMENT") }
        if contains(.NotNull)       { result.append(" NOT NULL") }
        if contains(.Unique)        { result.append(" UNIQUE") }
        if contains(.Check)         { result.append(" CHECK") }
        //if contains(.ForeignKey)    { result.appendContentsOf(" FOREIGN KEY") }
        
        return result
    }
}
