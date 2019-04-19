//
//  JSON+Error.swift
//  TestJSON
//
//  Created by 李招利 on 2019/1/7.
//  Copyright © 2019 jwl. All rights reserved.
//

import Foundation

extension JSON {
    
    
    public enum Error: Swift.Error {
        case notContains(String)
        case outOfRange(Int)
        case typeMismatch(String)
        case otherError(Swift.Error)
    }
    
    
}

extension JSON.Error : CustomStringConvertible {
    
    public var description: String {
        switch self {
        case let .notContains(value):
            return "object not contains `\(value)`"
        case let .outOfRange(value):
            return "index `\(value)` out of range"
        case let .typeMismatch(value):
            return "type mismatch `\(value)`"
        case let .otherError(error):
            return error.localizedDescription
        }
    }
    
}


extension JSON.Error : CustomDebugStringConvertible {
    
    public var debugDescription: String {
        switch self {
        case let .notContains(value):
            return "object not contains `\(value)`"
        case let .outOfRange(value):
            return "index `\(value)` out of range"
        case let .typeMismatch(value):
            return "type mismatch `\(value)`"
        case let .otherError(error):
            return error.localizedDescription
        }
    }
    
}

