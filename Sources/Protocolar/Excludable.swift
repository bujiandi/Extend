//
//  Excludable.swift
//  Protocolar
//
//  Created by bujiandi on 2018/8/23.
//

//import Foundation

public protocol Excludable {}

extension Excludable {
    
    public func exclude(`where` condition: (Self) -> Bool) -> Self? {
        return condition(self) ? nil : self
    }

}

extension Excludable where Self : Equatable {
    
    public func exclude(_ value:Self) -> Self? {
        return self == value ? nil : self
    }

}

extension String  : Excludable {}

extension Int     : Excludable {}
extension Int8    : Excludable {}
extension Int16   : Excludable {}
extension Int32   : Excludable {}
extension Int64   : Excludable {}

extension UInt    : Excludable {}
extension UInt8   : Excludable {}
extension UInt16  : Excludable {}
extension UInt32  : Excludable {}
extension UInt64  : Excludable {}

extension Float32 : Excludable {}
extension Float64 : Excludable {}
//extension Float80 : Excludable {}



