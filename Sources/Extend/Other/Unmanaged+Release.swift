//
//  Unmanaged+Release.swift
//  Tools
//
//  Created by appfenfen on 2017/10/10.
//

//import Foundation
//
//private let voidValue:Int = 0x160//0x800000002
//
//extension UnsafeMutableRawPointer: RawRepresentable {
//    public typealias RawValue = Int
//    public var rawValue:Int {
//        return Int(bitPattern: self)
//    }
//    public init?(rawValue: Int) {
//        self.init(bitPattern: rawValue)
//    }
//    public var isVoid:Bool {
//        return rawValue == voidValue
//    }
//}
//
//extension UnsafeRawPointer: RawRepresentable {
//    public typealias RawValue = Int
//    public var rawValue:Int {
//        return Int(bitPattern: self)
//    }
//    public init?(rawValue: Int) {
//        self.init(bitPattern: rawValue)
//    }
//    public var isVoid:Bool {
//        return rawValue == voidValue
//    }
//}
//
//extension Unmanaged {
//
//    public var isVoid:Bool {
//        return toOpaque().isVoid
//    }
//
//    // 如果返回值不为 Void 则释放内存
//    public func releaseIfNotVoid() {
//        if !isVoid {
////            release()
//        }
//    }
//
//}
