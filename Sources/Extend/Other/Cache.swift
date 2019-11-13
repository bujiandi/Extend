//
//  Cache.swift
//  Extend
//
//  Created by bujiandi on 2018/6/13.
//

//import Protocolar

open class Cache<Key: Hashable, Element> {
    
    private var _keys:[Key] = []
    private var _map:[Key:(cost:Int, value:Element)] = [:]
    private var _costLimit:Int = 0
    private var _totalCost:Int = 0
    open var totalCost:Int { return _totalCost }
    open var countLimit:Int = 0
    
    public init() {}
    public init(countLimit:Int) {
        self.countLimit = countLimit
        _keys.reserveCapacity(countLimit)
    }
    
    open func remove(key:Key) {
        _keys.remove(element: key)
        _totalCost -= _map.removeValue(forKey: key)?.cost ?? 0
    }
    
    private func push(key:Key, value:Element, cost:Int) {
        let old = _map[key]?.cost ?? 0
        _totalCost += cost - old
        _map[key] = (cost, value)
        if old > 0 { _keys.remove(element: key) }
        _keys.append(key)
        // 如果超出缓存容量限制则移除
        testLimit()
    }
    
    private func testLimit() {
        var need:Bool = true
        while need {
            if _costLimit > 0,
                _totalCost > _costLimit,
                _keys.count > 0 {
                remove(key: _keys.first!)
                continue
            }
            
            if countLimit > 0,
                _keys.count > countLimit {
                remove(key: _keys.first!)
                continue
            }
            
            need = false
        }
        
    }
    
    public struct Index: RawRepresentable, ExpressibleByIntegerLiteral {
        public let rawValue: Int
        public typealias IntegerLiteralType = Int
        
        public init(integerLiteral value: Int) {
            rawValue = value
        }
        
        public init(_ value: Int) {
            rawValue = value
        }
        
        public init(rawValue value: Int) {
            rawValue = value
        }
    }
}

extension Cache.Index : Comparable {
    @inlinable public static func < (lhs: Cache.Index, rhs: Cache.Index) -> Bool { return lhs.rawValue <  rhs.rawValue }
    @inlinable public static func <=(lhs: Cache.Index, rhs: Cache.Index) -> Bool { return lhs.rawValue <= rhs.rawValue }
    @inlinable public static func >=(lhs: Cache.Index, rhs: Cache.Index) -> Bool { return lhs.rawValue >= rhs.rawValue }
    @inlinable public static func > (lhs: Cache.Index, rhs: Cache.Index) -> Bool { return lhs.rawValue >  rhs.rawValue }
}

extension Cache where Element : Costable {
    
    public convenience init(costLimit:Int) {
        self.init()
        _costLimit = costLimit
    }
    
    public convenience init(costLimit:Int, countLimit:Int) {
        self.init(countLimit: countLimit)
        _costLimit = costLimit
    }
    
    public var costLimit:Int {
        get { return _costLimit }
        set { _costLimit = newValue }
    }

    public subscript(key:Key) -> Element? {
        get { return _map[key]?.value }
        set {
            if let value = newValue {
                push(key: key, value: value, cost: value.cost)
            } else {
                remove(key: key)
            }
        }
    }
}

extension Cache {
    
    public subscript(key:Key) -> Element? {
        get { return _map[key]?.value }
        set {
            if let value = newValue {
                push(key: key, value: value, cost: 1)
            } else {
                remove(key: key)
            }
        }
    }
}

extension Cache : MutableCollection, Sequence {
 
    public typealias _Element = Element
    public typealias SubSequence = Cache<Key, Element>
    public typealias Iterator =  AnyIterator<(Key, Element)>
    public typealias IndexDistance = Int
    
    public subscript(position: Index) -> (Key, Element) {
        get {
            let key = _keys[position.rawValue]
            return (key, _map[key]!.value)
        }
        set {
            let oldKey = _keys[position.rawValue]
            _map[oldKey] = nil
            let newKey = newValue.0
            _keys[position.rawValue] = newKey
            _map[newKey] = (1, newValue.1)
        }
    }

    public var startIndex:Index { return Index(rawValue: 0) }
    public var endIndex:Index { return Index(rawValue: Swift.max(_keys.count - 1, 0)) }
    
    public func makeIterator() -> AnyIterator<(Key, Element)> {
        var i:Int = 0
        return AnyIterator { [unowned self] in
            if i >= self._keys.count { return nil }
            let key = self._keys[i]
            defer { i += 1 }
            return (key, self._map[key]!.value)
        }
    }
    
    public func index(after i: Index) -> Index {
        return Index(rawValue: i.rawValue + 1)
    }
    
}


//extension Cache : Decodable where Key : Decodable, Element : Decodable {
//    public convenience init(from decoder: Decoder) throws {
//        self.init()
//        let container = try decoder.container(keyedBy: String.self)
//        _keys = container.allKeys
//        _map.reserveCapacity(_keys.count)
//        for key in _keys {
//            _map[key] = try container.decode(JSON.self, forKey: key)
//        }
//    }
//}
//
//extension Cache : Encodable where Key : Encodable, Element : Encodable {
//
//    public func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: Key.self)
//        for key in _keys {
//            try container.encode(_map[key]!, forKey: key)
//        }
//    }
//}

