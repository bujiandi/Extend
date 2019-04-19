//
//  JSON+CoreGraphics.swift
//  TestJSON
//
//  Created by 李招利 on 2019/1/16.
//  Copyright © 2019 jwl. All rights reserved.
//

#if canImport(CoreGraphics)
import CoreGraphics

extension JSON {
    
    public var optionalCGFloat:CGFloat? {
        guard let value = optionalDouble else { return nil }
        return CGFloat(value)
    }
    public var cgFloat:CGFloat { return optionalCGFloat ?? 0 }
    
    public static func float(_ value:CGFloat) -> JSON {
        return JSON.number(Number(value))
    }
}

extension JSON.Number {
    
    public init(_ value: CGFloat) {
        self.init(floatLiteral: Double(exactly: value) ?? Double(value))
    }
    
    public var cgFloatValue: CGFloat {
        let _length = rawValue.count
        if _length == 0 {
            if isNegative {
                return CGFloat.nan
            } else {
                return 0
            }
        }
        
        return CGFloat(doubleValue)
    }
}

#endif
