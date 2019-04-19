//
//  HTTPError.swift
//  Basic
//
//  Created by 李招利 on 2018/9/30.
//

#if canImport(JSON)
import JSON
#endif
import Foundation

extension HTTP {
    
    
    public enum ResponseError : Error {
        
        case unknowCharSet(Data)
        case unknowJSONData(Data, DecodingError)
        case unknowBookmark(Data, isStale:Bool)
        case unknowImageURL(URL?, URL)
        case unknowJSONForm(JSON)
        case unknowfailJSON(JSON, String)
        
        public var localizedDescription: String {
            switch self {
            case .unknowCharSet:    return "未知的字符编码"
            case .unknowJSONData:   return "数据不是标准JSON格式"
            case .unknowBookmark:   return "无法从Bookmark恢复已下载数据"
            case .unknowImageURL:   return "无效的图片数据格式"
            case .unknowJSONForm:   return "缺少标准参数，数据未知来源"
            case .unknowfailJSON(_, let text): return text
            }
        }
    }
    
    
    public enum RequestError : Error {
        
        case failStatusCode(Int, String)
        case failureRequest(Error)
        case postJSONError(JSON.Error, ignore:[String])
        case canceled
        
        public var localizedDescription: String {
            switch self {
            case .failureRequest(let error):    return error.localizedDescription
            case .failStatusCode(_, let text):  return text
            case .canceled:                     return "请求被取消"
            case .postJSONError(let error, let ignore):
                let path = ignore.joined(separator: "/")
                return error.debugDescription + ", ignore path: \(path)"
            }
        }
        
        public var isCanceled:Bool {
            if case .canceled = self { return true }
            return false
        }
        
    }
    
    
}



