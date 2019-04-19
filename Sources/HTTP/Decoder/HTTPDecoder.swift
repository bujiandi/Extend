//
//  HTTPDecoder.swift
//  Basic
//
//  Created by 李招利 on 2018/9/30.
//

import Foundation

public protocol HTTPResponeDecoder {
    
    associatedtype Result
    
    func decode(request:URLRequest, response:HTTPURLResponse, data:Data) throws -> Result
    
}

extension HTTP {
    
    public struct Decoder {
        
        public static var down:HTTP.DownDecoder { return HTTP.downDecoder }
        public static var html:HTTP.HTMLDecoder { return HTTP.htmlDecoder }
        public static var json:HTTP.JSONDecoder { return HTTP.jsonDecoder }
            
    }
    
}
