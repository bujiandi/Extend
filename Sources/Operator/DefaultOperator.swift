//
//  DefaultOperator.swift
//  Operator
//
//  Created by bujiandi on 2019/5/16.
//

import Protocolar

/// 排除 isEmpty 的情况
@inlinable public func ???<T:Emptiable>(lhs: T?, rhs: @autoclosure () -> T) -> T {
    let value = lhs ?? rhs()
    return value.isEmpty ? rhs() : value
}

/// 可选执行表达式
@inlinable public func ??<T>(lhs: Bool, rhs: @autoclosure () -> T) -> T? {
    return lhs ? rhs() : nil
}
