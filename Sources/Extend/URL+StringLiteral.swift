//
//  URL+StringLiteral.swift
//  Tools
//
//  Created by bujiandi on 2017/8/5.
//
//

import Foundation

extension URL : ExpressibleByStringLiteral {
    
    public typealias StringLiteralType = StaticString
    public typealias UnicodeScalarLiteralType = UnicodeScalar
    public typealias ExtendedGraphemeClusterLiteralType = String
    
    public init(extendedGraphemeClusterLiteral value: ExtendedGraphemeClusterLiteralType) {
        self.init(string: value)!
    }
    public init(unicodeScalarLiteral value: UnicodeScalarLiteralType) {
        self.init(string: value.description)!
    }
    public init(stringLiteral value: StringLiteralType) {
        self.init(string: value.description)!
    }
    
}

