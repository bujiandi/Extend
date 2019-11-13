//
//  FloatFormat.swift
//  Tools
//
//  Created by bujiandi on 2017/8/17.
//
//

#if canImport(Foundation)
import Foundation

extension BinaryFloatingPoint {
    
    /// 漂亮的格式化小数部分, 去掉多余的0
    public func pretty(format:NSString) -> String {
        return String(describing: NSNumber(value: NSString(format: format, self as! CVarArg).floatValue))
    }
}



extension FixedWidthInteger {

    /// 数值型加十六进制
    public var hex:String {
        return String(self, radix: 16, uppercase: true)
    }
}
#endif
