//
//  Operator+CGValue.swift
//  Operator
//
//  Created by bujiandi on 2019/4/18.
//

#if canImport(CoreGraphics)
import CoreGraphics

/// 可选赋值运算符 有则赋值, 没有忽略
@inlinable public func =?(lhs: inout CGFloat, rhs: Double?) {
    if let v = rhs { lhs = CGFloat(v) }
}

/// 可选赋值运算符 有则赋值, 没有忽略
@inlinable public func =?(lhs: inout CGFloat?, rhs: Double?) {
    if let v = rhs { lhs = CGFloat(v) }
}
#endif
