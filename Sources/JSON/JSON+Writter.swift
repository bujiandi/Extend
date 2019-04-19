//
//  JSON+Writter.swift
//  TestJSON
//
//  Created by 李招利 on 2019/1/9.
//  Copyright © 2019 jwl. All rights reserved.
//

import Foundation
#if os(macOS) || os(iOS)
import Darwin
#elseif os(Linux) || CYGWIN
import Glibc
#endif

extension JSON {
    
    internal struct Writer {
        
        var indent = 0
        let pretty: Bool
        let sortedKeys: Bool
        let writer: (String?) -> Void
        
        init(pretty: Bool = false, sortedKeys: Bool = false, writer: @escaping (String?) -> Void) {
            self.pretty = pretty
            self.sortedKeys = sortedKeys
            self.writer = writer
        }
        
        mutating func serializeJSON(_ json: JSON) {
            
            switch json {
            case .null:
                writer("null")
            case .string(let str):
                serializeString(str)
            case .number(let value):
                writer(value.rawValue)
            case .bool(let yesOrNo):
                writer(yesOrNo.description)
            case .array(let array):
                serializeArray(array)
            case .object(let obj):
                serializeObject(obj)
            case .error(let error, _):
                if pretty {
                    serializeString("(--->\(error.localizedDescription)<---)")
                }
            }
        }
        
        func serializeString(_ str: String) {
            writer("\"")
            if pretty {
                writer(str)
            } else {
                for scalar in str.unicodeScalars {
                    switch scalar {
                    case "\"":
                        writer("\\\"") // U+0022 quotation mark
                    case "\\":
                        writer("\\\\") // U+005C reverse solidus
                    case "/":
                        writer("\\/") // U+002F solidus
                    case "\u{8}":
                        writer("\\b") // U+0008 backspace
                    case "\u{c}":
                        writer("\\f") // U+000C form feed
                    case "\n":
                        writer("\\n") // U+000A line feed
                    case "\r":
                        writer("\\r") // U+000D carriage return
                    case "\t":
                        writer("\\t") // U+0009 tab
                    case "\u{0}"..."\u{f}":
                        writer("\\u000\(String(scalar.value, radix: 16))") // U+0000 to U+000F
                    case "\u{10}"..."\u{1f}":
                        writer("\\u00\(String(scalar.value, radix: 16))") // U+0010 to U+001F
                    default:
                        writer(String(scalar))
                    }
                }
            }
            writer("\"")
        }
        
        
        mutating func serializeArray(_ array: Array) {
            writer("[")
            if pretty {
                writer("\n")
                incAndWriteIndent()
            }
            
            var first = true
            for elem in array {
                if first {
                    first = false
                } else if pretty {
                    writer(",\n")
                    writeIndent()
                } else {
                    writer(",")
                }
                serializeJSON(elem)
            }
            if pretty {
                writer("\n")
                decAndWriteIndent()
            }
            writer("]")
        }
        
        mutating func serializeObject(_ obj: Object) {
            writer("{")
            if pretty {
                writer("\n")
                incAndWriteIndent()
            }
            
            var first = true
            
            func serializeDictionaryElement(key: String, value: JSON) {
                if first {
                    first = false
                } else if pretty {
                    writer(",\n")
                    writeIndent()
                } else {
                    writer(",")
                }
                
                serializeString(key)
                pretty ? writer(" : ") : writer(":")
                serializeJSON(value)
            }
            
            if sortedKeys {
                
                let keys:[String] = obj._keys.sorted { a, b in
                    let options: NSString.CompareOptions = [.numeric, .caseInsensitive, .forcedOrdering]
                    let range: Range<String.Index>  = a.startIndex..<a.endIndex
                    let locale = NSLocale.system
                    
                    return a.compare(b, options: options, range: range, locale: locale) == .orderedAscending
                }
                for elem in keys {
                    let value = obj._map[elem] ?? JSON.null
                    serializeDictionaryElement(key: elem, value: value)
                }
            } else {
                for elem in obj._keys {
                    let value = obj._map[elem] ?? JSON.null
                    serializeDictionaryElement(key: elem, value: value)
                }
            }
            
            if pretty {
                writer("\n")
                decAndWriteIndent()
            }
            writer("}")
        }
        
        func serializeNull() {
            writer("null")
        }
        
        let indentAmount = 2
        
        mutating func incAndWriteIndent() {
            indent += indentAmount
            writeIndent()
        }
        
        mutating func decAndWriteIndent() {
            indent -= indentAmount
            writeIndent()
        }
        
        func writeIndent() {
            for _ in 0..<indent {
                writer(" ")
            }
        }
        
    }
    
    
}


