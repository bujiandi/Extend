//
//  Emptiable.swift
//  Protocolar
//
//  Created by bujiandi on 2019/5/16.
//

public protocol Emptiable {
    var isEmpty:Bool { get }
}

extension String : Emptiable {}

extension Array : Emptiable {}

extension Set : Emptiable {}

extension ArraySlice : Emptiable {}

extension ContiguousArray : Emptiable {}

extension Emptiable {
    
    @inlinable public func ifEmpty(_ transform: @autoclosure () -> Self) -> Self {
        return ifEmpty(transform)
    }
    
    @inlinable func ifEmpty(_ transform:() -> Self) -> Self {
        return isEmpty ? transform() : self
    }
}
