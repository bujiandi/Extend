//
//  RangeOperator.swift
//  Basic
//
//  Created by 慧趣小歪 on 2018/11/24.
//

//import Protocolar

infix /* 中置 */ operator +- : AdditionPrecedence

public func +- <T:Calculable>(lhs: T, rhs: T) -> Range<T> {
    let v1 = lhs - rhs
    let v2 = lhs + rhs
    return min(v1, v2)..<max(v1, v2)
}
