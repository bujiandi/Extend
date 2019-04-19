//
//  JSON+Serializable.swift
//  TestJSON
//
//  Created by 李招利 on 2019/1/7.
//  Copyright © 2019 jwl. All rights reserved.
//

import Foundation
#if os(macOS) || os(iOS)
import Darwin
#elseif os(Linux) || CYGWIN
import Glibc
#endif

#if swift(>=5.0)

extension String.StringInterpolation {
    
    public mutating func appendInterpolation(_ json:JSON) {
        appendLiteral(":\n\(json.debugDescription)")
    }
}

#endif

extension InputStream {

    /* Create a JSON object from JSON data stream. The stream should be opened and configured. All other behavior of this method is the same as the JSONObjectWithData:options:error: method.
     */
    public func parseJSON(options opt: JSONSerialization.ReadingOptions = []) throws -> JSON {
        var data = Data()
        guard streamStatus == .open || streamStatus == .reading else {
            #if DEBUG
            fatalError("Stream is not available for reading")
            #else
            throw NSError(domain: NSCocoaErrorDomain, code: CocoaError.propertyListReadStream.rawValue, userInfo: [
                "NSDebugDescription" : "Stream is not available for reading"
                ])
            #endif
        }
        repeat {
            var buffer = [UInt8](repeating: 0, count: 1024)
            var bytesRead: Int = 0
            bytesRead = read(&buffer, maxLength: buffer.count)
            if bytesRead < 0 {
                throw streamError!
            } else {
                data.append(&buffer, count: bytesRead)
            }
        } while hasBytesAvailable
        return try data.parseJSON(options: opt)
    }

}

extension String {
    
    public var deserializeJSON:JSON {
        guard let data = data(using: .utf8) else {
            let error = NSError(domain: NSCocoaErrorDomain, code: CocoaError.propertyListReadCorrupt.rawValue, userInfo: [
                "NSDebugDescription" : "JSON text did not start with utf-8 String CharSet."
                ])
            return JSON.error(.otherError(error), ignore: [])
        }

        return data.deserializeJSON
    }
    
    public func parseJSON(options opt: JSONSerialization.ReadingOptions = []) throws -> JSON {
        guard let data = data(using: .utf8) else {
            throw NSError(domain: NSCocoaErrorDomain, code: CocoaError.propertyListReadCorrupt.rawValue, userInfo: [
                "NSDebugDescription" : "JSON text did not start with utf-8 String CharSet."
                ])
        }
        return try data.parseJSON(options: opt)
    }
    
    internal func parseJSONNumber() throws -> JSON.Number {
        
        let count = lengthOfBytes(using: .utf8)
        let bufferLength = count + 1 // Allow space for null terminator
        var utf8: [CChar] = Array<CChar>(repeating: 0, count: bufferLength)
        if !getCString(&utf8, maxLength: bufferLength, encoding: .utf8) {
            throw NSError(domain: NSCocoaErrorDomain, code: CocoaError.coderInvalidValue.rawValue, userInfo: [
                "NSDebugDescription" : "JSON text did not start with utf-8 String CharSet."
                ])
        }
        let rawBytes = UnsafeRawPointer(UnsafePointer(utf8))
        
        let buffer = UnsafeBufferPointer(start: rawBytes.bindMemory(to: UInt8.self, capacity: bufferLength), count: bufferLength)
        let source = JSON.UnicodeSource(buffer: buffer, encoding: .utf8)
        let reader = JSON.Reader(source: source)

        guard let (value, _) = try reader.parseNumber(0, options: [.allowFragments]) else {
            throw NSError(domain: NSCocoaErrorDomain, code: CocoaError.coderInvalidValue.rawValue, userInfo: [
                "NSDebugDescription" : "JSON text did not parse number with nil"
                ])
        }
        
        return value
    }
}

extension Data {
    
    public var deserializeJSON:JSON {
        do {
            return try parseJSON()
        } catch let error {
            return JSON.error(.otherError(error), ignore: [])
        }
    }
    
    /* Create a Foundation object from JSON data. Set the NSJSONReadingAllowFragments option if the parser should allow top-level objects that are not an NSArray or NSDictionary. Setting the NSJSONReadingMutableContainers option will make the parser generate mutable NSArrays and NSDictionaries. Setting the NSJSONReadingMutableLeaves option will make the parser generate mutable NSString objects. If an error occurs during the parse, then the error parameter will be set and the result will be nil.
     The data must be in one of the 5 supported encodings listed in the JSON specification: UTF-8, UTF-16LE, UTF-16BE, UTF-32LE, UTF-32BE. The data may or may not have a BOM. The most efficient encoding to use for parsing is UTF-8, so if you have a choice in encoding the data passed to this method, use UTF-8.
     */
    public func parseJSON(options opt: JSONSerialization.ReadingOptions = []) throws -> JSON {

        return try withUnsafeBytes { (bufferPoint:UnsafeRawBufferPointer) -> JSON in
            let encoding: String.Encoding
            let bytes = bufferPoint.bindMemory(to: UInt8.self).baseAddress!

            let buffer: UnsafeBufferPointer<UInt8>
            if let detected = JSON.parseBOM(bufferPoint) {
                encoding = detected.encoding
                buffer = UnsafeBufferPointer(start: bytes.advanced(by: detected.skipLength), count: count - detected.skipLength)
            }
            else {
                encoding = JSON.detectEncoding(bytes, count)
                buffer = UnsafeBufferPointer(start: bytes, count: count)
            }

            let source = JSON.UnicodeSource(buffer: buffer, encoding: encoding)
            let reader = JSON.Reader(source: source)
            if let (object, _) = try reader.parseObject(0, options: opt) {
                return JSON.object(object)
            }
            else if let (array, _) = try reader.parseArray(0, options: opt) {
                return JSON.array(array)
            }
            else if opt.contains(.allowFragments), let (value, _) = try reader.parseValue(0, options: opt) {
                return value
            }
            throw NSError(domain: NSCocoaErrorDomain, code: CocoaError.propertyListReadCorrupt.rawValue, userInfo: [
                "NSDebugDescription" : "JSON text did not start with array or object and option to allow fragments not set."
                ])
        }
//        return try withUnsafeBytes { (bytes: UnsafePointer<UInt8>) -> JSON in
//            let encoding: String.Encoding
//            let buffer: UnsafeBufferPointer<UInt8>
//            if let detected = JSON.parseBOM(bytes, length: count) {
//                encoding = detected.encoding
//                buffer = UnsafeBufferPointer(start: bytes.advanced(by: detected.skipLength), count: count - detected.skipLength)
//            }
//            else {
//                encoding = JSON.detectEncoding(bytes, count)
//                buffer = UnsafeBufferPointer(start: bytes, count: count)
//            }
//
//            let source = JSON.UnicodeSource(buffer: buffer, encoding: encoding)
//            let reader = JSON.Reader(source: source)
//            if let (object, _) = try reader.parseObject(0, options: opt) {
//                return JSON.object(object)
//            }
//            else if let (array, _) = try reader.parseArray(0, options: opt) {
//                return JSON.array(array)
//            }
//            else if opt.contains(.allowFragments), let (value, _) = try reader.parseValue(0, options: opt) {
//                return value
//            }
//            throw NSError(domain: NSCocoaErrorDomain, code: CocoaError.propertyListReadCorrupt.rawValue, userInfo: [
//                "NSDebugDescription" : "JSON text did not start with array or object and option to allow fragments not set."
//                ])
//        }
        
    }

}

extension JSONDecoder {
    
    public enum NumberOverflowDecodingStrategy {
        case ignore
        case `throw`
    }
    
    public enum URLDecodingStrategy {
        case `throw`
        case relative(URL)
        case custom((String) throws -> URL)
    }
    
}

extension JSON {
    
    init(stream: InputStream, options opt: JSONSerialization.ReadingOptions = []) throws {
        self = try stream.parseJSON(options: opt)
    }
    
    /* Create a Foundation object from JSON data. Set the NSJSONReadingAllowFragments option if the parser should allow top-level objects that are not an NSArray or NSDictionary. Setting the NSJSONReadingMutableContainers option will make the parser generate mutable NSArrays and NSDictionaries. Setting the NSJSONReadingMutableLeaves option will make the parser generate mutable NSString objects. If an error occurs during the parse, then the error parameter will be set and the result will be nil.
     The data must be in one of the 5 supported encodings listed in the JSON specification: UTF-8, UTF-16LE, UTF-16BE, UTF-32LE, UTF-32BE. The data may or may not have a BOM. The most efficient encoding to use for parsing is UTF-8, so if you have a choice in encoding the data passed to this method, use UTF-8.
     */
    public init(data: Data, options opt: JSONSerialization.ReadingOptions = []) throws {
        self = try data.parseJSON(options: opt)
    }
    
    public func serializeData(options opt: JSONSerialization.WritingOptions = []) -> Data {
        var jsonStr = String()
        
        let sortedKeys:Bool
        #if os(macOS)
        if #available(macOS 10.13, *) {
            sortedKeys = opt.contains(.sortedKeys)
        } else {
            sortedKeys = false
        }
        #else
        if #available(iOS 11.0, *) {
            sortedKeys = opt.contains(.sortedKeys)
        } else {
            sortedKeys = false
        }
        #endif
        
        var writer = Writer(pretty: opt.contains(.prettyPrinted), sortedKeys: sortedKeys) {
            if let text = $0 { jsonStr.append(text) }
        }
        
        writer.serializeJSON(self)
        
        let count = jsonStr.lengthOfBytes(using: .utf8)
        let bufferLength = count + 1 // Allow space for null terminator
        var utf8: [CChar] = Swift.Array<CChar>(repeating: 0, count: bufferLength)
        if !jsonStr.getCString(&utf8, maxLength: bufferLength, encoding: .utf8) {
            fatalError("Failed to generate a CString from a String")
        }
        let rawBytes = UnsafeRawPointer(UnsafePointer(utf8))
        let result = Data(bytes: rawBytes.bindMemory(to: UInt8.self, capacity: count), count: count)
        return result
    }
    
}

extension JSON.Array {
    
    public func serializeData(options opt: JSONSerialization.WritingOptions = []) -> Data {
        var jsonStr = String()
        
        let sortedKeys:Bool
        #if os(macOS)
        if #available(macOS 10.13, *) {
            sortedKeys = opt.contains(.sortedKeys)
        } else {
            sortedKeys = false
        }
        #else
        if #available(iOS 11.0, *) {
            sortedKeys = opt.contains(.sortedKeys)
        } else {
            sortedKeys = false
        }
        #endif
        
        var writer = JSON.Writer(pretty: opt.contains(.prettyPrinted), sortedKeys: sortedKeys) {
            if let text = $0 { jsonStr.append(text) }
        }
        
        writer.serializeArray(self)
        
        let count = jsonStr.lengthOfBytes(using: .utf8)
        let bufferLength = count + 1 // Allow space for null terminator
        var utf8: [CChar] = Swift.Array<CChar>(repeating: 0, count: bufferLength)
        if !jsonStr.getCString(&utf8, maxLength: bufferLength, encoding: .utf8) {
            fatalError("Failed to generate a CString from a String")
        }
        let rawBytes = UnsafeRawPointer(UnsafePointer(utf8))
        let result = Data(bytes: rawBytes.bindMemory(to: UInt8.self, capacity: count), count: count)
        return result
    }
}

extension JSON.Object {
    
    public func serializeData(options opt: JSONSerialization.WritingOptions = []) -> Data {
        var jsonStr = String()
        
        let sortedKeys:Bool
        #if os(macOS)
        if #available(macOS 10.13, *) {
            sortedKeys = opt.contains(.sortedKeys)
        } else {
            sortedKeys = false
        }
        #else
        if #available(iOS 11.0, *) {
            sortedKeys = opt.contains(.sortedKeys)
        } else {
            sortedKeys = false
        }
        #endif
        
        var writer = JSON.Writer(pretty: opt.contains(.prettyPrinted), sortedKeys: sortedKeys) {
            if let text = $0 { jsonStr.append(text) }
        }
        writer.serializeObject(self)
        
        let count = jsonStr.lengthOfBytes(using: .utf8)
        let bufferLength = count + 1 // Allow space for null terminator
        var utf8: [CChar] = Swift.Array<CChar>(repeating: 0, count: bufferLength)
        if !jsonStr.getCString(&utf8, maxLength: bufferLength, encoding: .utf8) {
            fatalError("Failed to generate a CString from a String")
        }
        let rawBytes = UnsafeRawPointer(UnsafePointer(utf8))
        let result = Data(bytes: rawBytes.bindMemory(to: UInt8.self, capacity: count), count: count)
        return result
    }
}


extension JSON: Equatable {
    
    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (lhs: JSON, rhs: JSON) -> Bool {
        switch (lhs, rhs) {
        case (.null, .null): return true
        case (.bool(let lValue), .bool(let rValue)): return lValue == rValue
        case (.number(let lValue), .number(let rValue)): return lValue == rValue
        case (.string(let lValue), .string(let rValue)): return lValue == rValue
        case (.object(let lValue), .object(let rValue)): return lValue == rValue
        case (.array(let lValue), .array(let rValue)): return lValue == rValue
        case (.error(let lValue, let lIgnore), .error(let rValue, let rIgnore)):
            return (lValue.localizedDescription == rValue.localizedDescription) && lIgnore == rIgnore
        default: return false
        }
        
    }
}

extension JSON: Hashable {
 
    public func hash(into hasher: inout Hasher) {
        switch self {
        case .null:
            hasher.combine(NSNull())
        case .bool(let value):
            hasher.combine(value)
        case .number(let value):
            hasher.combine(value)
        case .string(let value):
            hasher.combine(value)
        case .object(let value):
            hasher.combine(value)
        case .array(let value):
            hasher.combine(value)
        case .error(let error, let ignore):
            hasher.combine(error.localizedDescription)
            hasher.combine(ignore)
        }
    }
    
}

extension JSON : CustomStringConvertible {
    
    public var description: String {
        var jsonStr = String()
        var writer = Writer(pretty: false, sortedKeys: false) {
            if let text = $0 { jsonStr.append(text) }
        }
        writer.serializeJSON(self)
        return jsonStr
    }
    
}

extension JSON : CustomDebugStringConvertible {
    
    public var debugDescription: String {
        var jsonStr = String()
        var writer = Writer(pretty: true, sortedKeys: false) {
            if let text = $0 { jsonStr.append(text) }
        }
        writer.serializeJSON(self)
        return jsonStr
    }
}

extension JSON {
    /// Detect the encoding format of the NSData contents
    static func detectEncoding(_ bytes: UnsafePointer<UInt8>, _ length: Int) -> String.Encoding {
        
        if length >= 4 {
            switch (bytes[0], bytes[1], bytes[2], bytes[3]) {
            case (0, 0, 0, _):
                return .utf32BigEndian
            case (_, 0, 0, 0):
                return .utf32LittleEndian
            case (0, _, 0, _):
                return .utf16BigEndian
            case (_, 0, _, 0):
                return .utf16LittleEndian
            default:
                break
            }
        }
        else if length >= 2 {
            switch (bytes[0], bytes[1]) {
            case (0, _):
                return .utf16BigEndian
            case (_, 0):
                return .utf16LittleEndian
            default:
                break
            }
        }
        return .utf8
    }
    
    static func parseBOM(_ buffer: UnsafeRawBufferPointer) -> (encoding: String.Encoding, skipLength: Int)? {
        let length = buffer.count
        if length >= 2 {
            let byte0 = buffer.load(fromByteOffset: 0, as: UInt8.self)
            let byte1 = buffer.load(fromByteOffset: 1, as: UInt8.self)
            switch (byte0, byte1) {
            case (0xEF, 0xBB) where length >= 3:
                if buffer.load(fromByteOffset: 2, as: UInt8.self) == 0xBF {
                    return (.utf8, 3)
                }
            case (0x00, 0x00) where length >= 4:
                let byte2 = buffer.load(fromByteOffset: 2, as: UInt8.self)
                let byte3 = buffer.load(fromByteOffset: 3, as: UInt8.self)
                if byte2 == 0xFE && byte3 == 0xFF {
                    return (.utf32BigEndian, 4)
                }
            case (0xFF, 0xFE) where length >= 4:
                let byte2 = buffer.load(fromByteOffset: 2, as: UInt8.self)
                let byte3 = buffer.load(fromByteOffset: 3, as: UInt8.self)
                if byte2 == 0 && byte3 == 0 {
                    return (.utf32LittleEndian, 4)
                }
                return (.utf16LittleEndian, 2)
            case (0xFE, 0xFF):
                return (.utf16BigEndian, 2)
            default:
                break
            }
        }
        return nil
    }
    
    static func parseBOM(_ bytes: UnsafePointer<UInt8>, length: Int) -> (encoding: String.Encoding, skipLength: Int)? {
        if length >= 2 {
            switch (bytes[0], bytes[1]) {
            case (0xEF, 0xBB):
                if length >= 3 && bytes[2] == 0xBF {
                    return (.utf8, 3)
                }
            case (0x00, 0x00):
                if length >= 4 && bytes[2] == 0xFE && bytes[3] == 0xFF {
                    return (.utf32BigEndian, 4)
                }
            case (0xFF, 0xFE):
                if length >= 4 && bytes[2] == 0 && bytes[3] == 0 {
                    return (.utf32LittleEndian, 4)
                }
                return (.utf16LittleEndian, 2)
            case (0xFE, 0xFF):
                return (.utf16BigEndian, 2)
            default:
                break
            }
        }
        return nil
    }
}

extension JSON : Decodable {
    public init(from decoder: Swift.Decoder) throws {
        
        if let container = try? decoder.container(keyedBy: String.self) {
            let obj = JSON.Object()
            for key in container.allKeys {
                let value = try container.decode(JSON.self, forKey: key)
                obj.append(value: value, for: key)
            }
            self = .object(obj)
            return
        } else if var container = try? decoder.unkeyedContainer() {
            var list:Array = Array()
            while !container.isAtEnd {
                if let v = try? container.decode(JSON.self) {
                    list.append(v)
                }
            }
            self = .array(list)
            return
        } else if let container = try? decoder.singleValueContainer(), !container.decodeNil() {
            if let v = try? container.decode(Double.self) {
                self = .number(Number(v))
            } else if let v = try? container.decode(Bool.self) {
                self = .bool(v)
            } else {
                do {
                    let v = try container.decode(String.self)
                    self = .string(v)
                } catch let error {
                    self = JSON.error(.typeMismatch(error.localizedDescription), ignore: [])
                }
            }
            return
        }
        self = .null
    }
}

extension JSON : Encodable {
    public func encode(to encoder: Swift.Encoder) throws {
        switch self {
        case let .object(obj):
            var container = encoder.container(keyedBy: String.self)
            for k in obj._keys {
                try container.encode(obj._map[k], forKey: k)
            }
        case let .array(array):
            var container = encoder.unkeyedContainer()
            try container.encode(contentsOf: array)
        case let .number(num):
            var container = encoder.singleValueContainer()
            try container.encode(num.doubleValue)
        case let .string(str):
            var container = encoder.singleValueContainer()
            try container.encode(str)
        case let .bool(yesno):
            var container = encoder.singleValueContainer()
            try container.encode(yesno)
        case let .error(err):
            var container = encoder.singleValueContainer()
            try container.encode("(--->\(err)<---)")
        case .null:
            var container = encoder.singleValueContainer()
            try container.encodeNil()
        }
    }
}



//===----------------------------------------------------------------------===//
// Shared Key Types
//===----------------------------------------------------------------------===//

internal struct _JSONKey : CodingKey {
    public var stringValue: String
    public var intValue: Int?
    
    public init?(stringValue: String) {
        self.stringValue = stringValue
        self.intValue = nil
    }
    
    public init?(intValue: Int) {
        self.stringValue = "\(intValue)"
        self.intValue = intValue
    }
    
    public init(stringValue: String, intValue: Int?) {
        self.stringValue = stringValue
        self.intValue = intValue
    }
    internal init(index: Int) {
        self.stringValue = "Index \(index)"
        self.intValue = index
    }
    
    internal static let `super` = _JSONKey(stringValue: "super")!
}
