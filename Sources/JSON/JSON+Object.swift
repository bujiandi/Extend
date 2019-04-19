//
//  JSON+Object.swift
//  TestJSON
//
//  Created by 李招利 on 2019/1/7.
//  Copyright © 2019 jwl. All rights reserved.
//

import Foundation

fileprivate let commaSeparator:String = ","
fileprivate let prettySeparator:String = ",\n"

extension Data {
    fileprivate mutating func append(dataBy string: String, using chartSet:String.Encoding = .utf8) {
        guard let data = string.data(using: chartSet) else {
            #if DEBUG
            fatalError("error: can't append \"\(string)\" in data using \(chartSet)")
            #else
            return print("error: can't append \"\(string)\" in data using \(chartSet)")
            #endif
        }
        self.append(data)
    }
}

extension JSON {
    
    public struct ObjectIndex: RawRepresentable {
        public typealias RawValue = Int
        public var rawValue:RawValue
        public init(rawValue: RawValue) { self.rawValue = rawValue }
    }
    
    public final class Object {
        public typealias Key = String
        public typealias Value = Any?
        
        internal var _map:[String: JSON]
        internal var _keys:[String]
        
        public required init() {
            _map = [:]
            _keys = []
        }
        
//        deinit {
//            print("object deinit", _keys)
//        }
        
        public required init(dictionaryLiteral elements: (Key, Value)...) {
            var keys:[String] = []
            var map:[String: JSON] = [:]
            for (key, value) in elements {
                keys.append(key)
                map[key] = JSON.from(value)
            }
            _map = map
            _keys = keys
        }
        
        public func append(value: JSON, for key:String) {
            if let index = _keys.firstIndex(of: key) {
                _keys.remove(at: index)
            }
            _map[key] = value
            _keys.append(key)
        }
        
        @discardableResult
        public func remove(forKey key:String) -> JSON {
            if let index = _keys.firstIndex(of: key) {
                _keys.remove(at: index)
            }
            return _map.removeValue(forKey: key) ?? JSON.null
        }
    }
    
}

extension JSON.ObjectIndex : Comparable {
    public static func < (lhs: JSON.ObjectIndex, rhs: JSON.ObjectIndex) -> Bool { return lhs.rawValue <  rhs.rawValue }
    public static func <=(lhs: JSON.ObjectIndex, rhs: JSON.ObjectIndex) -> Bool { return lhs.rawValue <= rhs.rawValue }
    public static func >=(lhs: JSON.ObjectIndex, rhs: JSON.ObjectIndex) -> Bool { return lhs.rawValue >= rhs.rawValue }
    public static func > (lhs: JSON.ObjectIndex, rhs: JSON.ObjectIndex) -> Bool { return lhs.rawValue >  rhs.rawValue }
}

extension JSON.Object : MutableCollection, Sequence {
    
    public typealias _Element = (Key, JSON)
    public typealias Index = JSON.ObjectIndex
    public typealias SubSequence = JSON.Object
    public typealias Iterator =  AnyIterator<(Key, JSON)>
    public typealias IndexDistance = Int
    
    public subscript(position: Index) -> (Key, JSON) {
        get {
            let key = _keys[position.rawValue]
            return (key, _map[key]!)
        }
        set {
            let oldKey = _keys[position.rawValue]
            _map[oldKey] = nil
            let newKey = newValue.0
            _keys[position.rawValue] = newKey
            _map[newKey] = JSON.from(newValue.1)
        }
    }
    
    public var startIndex:Index { return Index(rawValue: 0) }
    public var endIndex:Index { return Index(rawValue: Swift.max(_keys.count - 1, 0)) }
    
    public subscript(key: Key) -> Value {
        get { return _map[key] }
        set { append(value: JSON.from(newValue), for: key) }
    }
    
    public func makeIterator() -> AnyIterator<(Key, JSON)> {
        var i:Int = 0
        return AnyIterator { [unowned self] in
            if i >= self._keys.count { return nil }
            let key = self._keys[i]
            defer { i += 1 }
            return (key, self._map[key]!)
        }
    }
    
    public subscript(bounds: Range<Index>) -> SubSequence {
        get {
            let subObject = JSON.Object()
            subObject._keys.reserveCapacity(bounds.upperBound.rawValue - bounds.lowerBound.rawValue)
            for key in _keys[bounds.lowerBound.rawValue..<bounds.upperBound.rawValue] {
                subObject._keys.append(key)
                subObject._map[key] = _map[key]
            }
            return subObject
        }
        set {
            let range:Range<Int> = bounds.lowerBound.rawValue..<bounds.upperBound.rawValue
            for key in _keys[range] {
                _map[key] = nil
            }
            _keys.replaceSubrange(range, with: newValue._keys)
            for (key, value) in newValue {
                _map[key] = value
            }
        }
    }
    
    public func index(after i: Index) -> Index {
        return Index(rawValue: i.rawValue + 1)
    }
    
}

extension JSON.Object : ExpressibleByDictionaryLiteral {
    
    public convenience init(_ dictionary:NSDictionary) {
        self.init()
        _keys.reserveCapacity(dictionary.count)
        for (keyAny, value) in dictionary {
            let key = "\(keyAny)"
            _keys.append(key)
            _map[key] = JSON.from(value)
        }
    }
    
}

extension JSON.Object : Decodable {
    public convenience init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: String.self)
        _keys = container.allKeys
        _map.reserveCapacity(_keys.count)
        for key in _keys {
            _map[key] = try container.decode(JSON.self, forKey: key)
        }
    }
}

extension JSON.Object : Encodable {
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: String.self)
        for key in _keys {
            try container.encode(_map[key]!, forKey: key)
        }
    }
}

// MARK: - JSON description
extension JSON.Object : CustomStringConvertible {
    
    private func serialize(pretty: Bool) -> String {
        var jsonStr = String()
        
        var writer = JSON.Writer(pretty: pretty, sortedKeys: false) {
            if let text = $0 { jsonStr.append(text) }
        }
        
        writer.serializeObject(self)
        
        return jsonStr
    }
    
    public var description: String {
        return serialize(pretty: false)
    }
    
}

extension JSON.Object : CustomDebugStringConvertible {
    
    public var debugDescription: String {
        return serialize(pretty: true)
    }
    
}

extension JSON.Object: Equatable {
    
    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (lhs: JSON.Object, rhs: JSON.Object) -> Bool {
        return lhs._keys == rhs._keys && lhs._map == rhs._map
    }
}

extension JSON.Object: Hashable {
    
    /// Hashes the essential components of this value by feeding them into the
    /// given hasher.
    ///
    /// Implement this method to conform to the `Hashable` protocol. The
    /// components used for hashing must be the same as the components compared
    /// in your type's `==` operator implementation. Call `hasher.combine(_:)`
    /// with each of these components.
    ///
    /// - Important: Never call `finalize()` on `hasher`. Doing so may become a
    ///   compile-time error in the future.
    ///
    /// - Parameter hasher: The hasher to use when combining the components
    ///   of this instance.
    public func hash(into hasher: inout Hasher) {
        for key in _keys {
            hasher.combine(key)
            hasher.combine(_map[key]!)
        }
    }
}


