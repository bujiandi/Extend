//
//  DefaultOperator.swift
//  Operator
//
//  Created by bujiandi on 2019/5/16.
//

import Protocolar

/// 排除 isEmpty 的情况
@inlinable public func ???<T:Emptiable>(lhs: @autoclosure () -> T?, rhs: @autoclosure () -> T) -> T {
    let value = lhs() ?? rhs()
    return value.isEmpty ? rhs() : value
}
