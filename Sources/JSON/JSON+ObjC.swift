//
//  JSON+ObjC.swift
//  TestJSON
//
//  Created by 李招利 on 2019/1/15.
//  Copyright © 2019 jwl. All rights reserved.
//

import Foundation

extension JSON.Object: ReferenceConvertible {

    public typealias ReferenceType = NSDictionary

}

extension JSON.Object: _ObjectiveCBridgeable {

    public typealias _ObjectiveCType = NSDictionary

    public func _bridgeToObjectiveC() -> NSDictionary {
        let dict = NSMutableDictionary()
        for key in _keys {
            dict[key._bridgeToObjectiveC()] = _map[key]?._bridgeToObjectiveC() ?? NSNull()
        }
        return dict.copy() as! NSDictionary
    }

    public static func _forceBridgeFromObjectiveC(_ source: NSDictionary, result: inout JSON.Object?) {
        result = JSON.Object(source)
    }

    public static func _conditionallyBridgeFromObjectiveC(_ source: NSDictionary, result: inout JSON.Object?) -> Bool {
        result = JSON.Object(source)
        return true
    }

    public static func _unconditionallyBridgeFromObjectiveC(_ source: NSDictionary?) -> JSON.Object {
        if let dict = source {
            return JSON.Object(dict)
        }
        return [:]
    }

}


extension JSON.Array: ReferenceConvertible {

    public typealias ReferenceType = NSArray

}

extension JSON.Array: _ObjectiveCBridgeable {

    public typealias _ObjectiveCType = NSArray

    public func _bridgeToObjectiveC() -> NSArray {
        return rawValue.map { $0._bridgeToObjectiveC() }._bridgeToObjectiveC()
    }

    public static func _forceBridgeFromObjectiveC(_ source: NSArray, result: inout JSON.Array?) {
        result = JSON.Array(source.map { JSON.from($0) })
    }

    public static func _conditionallyBridgeFromObjectiveC(_ source: NSArray, result: inout JSON.Array?) -> Bool {
        result = JSON.Array(source.map { JSON.from($0) })
        return true
    }

    public static func _unconditionallyBridgeFromObjectiveC(_ source: NSArray?) -> JSON.Array {
        return JSON.Array(source?.map { JSON.from($0) } ?? [])
    }

}

extension JSON.Number: ReferenceConvertible {

    public typealias ReferenceType = NSNumber

}

extension JSON.Number: _ObjectiveCBridgeable {

    public typealias _ObjectiveCType = NSNumber

    public func _bridgeToObjectiveC() -> NSNumber {
        if isInteger {
            return uint64Value._bridgeToObjectiveC() // as NSNumber
        } else if isFinite {
            return decimalValue._bridgeToObjectiveC()
        } else {
            return doubleValue._bridgeToObjectiveC()
        }
    }

    public static func _forceBridgeFromObjectiveC(_ source: NSNumber, result: inout JSON.Number?) {
        result = JSON.Number(source)
    }

    public static func _conditionallyBridgeFromObjectiveC(_ source: NSNumber, result: inout JSON.Number?) -> Bool {
        result = JSON.Number(source)
        return true
    }

    public static func _unconditionallyBridgeFromObjectiveC(_ source: NSNumber?) -> JSON.Number {
        if let value = source {
            return JSON.Number(value)
        } else {
            return JSON.Number.nan
        }
    }
}

extension JSON: _ObjectiveCBridgeable {

    public func _bridgeToObjectiveC() -> NSObject {
        switch self {
        case .null:                 return NSNull()
        case .bool(let value):      return value._bridgeToObjectiveC() // NSNumber(value: value)
        case .string(let string):   return string._bridgeToObjectiveC()
        case .number(let number):   return number._bridgeToObjectiveC()
        case .array(let array):     return array._bridgeToObjectiveC()
        case .object(let object):   return object._bridgeToObjectiveC()
        case .error(let error, _):  return error as NSError
        }
    }

    public static func _forceBridgeFromObjectiveC(_ source: NSObject, result: inout JSON?) {
        result = JSON.from(source)
    }

    public static func _conditionallyBridgeFromObjectiveC(_ source: NSObject, result: inout JSON?) -> Bool {
        if source.isKind(of: NSNull.self) {
            result = JSON.null
        } else if source.isKind(of: NSNumber.self) || source.isKind(of: NSDecimalNumber.self) {
            result = JSON.number(Number(source as! NSNumber))
        } else if source.isKind(of: NSDictionary.self) || source.isKind(of: NSMutableDictionary.self) {
            result = JSON.object(Object(source as! NSDictionary))
        } else if source.isKind(of: NSArray.self) || source.isKind(of: NSMutableArray.self) {
            result = JSON.array(Array((source as! NSArray).map { JSON.from($0) }))
        } else if source.isKind(of: NSString.self) || source.isKind(of: NSMutableString.self) {
            result = JSON.string(source as! String)
        } else if source.isKind(of: NSSet.self) || source.isKind(of: NSMutableSet.self) {
            result = JSON.array(Array((source as! NSSet).map { JSON.from($0) }))
        } else {
            return false
        }
        return true
    }

    public static func _unconditionallyBridgeFromObjectiveC(_ source: NSObject?) -> JSON {
        guard let obj = source else { return JSON.null }
        var json:JSON? = nil
        if _conditionallyBridgeFromObjectiveC(obj, result: &json) {
            return json ?? JSON.null
        }
        return JSON.null
    }
}

//extension JSON: ReferenceConvertible {
//
//    public typealias ReferenceType = NSObject
//
//}
