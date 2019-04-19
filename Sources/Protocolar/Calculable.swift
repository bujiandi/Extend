//
//  Calculable.swift
//  Protocolar
//
//  Created by bujiandi on 2018/11/24.
//


public protocol Calculable: Comparable {
    
    static func + (lhs: Self, rhs: Self) -> Self
    static func - (lhs: Self, rhs: Self) -> Self
    static func * (lhs: Self, rhs: Self) -> Self
    static func / (lhs: Self, rhs: Self) -> Self
    
}

extension Int       : Calculable {}
extension Int8      : Calculable {}
extension Int16     : Calculable {}
extension Int32     : Calculable {}
extension Int64     : Calculable {}
extension UInt      : Calculable {}
extension UInt8     : Calculable {}
extension UInt16    : Calculable {}
extension UInt32    : Calculable {}
extension UInt64    : Calculable {}
extension Float     : Calculable {}
extension Double    : Calculable {}
