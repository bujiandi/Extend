//
//  HTTPParamsEncoder.swift
//  Basic
//
//  Created by bujiandi on 2018/9/30.
//

import Extend
import Foundation

extension HTTP {
    
    open class ParamsEncoder : HTTPPostEncoder, HTTPGetEncoder {
        
        public typealias Params = (inout Form) -> Void
        public typealias SignParams = [(String, Any?)]
        
        open func sign(params:inout [(String, Any?)], url:URL!) {}
        
        open func encode(params: ((inout Form) -> Void)?, request: inout URLRequest) -> Data? {
            
            #if DEBUG
            print("HTTP ->", request.url?.absoluteString ?? "nil")
            #endif
            
            var form = Form()
            params?(&form)
            if form.params.isEmpty { return nil }
            
            var list = form.params.map({ ($0.0, $0.1()) })
            
            // 参数加签
            sign(params: &list, url: request.url)
            
            let separator = "&".data(using: .utf8)!
            var data = Data()
            for (key, val) in list {
                if !data.isEmpty { data.append(separator) }
                let k = key.encodeURL()
                let v = unwrapOptionalToString(val).encodeURL()
                data.append("\(k)=\(v)", using: .utf8)
            }
            
            #if DEBUG
            print("POST ->", String(data: data, encoding: .utf8) ?? "nil")
            #endif
            
            request.setValue("application/x-www-form-urlencoded; charset=UTF-8", forHTTPHeaderField: "Content-Type")
            
            return data
        }
        
        open func encode(params:((inout Form) -> Void)?, url:URL) -> String? {
            
            var form = Form()
            params?(&form)
            if form.params.isEmpty {
                #if DEBUG
                print("HTTP ->", url.absoluteString)
                #endif
                return nil
            }
            
            var list = form.params.map({ ($0.0, $0.1()) })

            // 参数加签
            sign(params: &list, url: url)
            
            var data = [String]()
            data.reserveCapacity(list.count)
            for (key, val) in list {
                let k = key.encodeURL()
                let v = unwrapOptionalToString(val).encodeURL()
                data.append("\(k)=\(v)")
            }
            
            #if DEBUG
            print("HTTP ->", url.absoluteString + "?" + data.joined(separator: "&"))
            #endif
            return data.joined(separator: "&")
        }
        
        public init() {}
    }

    // 默认POST/GET编码器, 可修改
    public static var paramsEncoder = HTTP.ParamsEncoder()
}

extension HTTP.ParamsEncoder {
    
    public struct Form: Collection, RangeReplaceableCollection {
        
        public typealias Index = Int
        public typealias Element = (String, () -> Any?)
        public typealias SubSequence = ArraySlice<Element>
        
        var params:[Element] = []
        public init() {}

        public var startIndex: Int { return params.startIndex }
        public var endIndex: Int { return params.endIndex }
        public var count: Int { return params.count }
        
        public func index(after i: Int) -> Int {
            return params.index(after: i)
        }
        
        public subscript(bounds: Int) -> Element {
            get { return params[bounds] }
            set { params[bounds] = newValue }
        }
        
        public mutating func replaceSubrange<C>(_ subrange: Range<Int>, with newElements: C) where C : Collection, Element == C.Element {
            params.replaceSubrange(subrange, with: newElements)
        }
        
        public mutating func append<C>(_ key:String, values:C) where C : Collection, C.Element : RawRepresentable {
            var iterator = values.makeIterator()
            while let element = iterator.next() {
                append(key, closure: { element.rawValue })
            }
        }
        
        public mutating func append<C>(_ key:String, values:C) where C : Collection {
            var iterator = values.makeIterator()
            while let element = iterator.next() {
                append(key, closure: { element })
            }
        }
        
        public mutating func append<T>(_ key:String, value closure: @autoclosure () -> T) where T : RawRepresentable {
            let value = closure()
            append(key, closure: { value.rawValue })
        }
        

        public mutating func append(_ key:String, value closure: @autoclosure () -> Any) {
            let value = closure()
            append(key, closure: { value })
        }
        
        public mutating func append(_ key:String, closure: @escaping () -> Any?) {
            params.append((key, closure))
        }
        
    }
    
}

extension HTTP.Request {
    
    public mutating func get(params:((inout HTTP.ParamsEncoder.Form) -> Void)?) {
        get(encoder: HTTP.Encoder.Get.params, params: params)
        
    }
    
    public mutating func post(params:((inout HTTP.ParamsEncoder.Form) -> Void)?) {
        post(encoder: HTTP.Encoder.Post.params, params: params)
    }
    
}
