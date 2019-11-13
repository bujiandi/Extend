//
//  NSDate+Extend.swift
//  Extend
//
//  Created by bujiandi on 2019/4/18.
//

#if canImport(Foundation)
import Foundation

extension NSDate {
    // MARK: - 可以获取时间差
    @inlinable public static func -(lhs: NSDate, rhs: NSDate) -> TimeInterval {
        return lhs.timeIntervalSince1970 - rhs.timeIntervalSince1970
    }
    @inlinable public static func -(lhs: NSDate, rhs: Date) -> TimeInterval {
        return lhs.timeIntervalSince1970 - rhs.timeIntervalSince1970
    }
}
#endif
