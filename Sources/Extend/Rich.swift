//
//  Rich.swift
//  Tools
//
//  Created by 慧趣小歪 on 2017/8/23.
//
//

import Foundation

extension String {
    
    public static func +(lhs:String, rhs:[NSAttributedString.Key : Any]) -> NSAttributedString {
        return NSAttributedString(string: lhs, attributes: rhs)
    }
    
    public static func +(lhs:String, rhs:[NSAttributedString.Key]) -> NSAttributedString {
        return NSAttributedString(string: lhs)
    }
}


public func +=<M:NSMutableAttributedString, T:NSAttributedString>(lhs:inout M, rhs:T) {
    lhs.append(rhs)
}

public func +=<M:NSMutableAttributedString>(lhs:inout M, rhs:String) {
    lhs.append(NSAttributedString(string: rhs))
}

public func +<T:NSAttributedString>(lhs:T, rhs:T) -> T {
    let rich = NSMutableAttributedString()
    rich.append(lhs)
    rich.append(rhs)
    return T(attributedString: rich)
}

public func +<T:NSAttributedString>(lhs:T, rhs:String) -> T {
    return lhs + T(string: rhs)
}


public func +=<T:NSAttributedString>(lhs:inout T, rhs:T) {
    let rich = NSMutableAttributedString()
    rich.append(lhs)
    rich.append(rhs)
    lhs = T(attributedString: rich)
}

public func +=<T:NSAttributedString>(lhs:inout T, rhs:String) {
    lhs += T(string: rhs)
}
