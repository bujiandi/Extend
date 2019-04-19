//
//  Optional+Rich.swift
//  RichText
//
//  Created by 李招利 on 2018/9/14.
//

import Foundation

extension Optional where Wrapped == Rich {
    
    public static func +(lhs:Wrapped?, rhs:Wrapped?) -> Wrapped? {
        if lhs == nil {
            return rhs
        } else if rhs == nil {
            return lhs
        } else if let vl = lhs, let vr = rhs {
            return vl + vr
        } else {
            return nil
        }
    }
    
}
