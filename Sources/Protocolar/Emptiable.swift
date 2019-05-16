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

