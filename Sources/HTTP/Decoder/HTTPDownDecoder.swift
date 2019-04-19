//
//  HTTPDownDecoder.swift
//  Basic
//
//  Created by 李招利 on 2018/9/30.
//

import Foundation

extension HTTP {
    
    open class DownDecoder : HTTPResponeDecoder {
        
        public typealias Result = URL
        
        public init() {}
        
        open func decode(request:URLRequest, response:HTTPURLResponse, data:Data) throws -> Result {
            var isStale:Bool = false
            guard let localURL = try? URL(resolvingBookmarkData: data, bookmarkDataIsStale: &isStale) else {
                throw HTTP.ResponseError.unknowBookmark(data, isStale: isStale)
            }
            return localURL
        }
        
    }

    public static var downDecoder = DownDecoder()
}

// Look HTTPDownload.swift
