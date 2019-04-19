//
//  Optional+SafeUnwrap.swift
//  Basic
//
//  Created by 小歪 on 2018/7/17.
//

//import Foundation


extension Optional where Wrapped == String {
    
    public var isEmpty:Bool {
        switch self {
        case .none:             return true
        case .some(let value):  return value.isEmpty
        }
    }
    
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

extension Optional where Wrapped : FixedWidthInteger {
    
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
    
    public static func -(lhs:Wrapped?, rhs:Wrapped?) -> Wrapped? {
        if rhs == nil {
            return lhs
        } else if lhs == nil {
            return 0 - rhs!
        } else if let vl = lhs, let vr = rhs {
            return vl - vr
        } else {
            return nil
        }
    }
    
    public static func *(lhs:Wrapped?, rhs:Wrapped?) -> Wrapped? {
        if lhs == nil {
            return rhs
        } else if rhs == nil {
            return lhs
        } else if let vl = lhs, let vr = rhs {
            return vl * vr
        } else {
            return nil
        }
    }
    
    public static func /(lhs:Wrapped?, rhs:Wrapped?) -> Wrapped? {
        if rhs == nil {
            return lhs
        } else if lhs == nil {
            return 0 / rhs!
        } else if let vl = lhs, let vr = rhs {
            return vl / vr
        } else {
            return nil
        }
    }
}

extension Optional where Wrapped : BinaryFloatingPoint {
    
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
    
    public static func -(lhs:Wrapped?, rhs:Wrapped?) -> Wrapped? {
        if rhs == nil {
            return lhs
        } else if lhs == nil {
            return 0
        } else if let vl = lhs, let vr = rhs {
            return vl - vr
        } else {
            return nil
        }
    }
    
    public static func *(lhs:Wrapped?, rhs:Wrapped?) -> Wrapped? {
        if lhs == nil {
            return rhs
        } else if rhs == nil {
            return lhs
        } else if let vl = lhs, let vr = rhs {
            return vl * vr
        } else {
            return nil
        }
    }
    
    public static func /(lhs:Wrapped?, rhs:Wrapped?) -> Wrapped? {
        if rhs == nil {
            return lhs
        } else if lhs == nil {
            return 0
        } else if let vl = lhs, let vr = rhs {
            return vl / vr
        } else {
            return nil
        }
    }
}

extension Optional {
    
    @inlinable public func unwrap(nilDefault:Wrapped) -> Wrapped {
        return self ?? nilDefault
    }
}

extension Optional where Wrapped : ExpressibleByStringLiteral {
    
    @inlinable public var safeUnwrap:Wrapped {
        return self ?? ""
    }
}

extension Optional where Wrapped : ExpressibleByIntegerLiteral {
    
    @inlinable public var safeUnwrap:Wrapped {
        return self ?? 0
    }
}

extension Optional where Wrapped : ExpressibleByFloatLiteral {
    
    @inlinable public var safeUnwrap:Wrapped {
        return self ?? 0.0
    }
}

extension Optional where Wrapped : ExpressibleByArrayLiteral {
    
    @inlinable public var safeUnwrap:Wrapped {
        return self ?? []
    }
}

extension Optional where Wrapped : ExpressibleByBooleanLiteral {
    
    @inlinable public var safeUnwrap:Wrapped {
        return self ?? false
    }
}

extension Optional where Wrapped : ExpressibleByDictionaryLiteral {
    
    @inlinable public var safeUnwrap:Wrapped {
        return self ?? [:]
    }
}

