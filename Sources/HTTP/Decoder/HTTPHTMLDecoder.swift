//
//  HTTPHTMLDecoder.swift
//  Basic
//
//  Created by 李招利 on 2018/9/30.
//

import Foundation

extension HTTP {
    
    open class HTMLDecoder : HTTPResponeDecoder {
        
        public typealias Result = String
        
        public init() {}
        
        open func decode(request:URLRequest, response:HTTPURLResponse, data:Data) throws -> Result {
            guard let result = String(data: data, encoding: .utf8) else {
                throw HTTP.ResponseError.unknowCharSet(data)
            }
            return result
        }
    }
    
    public static var htmlDecoder = HTMLDecoder()
}



extension HTTP.Request {
    
    public mutating func responseHTML(_ onSuccess: @escaping (String) throws -> Void) {
        response(decoder: HTTP.Decoder.html, onSuccess: onSuccess)
    }
    
}
