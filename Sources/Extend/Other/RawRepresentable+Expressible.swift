//
//  RawRepresentable+Expressible.swift
//  Basic
//
//  Created by 小歪 on 2018/6/20.
//

import Foundation

extension RawRepresentable {
    /// 枚举遍历聚合函数
    func convert<T>(_ convert:(Self) -> T) -> T {
        return convert(self)
    }
    
}

extension RawRepresentable where Self : ExpressibleByIntegerLiteral, Self.RawValue == IntegerLiteralType {
    
    public init(rawValue: IntegerLiteralType) {
        self.init(integerLiteral: rawValue)
    }
}

extension RawRepresentable where Self : ExpressibleByFloatLiteral, Self.RawValue == FloatLiteralType {
    
    public init(rawValue: FloatLiteralType) {
        self.init(floatLiteral: rawValue)
    }
}

extension RawRepresentable where Self : ExpressibleByBooleanLiteral, Self.RawValue == BooleanLiteralType {
    
    public init(rawValue: BooleanLiteralType) {
        self.init(booleanLiteral: rawValue)
    }
}


extension RawRepresentable where Self : ExpressibleByStringLiteral, Self.RawValue == StringLiteralType {

    public init(rawValue: StringLiteralType) {
        self.init(stringLiteral: rawValue)
    }
}

