//
//  Operator.swift
//  NetWork
//
//  Created by 慧趣小歪 on 16/3/25.
//  Copyright © 2016年 小分队. All rights reserved.
//
//  那些曾被Swift删除但是很有用的运算符
//

import Foundation

precedencegroup NilWrapPrecedence {
    associativity: right
    higherThan: AssignmentPrecedence
    lowerThan: LogicalConjunctionPrecedence
}
/// 可选赋值运算符 有则赋值, 没有忽略
infix operator ??? : NilWrapPrecedence
infix operator =? : AssignmentPrecedence

@inlinable public func ??(lhs:Bool, rhs: @autoclosure () -> Void) {
    if lhs { rhs() }
}

@inlinable public func ??<T>(lhs:Bool, rhs: @autoclosure () -> T?) -> T? {
    return lhs ? rhs() : nil
}

@inlinable public func ???<T>(lhs: @autoclosure () -> T?, rhs: Bool) -> T? {
    return rhs ? lhs() : nil
}

@inlinable public func ???<T>(lhs: @autoclosure () -> T, rhs: Bool) -> T? {
    return rhs ? lhs() : nil
}

/// 可选赋值运算符 有则赋值, 没有忽略
@inlinable public func =?<T>(lhs: inout T, rhs: T?) {
    if let v = rhs { lhs = v }
}

/// 可选赋值运算符 有则赋值, 没有忽略
@inlinable public func =?<T>(lhs: inout T?, rhs: T?) {
    if let v = rhs { lhs = v }
}

/// 可选值相乘
@inlinable public func *<T>(lhs: T?, rhs: T) -> T? where T : FloatingPoint {
    if let v = lhs { return v * rhs }
    return nil
}
/*
这里给出常用类型对应的group

infix operator ||   : LogicalDisjunctionPrecedence
infix operator &&   : LogicalConjunctionPrecedence
infix operator <    : ComparisonPrecedence
infix operator <=   : ComparisonPrecedence
infix operator >    : ComparisonPrecedence
infix operator >=   : ComparisonPrecedence
infix operator ==   : ComparisonPrecedence
infix operator !=   : ComparisonPrecedence
infix operator ===  : ComparisonPrecedence
infix operator !==  : ComparisonPrecedence
infix operator ~=   : ComparisonPrecedence
infix operator ??   : NilCoalescingPrecedence
infix operator +    : AdditionPrecedence
infix operator -    : AdditionPrecedence
infix operator &+   : AdditionPrecedence
infix operator &-   : AdditionPrecedence
infix operator |    : AdditionPrecedence
infix operator ^    : AdditionPrecedence
infix operator *    : MultiplicationPrecedence
infix operator /    : MultiplicationPrecedence
infix operator %    : MultiplicationPrecedence
infix operator &*   : MultiplicationPrecedence
infix operator &    : MultiplicationPrecedence
infix operator <<   : BitwiseShiftPrecedence
infix operator >>   : BitwiseShiftPrecedence
infix operator ..<  : RangeFormationPrecedence
infix operator ...  : RangeFormationPrecedence
infix operator *=   : AssignmentPrecedence
infix operator /=   : AssignmentPrecedence
infix operator %=   : AssignmentPrecedence
infix operator +=   : AssignmentPrecedence
infix operator -=   : AssignmentPrecedence
infix operator <<=  : AssignmentPrecedence
infix operator >>=  : AssignmentPrecedence
infix operator &=   : AssignmentPrecedence
infix operator ^=   : AssignmentPrecedence
infix operator |=   : AssignmentPrecedence
 
infix operator ?=   : AssignmentPrecedence
infix operator <-   : AssignmentPrecedence

*/
