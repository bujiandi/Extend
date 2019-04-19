//
//  HTTPRequestEncoder.swift
//  Basic
//
//  Created by 李招利 on 2018/9/30.
//

import Foundation

public protocol HTTPPostEncoder {
    
    associatedtype Params
    associatedtype SignParams
        
    func sign(params:inout SignParams, url:URL!)
    
    func encode(params:Params?, request:inout URLRequest) throws -> Data?
    
}

public protocol HTTPGetEncoder {
    
    associatedtype Params
    associatedtype SignParams
    
    func sign(params:inout SignParams, url:URL!)
    
    func encode(params:Params?, url:URL) -> String?
    
}


extension HTTP {
    
    public struct Encoder {
        
         public struct Post {
            
            public static var upload:HTTP.UploadEncoder { return HTTP.uploadEncoder }
            public static var params:HTTP.ParamsEncoder { return HTTP.paramsEncoder }
            public static var json:HTTP.JSONEncoder { return HTTP.jsonEncoder }
            
        }
        
        public struct Get {
            
            public static var params:HTTP.ParamsEncoder { return HTTP.paramsEncoder }

        }
    }
    
}

