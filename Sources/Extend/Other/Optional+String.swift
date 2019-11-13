
extension Optional where Wrapped : CustomDebugStringConvertible {
    public var string:String? {
        switch self {
        case .none: return nil
        case .some(let value): return value.debugDescription
        }
    }
}

extension Optional where Wrapped : CustomStringConvertible {
    public var string:String? {
        switch self {
        case .none: return nil
        case .some(let value): return value.description
        }
    }
}

extension Optional {
    public var string:String? {
        switch self {
        case .none: return nil
        case .some(let value): return String(describing: value)
        }
    }
    
    public func print() {
        if case .some(let value) = self {
            Swift.print(value)
        }
    }
}
