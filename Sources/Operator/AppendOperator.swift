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

@inlinable public func <-<C, E>(lhs: inout C?, rhs: E) where C : RangeReplaceableCollection, C.Element == E {
    if lhs == nil {
        lhs = C.init(repeating: rhs, count: 1)
    } else {
        lhs!.append(rhs)
    }
}

@inlinable public func <-?<C, E>(lhs: inout C, rhs: E?) where C : RangeReplaceableCollection, C.Element == E {
    if let value = rhs { lhs.append(value) }
}

@inlinable public func <-?<C, E>(lhs: inout C?, rhs: E?) where C : RangeReplaceableCollection, C.Element == E {
    guard let value = rhs else { return }
    if lhs == nil {
        lhs = C.init(repeating: value, count: 1)
    } else {
        lhs!.append(value)
    }
}

@inlinable public func <-(lhs: inout String, rhs: String) {
    lhs.append(rhs)
}

@inlinable public func <-(lhs: inout String?, rhs: String) {
    if lhs == nil {
        lhs = rhs
    } else {
        lhs!.append(rhs)
    }
}

@inlinable public func <-?(lhs: inout String, rhs: String?) {
    if let value = rhs { lhs.append(value) }
}

@inlinable public func <-?(lhs: inout String?, rhs: String?) {
    guard let value = rhs else { return }
    if lhs == nil {
        lhs = value
    } else {
        lhs!.append(value)
    }
}
