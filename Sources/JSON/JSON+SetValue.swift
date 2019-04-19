//
//  JSON+SetValue.swift
//  TestJSON
//
//  Created by 李招利 on 2019/1/11.
//  Copyright © 2019 jwl. All rights reserved.
//

import Foundation

extension JSON {
    
    public static func uint64(_ value:UInt64) -> JSON {
        return JSON.number(Number(value))
    }
    
    public static func uint64<T>(_ value:T) -> JSON where T : RawRepresentable, T.RawValue == UInt64 {
        return JSON.number(Number(value.rawValue))
    }
    
    public static func uint32(_ value:UInt32) -> JSON {
        return JSON.number(Number(value))
    }
    
    public static func uint32<T>(_ value:T) -> JSON where T : RawRepresentable, T.RawValue == UInt32 {
        return JSON.number(Number(value.rawValue))
    }
    
    public static func uint16(_ value:UInt16) -> JSON {
        return JSON.number(Number(value))
    }
    
    public static func uint16<T>(_ value:T) -> JSON where T : RawRepresentable, T.RawValue == UInt16 {
        return JSON.number(Number(value.rawValue))
    }
    
    public static func uint8(_ value:UInt8) -> JSON {
        return JSON.number(Number(value))
    }
    
    public static func uint8<T>(_ value:T) -> JSON where T : RawRepresentable, T.RawValue == UInt8 {
        return JSON.number(Number(value.rawValue))
    }
    
    public static func uint(_ value:UInt) -> JSON {
        return JSON.number(Number(value))
    }
    
    public static func uint<T>(_ value:T) -> JSON where T : RawRepresentable, T.RawValue == UInt {
        return JSON.number(Number(value.rawValue))
    }
    
    public static func int64(_ value:Int64) -> JSON {
        return JSON.number(Number(value))
    }
    
    public static func int64<T>(_ value:T) -> JSON where T : RawRepresentable, T.RawValue == Int64 {
        return JSON.number(Number(value.rawValue))
    }
    
    public static func int32(_ value:Int32) -> JSON {
        return JSON.number(Number(value))
    }
    
    public static func int32<T>(_ value:T) -> JSON where T : RawRepresentable, T.RawValue == Int32 {
        return JSON.number(Number(value.rawValue))
    }
    
    public static func int16(_ value:Int16) -> JSON {
        return JSON.number(Number(value))
    }
    
    public static func int16<T>(_ value:T) -> JSON where T : RawRepresentable, T.RawValue == Int16 {
        return JSON.number(Number(value.rawValue))
    }
    
    public static func int8(_ value:Int8) -> JSON {
        return JSON.number(Number(value))
    }
    
    public static func int8<T>(_ value:T) -> JSON where T : RawRepresentable, T.RawValue == Int8 {
        return JSON.number(Number(value.rawValue))
    }
    
    public static func int(_ value:Int) -> JSON {
        return JSON.number(Number(value))
    }
    
    public static func int<T>(_ value:T) -> JSON where T : RawRepresentable, T.RawValue == Int {
        return JSON.number(Number(value.rawValue))
    }
    
    public static func double(_ value:Double) -> JSON {
        return JSON.number(Number(value))
    }
    
    public static func double<T>(_ value:T) -> JSON where T : RawRepresentable, T.RawValue == Double {
        return JSON.number(Number(value.rawValue))
    }
    
    public static func float(_ value:Float) -> JSON {
        return JSON.number(Number(value))
    }
    
    public static func decimal<T>(_ value:T) -> JSON where T : RawRepresentable, T.RawValue == Decimal {
        return JSON.number(Number(value.rawValue))
    }
    
    public static func decimal(_ value:Decimal) -> JSON {
        return JSON.number(Number(value))
    }
    
    public static func int<T>(_ value:T) -> JSON where T : RawRepresentable, T.RawValue == Float {
        return JSON.number(Number(value.rawValue))
    }
    
    public static func text(_ value:String?) -> JSON {
        if let text = value {
            return JSON.string(text)
        }
        return JSON.null
    }
    
    public static func text<T>(_ value:T) -> JSON where T : RawRepresentable, T.RawValue == String {
        return JSON.string(value.rawValue)
    }
    
    public static func text<T>(_ value:T) -> JSON where T : CustomStringConvertible {
        return JSON.string(value.description)
    }
    
    public static func list<S>(_ value:S) -> JSON where S : Sequence, S.Element == JSON {
        return JSON.array(Array(value))
    }
}
