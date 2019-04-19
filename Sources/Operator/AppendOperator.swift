//
//  AppendOperator.swift
//  Basic
//
//  Created by 慧趣小歪 on 2018/11/24.
//

infix /* 中置 */ operator <-? : AssignmentPrecedence
infix /* 中置 */ operator <- : AssignmentPrecedence

@inlinable public func <-<C, E>(lhs: inout C, rhs: E) where C : RangeReplaceableCollection, C.Element == E {
    lhs.append(rhs)
}

@inlinable public func <-?<C, E>(lhs: inout C, rhs: E?) where C : RangeReplaceableCollection, C.Element == E {
    if let value = rhs { lhs.append(value) }
}

@inlinable public func <-(lhs: inout String, rhs: String) {
    lhs.append(rhs)
}

@inlinable public func <-?(lhs: inout String, rhs: String?) {
    if let value = rhs { lhs.append(value) }
}
