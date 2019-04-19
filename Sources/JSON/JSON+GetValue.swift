//
//  JSON+GetValue.swift
//  TestJSON
//
//  Created by 李招利 on 2019/1/10.
//  Copyright © 2019 jwl. All rights reserved.
//

import Foundation

#if canImport(Basic)

extension Optional where Wrapped == JSON {
    
    public var safeUnwrap:Wrapped {
        return self ?? .null
    }
}

#endif

extension JSON {
    
    public var array:[JSON] {
        if case .array(let list) = self { return list.rawValue }
        return []
    }
    
    public var isArray:Bool {
        if case .array = self { return true }
        return false
    }
    public var isObject:Bool {
        if case .object = self { return true }
        return false
    }
    public var isNumber:Bool {
        if case .number = self { return true }
        return false
    }
    public var isString:Bool {
        if case .string = self { return true }
        return false
    }
    public var isNullOrError:Bool {
        if case .null = self { return true }
        if case .error = self { return true }
        return false
    }
    public var isNull:Bool {
        if case .null = self { return true }
        return false
    }
    public var isError:Bool {
        if case .error = self { return true }
        return false
    }
    
    public var optionalString:String? {
        switch self {
        case let .string(text): return text
        case let .number(aNum): return aNum.rawValue
        case let .bool(value):  return value ? "true" : "false"
        case let .array(list):  return list.description
        case let .object(obj):  return obj.description
        case let .error(error, ignore):
            #if DEBUG
            fatalError(error.debugDescription + ", ignore path:\(ignore.joinPath)")
            #else
            return nil
            #endif
        case .null: return nil
        }
    }
    
    public var string:String {
        if case .null = self { return "null" }
        return optionalString ?? ""
    }
    
    public var optionalInt:Int? {
        switch self {
        case let .string(text): return Int(text)
        case let .number(aNum): return aNum.intValue
        case let .bool(value):  return value ? 1 : 0
        case let .array(list):  return list.count
        case let .object(obj):  return obj.count
        case let .error(error, ignore):
            #if DEBUG
            fatalError(error.debugDescription + ", ignore path:\(ignore.joinPath)")
            #else
            return nil
            #endif
        case .null: return nil
        }
    }
    
    public var int:Int {
        return optionalInt ?? 0
    }
    
    
    public var optionalFloat:Float? {
        switch self {
        case let .string(text): return Float(text)
        case let .number(aNum): return aNum.floatValue
        case let .bool(value):  return value ? 1 : 0
        case let .error(error, ignore):
            #if DEBUG
            fatalError(error.debugDescription + ", ignore path:\(ignore.joinPath)")
            #else
            return nil
            #endif
        default: return nil
        }
    }
    
    public var float:Float {
        return optionalFloat ?? 0
    }
    
    public var optionalBool:Bool? {
        switch self {
        case let .string(text):
            return (text == "true" || text == "1") ? true : (text == "false" || text == "0" ? false : nil)
        case let .number(aNum): return aNum.doubleValue != 0
        case let .bool(value):  return value
        case let .error(error, ignore):
            #if DEBUG
            fatalError(error.debugDescription + ", ignore path:\(ignore.joinPath)")
            #else
            return nil
            #endif
        default: return nil
        }
    }
    public var bool:Bool { return optionalBool ?? false }
    
    public var optionalDouble:Double? {
        switch self {
        case let .string(text): return Double(text)
        case let .number(aNum): return aNum.doubleValue
        case let .bool(value):  return value ? 1 : 0
        case let .error(error, ignore):
            #if DEBUG
            fatalError(error.debugDescription + ", ignore path:\(ignore.joinPath)")
            #else
            return nil
            #endif
        default: return nil
        }
    }
    public var double:Double { return optionalDouble ?? 0 }
    
    public var optionalDecimal:Decimal? {
        switch self {
        case let .string(text): return Decimal(string: text)
        case let .number(aNum): return aNum.decimalValue
        case let .bool(value):  return value ? 1 : 0
        case let .error(error, ignore):
            #if DEBUG
            fatalError(error.debugDescription + ", ignore path:\(ignore.joinPath)")
            #else
            return nil
            #endif
        default: return nil
        }
    }
    
    public var decimal:Decimal {
        return optionalDecimal ?? 0
    }
    
    public var uint:UInt {
        switch self {
        case let .string(text): return UInt(text) ?? 0
        case let .number(aNum): return aNum.uintValue
        case let .bool(value):  return value ? 1 : 0
        case let .array(list):  return UInt(list.count)
        case let .object(obj):  return UInt(obj.count)
        case let .error(error, ignore):
            #if DEBUG
            fatalError(error.debugDescription + ", ignore path:\(ignore.joinPath)")
            #else
            return 0
            #endif
        case .null: return 0
        }
    }
    
    public var int64:Int64 {
        switch self {
        case let .string(text): return Int64(text) ?? 0
        case let .number(aNum): return aNum.int64Value
        case let .bool(value):  return value ? 1 : 0
        case let .array(list):  return Int64(list.count)
        case let .object(obj):  return Int64(obj.count)
        case let .error(error, ignore):
            #if DEBUG
            fatalError(error.debugDescription + ", ignore path:\(ignore.joinPath)")
            #else
            return 0
            #endif
        case .null: return 0
        }
    }
    
    public var int32:Int32 {
        switch self {
        case let .string(text): return Int32(text) ?? 0
        case let .number(aNum): return aNum.int32Value
        case let .bool(value):  return value ? 1 : 0
        case let .array(list):  return Int32(list.count)
        case let .object(obj):  return Int32(obj.count)
        case let .error(error, ignore):
            #if DEBUG
            fatalError(error.debugDescription + ", ignore path:\(ignore.joinPath)")
            #else
            return 0
            #endif
        case .null: return 0
        }
    }
    
    public var int16:Int16 {
        switch self {
        case let .string(text): return Int16(text) ?? 0
        case let .number(aNum): return aNum.int16Value
        case let .bool(value):  return value ? 1 : 0
        case let .array(list):  return Int16(list.count)
        case let .object(obj):  return Int16(obj.count)
        case let .error(error, ignore):
            #if DEBUG
            fatalError(error.debugDescription + ", ignore path:\(ignore.joinPath)")
            #else
            return 0
            #endif
        case .null: return 0
        }
    }
    
    public var int8:Int8 {
        switch self {
        case let .string(text): return Int8(text) ?? 0
        case let .number(aNum): return aNum.int8Value
        case let .bool(value):  return value ? 1 : 0
        case let .array(list):  return Int8(list.count)
        case let .object(obj):  return Int8(obj.count)
        case let .error(error, ignore):
            #if DEBUG
            fatalError(error.debugDescription + ", ignore path:\(ignore.joinPath)")
            #else
            return 0
            #endif
        case .null: return 0
        }
    }
    
}


extension Array where Element == String {
    
    fileprivate var joinPath:String {
        return joined(separator: "/")
    }
    
}
