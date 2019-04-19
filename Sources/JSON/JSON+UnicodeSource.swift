//
//  JSON+UnicodeSource.swift
//  TestJSON
//
//  Created by 李招利 on 2019/1/7.
//  Copyright © 2019 jwl. All rights reserved.
//

import Foundation

extension JSON {

    internal struct UnicodeSource {
        let buffer: UnsafeBufferPointer<UInt8>
        let encoding: String.Encoding
        let step: Int
        
        init(buffer: UnsafeBufferPointer<UInt8>, encoding: String.Encoding) {
            self.buffer = buffer
            self.encoding = encoding
            
            self.step = {
                switch encoding {
                case .utf8:
                    return 1
                case .utf16BigEndian, .utf16LittleEndian:
                    return 2
                case .utf32BigEndian, .utf32LittleEndian:
                    return 4
                default:
                    return 1
                }
            }()
        }
        
        func takeASCII(_ input: Index) -> (UInt8, Index)? {
            guard hasNext(input) else {
                return nil
            }
            
            let index: Int
            switch encoding {
            case .utf8:
                index = input
            case .utf16BigEndian where buffer[input] == 0:
                index = input + 1
            case .utf32BigEndian where buffer[input] == 0 && buffer[input+1] == 0 && buffer[input+2] == 0:
                index = input + 3
            case .utf16LittleEndian where buffer[input+1] == 0:
                index = input
            case .utf32LittleEndian where buffer[input+1] == 0 && buffer[input+2] == 0 && buffer[input+3] == 0:
                index = input
            default:
                return nil
            }
            return (buffer[index] < 0x80) ? (buffer[index], input + step) : nil
        }
        
        func takeString(_ begin: Index, end: Index) throws -> String {
            let byteLength = begin.distance(to: end)
            
            guard let chunk = String(data: Data(bytes: buffer.baseAddress!.advanced(by: begin), count: byteLength), encoding: encoding) else {
                throw NSError(domain: NSCocoaErrorDomain, code: CocoaError.propertyListReadCorrupt.rawValue, userInfo: [
                    "NSDebugDescription" : "Unable to convert data to a string using the detected encoding. The data may be corrupt."
                    ])
            }
            return chunk
        }
        
        func hasNext(_ input: Index) -> Bool {
            return input + step <= buffer.endIndex
        }
        
        func distanceFromStart(_ index: Index) -> Int {
            return buffer.startIndex.distance(to: index) / step
        }
    }
    
    
}
