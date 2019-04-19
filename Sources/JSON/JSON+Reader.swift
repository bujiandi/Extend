//
//  JSON+Reader.swift
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

extension JSON {
    
    internal struct Reader {
        
        static let whitespaceASCII: [UInt8] = [
            0x09, // Horizontal tab
            0x0A, // Line feed or New line
            0x0D, // Carriage return
            0x20, // Space
        ]
        
        struct Structure {
            static let BeginArray: UInt8     = 0x5B // [
            static let EndArray: UInt8       = 0x5D // ]
            static let BeginObject: UInt8    = 0x7B // {
            static let EndObject: UInt8      = 0x7D // }
            static let NameSeparator: UInt8  = 0x3A // :
            static let ValueSeparator: UInt8 = 0x2C // ,
            static let QuotationMark: UInt8  = 0x22 // "
            static let Escape: UInt8         = 0x5C // \
        }
        
        typealias Index = Int
        typealias IndexDistance = Int
        
        let source: UnicodeSource
        
        func consumeWhitespace(_ input: Index) -> Index? {
            var index = input
            while let (char, nextIndex) = source.takeASCII(index), Reader.whitespaceASCII.contains(char) {
                index = nextIndex
            }
            return index
        }
        
        func consumeStructure(_ ascii: UInt8, input: Index) throws -> Index? {
            return try consumeWhitespace(input).flatMap(consumeASCII(ascii)).flatMap(consumeWhitespace)
        }
        
        func consumeASCII(_ ascii: UInt8) -> (Index) throws -> Index? {
            return { (input: Index) throws -> Index? in
                switch self.source.takeASCII(input) {
                case nil:
                    throw NSError(domain: NSCocoaErrorDomain, code: CocoaError.propertyListReadCorrupt.rawValue, userInfo: [
                        "NSDebugDescription" : "Unexpected end of file during JSON parse."
                        ])
                case let (taken, index)? where taken == ascii:
                    return index
                default:
                    return nil
                }
            }
        }
        
        func consumeASCIISequence(_ sequence: String, input: Index) throws -> Index? {
            var index = input
            for scalar in sequence.unicodeScalars {
                guard let nextIndex = try consumeASCII(UInt8(scalar.value))(index) else {
                    return nil
                }
                index = nextIndex
            }
            return index
        }
        
        func takeMatching(_ match: @escaping (UInt8) -> Bool) -> ([Character], Index) -> ([Character], Index)? {
            return { input, index in
                guard let (byte, index) = self.source.takeASCII(index), match(byte) else {
                    return nil
                }
                return (input + [Character(UnicodeScalar(byte))], index)
            }
        }
        
        //MARK: - String Parsing
        func parseString(_ input: Index) throws -> (String, Index)? {
            guard let beginIndex = try consumeWhitespace(input).flatMap(consumeASCII(Structure.QuotationMark)) else {
                return nil
            }
            var chunkIndex: Int = beginIndex
            var currentIndex: Int = chunkIndex
            
            var output: String = ""
            while source.hasNext(currentIndex) {
                guard let (ascii, index) = source.takeASCII(currentIndex) else {
                    currentIndex += source.step
                    continue
                }
                switch ascii {
                case Structure.QuotationMark:
                    output += try source.takeString(chunkIndex, end: currentIndex)
                    return (output, index)
                case Structure.Escape:
                    output += try source.takeString(chunkIndex, end: currentIndex)
                    if let (escaped, nextIndex) = try parseEscapeSequence(index) {
                        output += escaped
                        chunkIndex = nextIndex
                        currentIndex = nextIndex
                        continue
                    }
                    else {
                        throw NSError(domain: NSCocoaErrorDomain, code: CocoaError.propertyListReadCorrupt.rawValue, userInfo: [
                            "NSDebugDescription" : "Invalid escape sequence at position \(source.distanceFromStart(currentIndex))"
                            ])
                    }
                default:
                    currentIndex = index
                }
            }
            throw NSError(domain: NSCocoaErrorDomain, code: CocoaError.propertyListReadCorrupt.rawValue, userInfo: [
                "NSDebugDescription" : "Unexpected end of file during string parse."
                ])
        }
        
        func parseEscapeSequence(_ input: Index) throws -> (String, Index)? {
            guard let (byte, index) = source.takeASCII(input) else {
                throw NSError(domain: NSCocoaErrorDomain, code: CocoaError.propertyListReadCorrupt.rawValue, userInfo: [
                    "NSDebugDescription" : "Early end of unicode escape sequence around character"
                    ])
            }
            let output: String
            switch byte {
            case 0x22: output = "\""
            case 0x5C: output = "\\"
            case 0x2F: output = "/"
            case 0x62: output = "\u{08}" // \b
            case 0x66: output = "\u{0C}" // \f
            case 0x6E: output = "\u{0A}" // \n
            case 0x72: output = "\u{0D}" // \r
            case 0x74: output = "\u{09}" // \t
            case 0x75: return try parseUnicodeSequence(index)
            default: return nil
            }
            return (output, index)
        }
        
        func parseUnicodeSequence(_ input: Index) throws -> (String, Index)? {
            
            guard let (codeUnit, index) = parseCodeUnit(input) else {
                return nil
            }
            
            let isLeadSurrogate = UTF16.isLeadSurrogate(codeUnit)
            let isTrailSurrogate = UTF16.isTrailSurrogate(codeUnit)
            
            guard isLeadSurrogate || isTrailSurrogate else {
                // The code units that are neither lead surrogates nor trail surrogates
                // form valid unicode scalars.
                return (String(UnicodeScalar(codeUnit)!), index)
            }
            
            // Surrogates must always come in pairs.
            
            guard isLeadSurrogate else {
                // Trail surrogate must come after lead surrogate
                throw CocoaError.error(.propertyListReadCorrupt,
                                       userInfo: [
                                        "NSDebugDescription" : """
                                        Unable to convert unicode escape sequence (no high-surrogate code point) \
                                        to UTF8-encoded character at position \(source.distanceFromStart(input))
                                        """
                    ])
            }
            
            guard let (trailCodeUnit, finalIndex) = try consumeASCIISequence("\\u", input: index).flatMap(parseCodeUnit),
                UTF16.isTrailSurrogate(trailCodeUnit) else {
                    throw CocoaError.error(.propertyListReadCorrupt,
                                           userInfo: [
                                            "NSDebugDescription" : """
                                            Unable to convert unicode escape sequence (no low-surrogate code point) \
                                            to UTF8-encoded character at position \(source.distanceFromStart(input))
                                            """
                        ])
            }
            
            return (String(UTF16.decode(UTF16.EncodedScalar([codeUnit, trailCodeUnit]))), finalIndex)
        }
        
        func isHexChr(_ byte: UInt8) -> Bool {
            return (byte >= 0x30 && byte <= 0x39)
                || (byte >= 0x41 && byte <= 0x46)
                || (byte >= 0x61 && byte <= 0x66)
        }
        
        func parseCodeUnit(_ input: Index) -> (UTF16.CodeUnit, Index)? {
            let hexParser = takeMatching(isHexChr)
            guard let (result, index) = hexParser([], input).flatMap(hexParser).flatMap(hexParser).flatMap(hexParser),
                let value = Int(String(result), radix: 16) else {
                    return nil
            }
            return (UTF16.CodeUnit(value), index)
        }
        
        //MARK: - Number parsing
        private static let ZERO = UInt8(ascii: "0")
        private static let ONE = UInt8(ascii: "1")
        private static let NINE = UInt8(ascii: "9")
        private static let MINUS = UInt8(ascii: "-")
        private static let PLUS = UInt8(ascii: "+")
        private static let LOWER_EXPONENT = UInt8(ascii: "e")
        private static let UPPER_EXPONENT = UInt8(ascii: "E")
        private static let DECIMAL_SEPARATOR = UInt8(ascii: ".")
        private static let allDigits = (ZERO...NINE)
        private static let oneToNine = (ONE...NINE)
        
        private static let numberCodePoints: [UInt8] = {
            var numberCodePoints = Swift.Array(ZERO...NINE)
            numberCodePoints.append(contentsOf: [DECIMAL_SEPARATOR, MINUS, PLUS, LOWER_EXPONENT, UPPER_EXPONENT])
            return numberCodePoints
        }()
        
        
        func parseNumber(_ input: Index, options opt: JSONSerialization.ReadingOptions) throws -> (Number, Index)? {
            
            var isNegative = false
            var string = ""
            var isInteger = true
            var exponent = 0
            var positiveExponent = true
            var index = input
            var digitCount: Int?
            var ascii: UInt8 = 0    // set by nextASCII()
            
            // Validate the input is a valid JSON number, also gather the following
            // about the input: isNegative, isInteger, the exponent and if it is +/-,
            // and finally the count of digits including excluding an '.'
            func checkJSONNumber() throws -> Bool {
                // Return true if the next character is any one of the valid JSON number characters
                func nextASCII() -> Bool {
                    guard let (ch, nextIndex) = source.takeASCII(index),
                        Reader.numberCodePoints.contains(ch) else { return false }
                    
                    index = nextIndex
                    ascii = ch
                    string.append(Character(UnicodeScalar(ascii)))
                    return true
                }
                
                // Consume as many digits as possible and return with the next non-digit
                // or nil if end of string.
                func readDigits() -> UInt8? {
                    while let (ch, nextIndex) = source.takeASCII(index) {
                        if !Reader.allDigits.contains(ch) {
                            return ch
                        }
                        string.append(Character(UnicodeScalar(ch)))
                        index = nextIndex
                    }
                    return nil
                }
                
                guard nextASCII() else { return false }
                
                if ascii == Reader.MINUS {
                    isNegative = true
                    guard nextASCII() else { return false }
                }
                
                if Reader.oneToNine.contains(ascii) {
                    guard let ch = readDigits() else { return true }
                    ascii = ch
                    if [ Reader.DECIMAL_SEPARATOR, Reader.LOWER_EXPONENT, Reader.UPPER_EXPONENT ].contains(ascii) {
                        guard nextASCII() else { return false } // There should be at least one char as readDigits didnt remove the '.eE'
                    }
                } else if ascii == Reader.ZERO {
                    guard nextASCII() else { return true }
                } else {
                    throw NSError(domain: NSCocoaErrorDomain, code: CocoaError.propertyListReadCorrupt.rawValue,
                                  userInfo: ["NSDebugDescription" : "Numbers must start with a 1-9 at character \(input)." ])
                }
                
                if ascii == Reader.DECIMAL_SEPARATOR {
                    isInteger = false
                    guard readDigits() != nil else { return true }
                    guard nextASCII() else { return true }
                } else if Reader.allDigits.contains(ascii) {
                    throw NSError(domain: NSCocoaErrorDomain, code: CocoaError.propertyListReadCorrupt.rawValue,
                                  userInfo: ["NSDebugDescription" : "Leading zeros not allowed at character \(input)." ])
                }
                
                digitCount = string.count - (isInteger ? 0 : 1) - (isNegative ? 1 : 0)
                guard ascii == Reader.LOWER_EXPONENT || ascii == Reader.UPPER_EXPONENT else {
                    // End of valid number characters
                    return true
                }
                digitCount = digitCount! - 1
                
                // Process the exponent
                isInteger = false
                guard nextASCII() else { return false }
                if ascii == Reader.MINUS {
                    positiveExponent = false
                    guard nextASCII() else { return false }
                } else if ascii == Reader.PLUS {
                    positiveExponent = true
                    guard nextASCII() else { return false }
                }
                guard Reader.allDigits.contains(ascii) else { return false }
                exponent = Int(ascii - Reader.ZERO)
                while nextASCII() {
                    guard Reader.allDigits.contains(ascii) else { return false } // Invalid exponent character
                    exponent = (exponent * 10) + Int(ascii - Reader.ZERO)
                    if exponent > 324 {
                        // Exponent is too large to store in a Double
                        return false
                    }
                }
                return true
            }
            
            guard try checkJSONNumber() == true else { return nil }
            digitCount = digitCount ?? string.count - (isInteger ? 0 : 1) - (isNegative ? 1 : 0)
            
            return (Number(string, negative: isNegative, integer: isInteger, digit: digitCount!, exponent: exponent), index)
//            // Try Int64() or UInt64() first
//            if isInteger {
//                if isNegative {
//                    if digitCount! <= 19, let intValue = Int64(string) {
////                        return (NSNumber(value: intValue), index)
//                        return (Number.int(intValue), index)
//                    }
//                } else {
//                    if digitCount! <= 20, let uintValue = UInt64(string) {
////                        return (NSNumber(value: uintValue), index)
//                        return (Number.uint(uintValue), index)
//                    }
//                }
//            }
//            
//            // Decimal holds more digits of precision but a smaller exponent than Double
//            // so try that if the exponent fits and there are more digits than Double can hold
//            if digitCount! > 17 && exponent >= -128 && exponent <= 127,
//                let decimal = Decimal(string: string), decimal.isFinite {
////                return (NSDecimalNumber(decimal: decimal), index)
//                return (Number.decimal(decimal), index)
//            }
//            // Fall back to Double() for everything else
//            if let doubleValue = Double(string) {
//                return (Number.double(doubleValue), index)
//            }
//            return nil
        }
        
        //MARK: - Value parsing
        func parseValue(_ input: Index, options opt: JSONSerialization.ReadingOptions) throws -> (JSON, Index)? {
            if let (value, parser) = try parseString(input) {
                return (JSON.string(value), parser)
            }
            else if let parser = try consumeASCIISequence("true", input: input) {
                return (JSON.bool(true), parser)
            }
            else if let parser = try consumeASCIISequence("false", input: input) {
                return (JSON.bool(false), parser)
            }
            else if let parser = try consumeASCIISequence("null", input: input) {
                return (JSON.null, parser)
            }
            else if let (object, parser) = try parseObject(input, options: opt) {
                return (JSON.object(object), parser)
            }
            else if let (array, parser) = try parseArray(input, options: opt) {
                return (JSON.array(array), parser)
            }
            else if let (number, parser) = try parseNumber(input, options: opt) {
                return (JSON.number(number), parser)
            }
            return nil
        }
        
        //MARK: - Object parsing
        func parseObject(_ input: Index, options opt: JSONSerialization.ReadingOptions) throws -> (Object, Index)? {
            guard let beginIndex = try consumeStructure(Structure.BeginObject, input: input) else {
                return nil
            }
            var index = beginIndex
//            var output: [String: Any] = [:]
            let outObj: Object = [:]
            while true {
                if let finalIndex = try consumeStructure(Structure.EndObject, input: index) {
                    return (outObj, finalIndex)
                }
                
                if let (key, value, nextIndex) = try parseObjectMember(index, options: opt) {
//                    output[key] = value
                    outObj.append(value: value, for: key)
                    
                    if let finalParser = try consumeStructure(Structure.EndObject, input: nextIndex) {
                        return (outObj, finalParser)
                    }
                    else if let nextIndex = try consumeStructure(Structure.ValueSeparator, input: nextIndex) {
                        index = nextIndex
                        continue
                    }
                    else {
                        return nil
                    }
                }
                return nil
            }
        }
        
        func parseObjectMember(_ input: Index, options opt: JSONSerialization.ReadingOptions) throws -> (String, JSON, Index)? {
            guard let (name, index) = try parseString(input) else {
                throw NSError(domain: NSCocoaErrorDomain, code: CocoaError.propertyListReadCorrupt.rawValue, userInfo: [
                    "NSDebugDescription" : "Missing object key at location \(source.distanceFromStart(input))"
                    ])
            }
            guard let separatorIndex = try consumeStructure(Structure.NameSeparator, input: index) else {
                throw NSError(domain: NSCocoaErrorDomain, code: CocoaError.propertyListReadCorrupt.rawValue, userInfo: [
                    "NSDebugDescription" : "Invalid separator at location \(source.distanceFromStart(index))"
                    ])
            }
            guard let (value, finalIndex) = try parseValue(separatorIndex, options: opt) else {
                throw NSError(domain: NSCocoaErrorDomain, code: CocoaError.propertyListReadCorrupt.rawValue, userInfo: [
                    "NSDebugDescription" : "Invalid value at location \(source.distanceFromStart(separatorIndex))"
                    ])
            }
            
            return (name, value, finalIndex)
        }
        
        //MARK: - Array parsing
        func parseArray(_ input: Index, options opt: JSONSerialization.ReadingOptions) throws -> (Array, Index)? {
            guard let beginIndex = try consumeStructure(Structure.BeginArray, input: input) else {
                return nil
            }
            var index = beginIndex
            var output: Array = Array()
            while true {
                if let finalIndex = try consumeStructure(Structure.EndArray, input: index) {
                    return (output, finalIndex)
                }
                
                if let (value, nextIndex) = try parseValue(index, options: opt) {
                    output.append(value)
                    
                    if let finalIndex = try consumeStructure(Structure.EndArray, input: nextIndex) {
                        return (output, finalIndex)
                    }
                    else if let nextIndex = try consumeStructure(Structure.ValueSeparator, input: nextIndex) {
                        index = nextIndex
                        continue
                    }
                }
                throw NSError(domain: NSCocoaErrorDomain, code: CocoaError.propertyListReadCorrupt.rawValue, userInfo: [
                    "NSDebugDescription" : "Badly formed array at location \(source.distanceFromStart(index))"
                    ])
            }
        }
        
    }
    
    
    
}
