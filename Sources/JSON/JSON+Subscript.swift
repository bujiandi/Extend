//
//  JSON+Subscript.swift
//  TestJSON
//
//  Created by 李招利 on 2019/1/7.
//  Copyright © 2019 jwl. All rights reserved.
//

import Foundation

extension JSON {
    public subscript(key:String) -> JSON {
        get {
            switch self {
            case .error(let error, var ignorePath):
                ignorePath.append(key)
                return JSON.error(error, ignore: ignorePath)
            case .object(let obj):
                return obj._map[key] ?? JSON.null
            case .array(let list):
                if let index = Int(key) {
                    return index >= list.count ?
                        JSON.error(.outOfRange(index), ignore: []):
                        list[index]
                }
                fallthrough
            default:
                return JSON.error(.notContains(key), ignore: [])
            }
        }
        set {
            switch self {
            case .null:
                self = JSON([key:newValue])
            case .object(let obj):
                obj[key] = newValue
            case .array(let list):
                if let index = Int(key), index <= list.count {
                    list[index] = newValue
//                    self = .array(list)
                    return
                }
                fallthrough
            default:
                fatalError("error: can't set value(\(newValue) to key:(\(key)) in object:\n\(self))")
            }
        }
    }
    
    
    public subscript(position:Int) -> JSON {
        get {
            switch self {
            case .error(let error, var ignorePath):
                ignorePath.append("Index \(position)")
                return JSON.error(error, ignore: ignorePath)
            case .object(let obj):
                if position < obj.count {
                    return obj[ObjectIndex(rawValue: position)].1;
                }
                return JSON.error(.outOfRange(position), ignore: [])
            case .array(let array):
                if position < array.count {
                    return array[position]
                }
                return JSON.error(.outOfRange(position), ignore: [])
            default:
                return JSON.error(.typeMismatch("json not array:\(debugDescription) for index:\(position)"), ignore: [])
            }
        }
        set {
            switch self {
            case .object(let obj):
                if position >= obj.count {
                    fatalError("error: set index out of bounds in object:\n\(self))")
                }
                obj[ObjectIndex(rawValue: position)] = (obj._keys[position], newValue)
            case .array(let list):
                if position > list.count {
                    fatalError("error: set index out of bounds in array:\n\(self))")
                }
                list[position] = newValue
                self = .array(list)
            case .null where position == 0:
                self = .array([newValue])
            default:
                fatalError("error: set index out of bounds in other:\n\(self))")
            }
        }
    }
    
    public mutating func append(_ item:JSON) {
        
        if case .array(var list) = self {
            list.append(item)
            self = .array(list)
        } else if case .null = self {
            self = .array([item])
        } else {
            fatalError("error: can't append in other:\n\(self)) by item\(item)")
        }
    }
    
    @discardableResult
    public mutating func remove(forKey key:String) -> JSON {
        var result = JSON.null
        if case .object(let obj) = self {
            result = obj.remove(forKey: key)
            self = .object(obj)
        } else {
            print("error: can't remove in other:\n\(self)) by key\(key)")
        }
        return result
    }
    
    public mutating func update(_ item:JSON) {
        self = item
    }
    
    public func contains(_ key:String) -> Bool {
        if case .object(let obj) = self {
            return obj._keys.contains(key)
        }
        return false
    }
}


extension JSON : Sequence {
    
}

extension JSON : Collection {
    
    public typealias Index = Int
    
    public var startIndex: Index {
        return 0
    }
    
    public var endIndex: Index {
        switch self {
        case let .array(list): return list.count
        case let .object(obj): return obj.count
        default:break
        }
        return 0
    }
    
    
    public typealias SubSequence = ArraySlice<JSON>
    
    public subscript(bounds: Range<Index>) -> ArraySlice<JSON> {
        get {
            switch self {
            case let .array(list): return list[bounds]
            //case let .object(obj as JSON.Object): return obj[bounds]
            default: break
            }
            return []
        }
        set {
            switch self {
            case var .array(list):
                list[bounds] = newValue
                self = .array(list)
            //case let .object(obj as JSON.Object): return obj[bounds]
            default: break
            }
        }
    }
    
    /// Returns the position immediately after the given index.
    ///
    /// - Parameter i: A valid index of the collection. `i` must be less than
    ///   `endIndex`.
    /// - Returns: The index value immediately after `i`.
    public func index(after i: Index) -> Index {
        return i + 1
    }
    
    /// Replaces the given index with its successor.
    ///
    /// - Parameter i: A valid index of the collection. `i` must be less than
    ///   `endIndex`.
    public func formIndex(after i: inout Index) {
//        if i >= endIndex {
//            fatalError("index out of range:\(startIndex..<endIndex)")
//        }
        i += 1
    }
}

extension JSON : MutableCollection {
    
    
}

extension Encodable {
    public func serialize() throws -> Data {
        if self is JSON {
            return (self as! JSON).serializeData()
        }
        return try JSONEncoder().encode(self)
    }
}

extension String : CodingKey {
    public init(stringValue: String) {
        self = stringValue
    }
    public var stringValue: String {
        return self
    }
    
    public init?(intValue: Int) {
        self = "Index \(intValue)"
    }
    public var intValue: Int? {
        if self.hasPrefix("Index ") {
            return Int(suffix(from: index(startIndex, offsetBy: 6)))
        }
        return nil
    }
}

