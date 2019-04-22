//
//  DBError.swift
//  DataBase
//
//  Created by bujiandi on 2019/4/22.
//

public struct DBError: Error, RawRepresentable {
    
    public let rawValue:(Int, String)
    
    public typealias RawValue = (Int, String)
    
    public init(rawValue value:(Int, String)) {
        rawValue = value
    }
    
    public init(code:Int, _ message:String) {
        rawValue = (code, message)
    }
    
    public var localizedDescription: String {
        return "db[\(rawValue.0)] error:\(rawValue.1)"
    }
}

extension DBError {
    
    public var code:Int { return rawValue.0 }
    public var message:String { return rawValue.1 }
    
}

extension DBError : CustomStringConvertible {
    
    public var description: String {
        return rawValue.1
    }
}

extension DBError : CustomDebugStringConvertible {
    
    public var debugDescription: String {
        return localizedDescription
    }
}

