//
//  JSON+Copy.swift
//  Basic
//
//  Created by 李招利 on 2019/1/17.
//

import Foundation

public protocol Copyable {
    
    func copy() -> Self
    
}

extension JSON.Array: Copyable {
    
    public func copy() -> JSON.Array {
        return JSON.Array(rawValue.map { $0.copy() })
    }
    
}
extension JSON.Object: Copyable {
    
    public func copy() -> JSON.Object {
        let obj = JSON.Object()
        obj._keys = _keys
        obj._map = _map.mapValues { $0.copy() }
        return obj
    }
}

extension JSON: Copyable {
    
    public func copy() -> JSON {
        switch self {
        case let .array(array):
            return JSON.array(array.copy())
        case let .object(object):
            return JSON.object(object.copy())
        default: return self
        }
    }
    
}
