//
//  UserDefaultTool.swift
//  Tools
//
//  Created by Steven on 2017/9/19.
//
//

import Foundation


public func load<T>(_ value:@autoclosure ()->T?, sift: (T)->T?) -> T? {
    if let v = value() {
        return sift(v)
    }
    return nil
}

public func load<T>(_ value:@autoclosure ()->T, sift: (T)->T) -> T {
    return sift(value())
}

public func load<T>(_ value:@autoclosure ()->T, sift: (T)->T?) -> T? {
    return sift(value())
}

//public struct DecoderGetter : Decodable {
//    
//    public let decoder: Decoder
//    public init(from decoder: Decoder) {
//        self.decoder = decoder
//    }
//    
//}
//
//open class CodeStruct<T:Codable> : NSObject, NSCoding, RawRepresentable {
//
//    public typealias RawValue = T
//
//    open let rawValue: T
//    public required init(rawValue: RawValue) {
//        self.rawValue = rawValue
//    }
//
//    public func encode(with aCoder: NSCoder) {
//        if let data = try? JSONEncoder().encode(rawValue) {
//            aCoder.encode(data)
//        }
//    }
//
//    public required init?(coder aDecoder: NSCoder) {
//        guard let data = aDecoder.decodeData() else { return nil }
//        guard let value = try? JSONDecoder().decode(T.self, from:data) else { return nil }
//        self.rawValue = value
//    }
//
//}

//extension Encodable where Self : Decodable {
//
//    public var archive:CodeStruct<Self> { return CodeStruct(rawValue: self) }
//
//}


public protocol UserDefaultsSettable {
   var uniqueKey : String { get }
}

extension UserDefaultsSettable where Self : RawRepresentable,Self.RawValue == String {
    
    //为所有的Key加上枚举名做命名空间，避免重复
    public var uniqueKey : String {
        
        return "\(Self.self).\(rawValue)"
        
    }
    
    public var suite:UserDefaults {
        return UserDefaults(suiteName: uniqueKey)!
    }
    
    public func save(value : Any?) {
        
        UserDefaults.standard.set(value, forKey: uniqueKey)
        UserDefaults.standard.synchronize()
    }
    
    public func saveCodable<T:Codable>(_ value:T?) throws {
        if let t = value {
            let data = try JSONEncoder().encode(t)
            UserDefaults.standard.set(data, forKey: uniqueKey)
        } else {
            UserDefaults.standard.set(nil, forKey: uniqueKey)
        }
        UserDefaults.standard.synchronize()
    }
    
    public func saveBool(_ value : Bool) {
        UserDefaults.standard.set(value, forKey: uniqueKey)
        UserDefaults.standard.synchronize()
    }
    
    public func saveDouble(_ value : Double) {
        UserDefaults.standard.set(value, forKey: uniqueKey)
        UserDefaults.standard.synchronize()
    }
    
    public func saveInt(_ value : Int) {
        UserDefaults.standard.set(value, forKey: uniqueKey)
        UserDefaults.standard.synchronize()
    }
    
    public func saveFloat(_ value : Float) {
        UserDefaults.standard.set(value, forKey: uniqueKey)
        UserDefaults.standard.synchronize()
    }
    
    public func saveURL(_ value : URL) {
        UserDefaults.standard.set(value, forKey: uniqueKey)
        UserDefaults.standard.synchronize()
    }
    
    //取值
    public func load<T:Codable>(_ type:T.Type) -> T? {
        guard let data = UserDefaults.standard.data(forKey: uniqueKey) else {
            return nil
        }
        return try? JSONDecoder().decode(type, from: data)
    }
    
    public var loadValue : Any? {
        return UserDefaults.standard.value(forKey: uniqueKey)
    }
    
    public var loadString : String? {
        return UserDefaults.standard.string(forKey: uniqueKey)
    }
    
    public var loadBool : Bool {
        return UserDefaults.standard.bool(forKey: uniqueKey)
    }
    
    public var loadDouble : Double? {
        return Double(UserDefaults.standard.string(forKey: uniqueKey) ?? .Empty)
    }
    
    public var loadFloat: Float? {
        return Float(UserDefaults.standard.string(forKey: uniqueKey) ?? .Empty)
    }
    
    public var loadInt: Int? {
        return Int(UserDefaults.standard.string(forKey: uniqueKey) ?? .Empty)
    }
    
    public var loadURL: URL? {
        return UserDefaults.standard.url(forKey: uniqueKey)
    }
    
    
}
