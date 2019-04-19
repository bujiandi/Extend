//
//  HTTPJSONEncoder.swift
//  Basic
//
//  Created by 李招利 on 2018/9/30.
//

#if canImport(JSON)
import JSON
#endif
import Foundation

extension HTTP {
    
    open class JSONEncoder : HTTPPostEncoder {
        
        public typealias Params = (inout JSON) -> Void
        public typealias SignParams = JSON
        
        open func sign(params: inout JSON, url:URL!) {}
        
        open func encode(params: ((inout JSON) -> Void)?, request: inout URLRequest) throws -> Data? {
            
            #if DEBUG
            print("HTTP ->", request.url?.absoluteString ?? "nil")
            #endif

            var json = JSON.null
            params?(&json)
            
            request.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")

            if json.isNull { return nil }
            
            if case let .error(error, ignore) = json {
                throw HTTP.RequestError.postJSONError(error, ignore: ignore)
            }
            
            // 参数加签
            sign(params: &json, url: request.url)
            
            #if DEBUG
            print("POST ->", json.debugDescription)
            #endif
            
            return json.serializeData()
        }
        
        public init() {}
    }
    

    // 默认JSON编码器, 可修改
    public static var jsonEncoder = HTTP.JSONEncoder()
}

extension HTTP.Request {
    
    public mutating func post(json:JSON) {
        post(encoder: HTTP.Encoder.Post.json) { $0 = json }
    }
    
    public mutating func postJSON(_ json:((inout JSON) -> Void)?) {
        post(encoder: HTTP.Encoder.Post.json, params: json)
    }
    
}
