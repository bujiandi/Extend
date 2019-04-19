//
//  JSON+Literal.swift
//  TestJSON
//
//  Created by 李招利 on 2019/1/8.
//  Copyright © 2019 jwl. All rights reserved.
//

import Foundation

extension JSON : ExpressibleByDictionaryLiteral {
    
    public typealias Key = String
    public typealias Value = Any?
    
    public init(dictionaryLiteral elements: (Key, Value)...) {
        let obj = JSON.Object()
        for (k, v) in elements {
            obj.append(value: JSON.from(v), for: k)
        }
        self = .object(obj)
    }
}

extension JSON : ExpressibleByArrayLiteral {
    public typealias Element = JSON
    public init(arrayLiteral elements: Element...) {
        self = JSON.from(elements)
    }
}

extension JSON : ExpressibleByStringLiteral, ExpressibleByUnicodeScalarLiteral, ExpressibleByExtendedGraphemeClusterLiteral {
    
    public typealias StringLiteralType = StaticString
    public typealias UnicodeScalarLiteralType = UnicodeScalarType
    public typealias ExtendedGraphemeClusterLiteralType = ExtendedGraphemeClusterType
    
    public init(extendedGraphemeClusterLiteral value: ExtendedGraphemeClusterLiteralType) {
        self = .string(value.description)
    }
    
    public init(unicodeScalarLiteral value: UnicodeScalarLiteralType) {
        self = .string(value.description)
    }
    
    public init(stringLiteral value: StringLiteralType) {
        self = .string(value.description)
    }
}

extension JSON : ExpressibleByFloatLiteral {
    
    public typealias FloatLiteralType = Double
    
    public init(floatLiteral value: FloatLiteralType) {
        self = .number(JSON.Number(value))
    }
    
}

extension JSON : ExpressibleByBooleanLiteral {
    public typealias BooleanLiteralType = Bool
    
    public init(booleanLiteral value: BooleanLiteralType) {
        self = .bool(value)
    }
}

extension JSON : ExpressibleByIntegerLiteral {
    public typealias IntegerLiteralType = Int
    
    public init(integerLiteral value: IntegerLiteralType) {
        self = .number(JSON.Number(value))
    }
}

extension JSON : ExpressibleByNilLiteral {
    
    public init(nilLiteral: ()) {
        self = .null
    }
}
