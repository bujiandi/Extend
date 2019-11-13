//
//  File.swift
//  
//
//  Created by 慧趣小歪 on 2019/11/13.
//

import Foundation


public protocol Defaultable {
    static var defaultValue:Self { get }
}

extension String: Defaultable {
    public static let defaultValue = ""
}

extension Int: Defaultable {
    public static let defaultValue = 0
}

extension Int8: Defaultable {
    public static let defaultValue:Self = 0
}

extension Int16: Defaultable {
    public static let defaultValue:Self = 0
}

extension Int32: Defaultable {
    public static let defaultValue:Self = 0
}

extension Int64: Defaultable {
    public static let defaultValue:Self = 0
}

extension UInt: Defaultable {
    public static let defaultValue:Self = 0
}

extension UInt8: Defaultable {
    public static let defaultValue:Self = 0
}

extension UInt16: Defaultable {
    public static let defaultValue:Self = 0
}

extension UInt32: Defaultable {
    public static let defaultValue:Self = 0
}

extension UInt64: Defaultable {
    public static let defaultValue:Self = 0
}

extension Float: Defaultable {
    public static let defaultValue:Self = 0
}

extension Double: Defaultable {
    public static let defaultValue:Self = 0
}

extension Decimal: Defaultable {
    public static let defaultValue:Self = 0
}
