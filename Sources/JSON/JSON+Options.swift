//
//  JSON+Options.swift
//  TestJSON
//
//  Created by 李招利 on 2019/1/7.
//  Copyright © 2019 jwl. All rights reserved.
//
//
//import Foundation
//
//extension JSON {
//
//    public struct WritingOptions : OptionSet {
//        public let rawValue: UInt
//        public init(rawValue: UInt) { self.rawValue = rawValue }
//
//        public static let prettyPrinted = WritingOptions(rawValue: 1 << 0)
//        public static let sortedKeys = WritingOptions(rawValue: 1 << 1)
//    }
//
//    public struct ReadingOptions : OptionSet {
//        public let rawValue: UInt
//        public init(rawValue: UInt) { self.rawValue = rawValue }
//
//        public static let mutableContainers = ReadingOptions(rawValue: 1 << 0)
//        public static let mutableLeaves = ReadingOptions(rawValue: 1 << 1)
//        public static let allowFragments = ReadingOptions(rawValue: 1 << 2)
//    }
//
//}
