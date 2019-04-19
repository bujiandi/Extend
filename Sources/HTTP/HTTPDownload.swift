//
//  HTTPDownload.swift
//  Basic
//
//  Created by 李招利 on 2018/10/9.
//

import Foundation

#if os(iOS)
//extension URL {
//    
//    @available(iOS 4.0, *)
//    public init(resolvingBookmarkData bookmarkData: Data, options: NSURL.BookmarkResolutionOptions = [], relativeTo relativeURL: URL? = nil, bookmarkDataIsStale isStale: inout Bool) throws {
//        var objcStale:ObjCBool = false
//        self = try NSURL(resolvingBookmarkData: bookmarkData, options: options, relativeTo: relativeURL, bookmarkDataIsStale: &objcStale) as URL
//        isStale = objcStale.boolValue
//    }
//    
//}
#endif

extension HTTP {
    
    public enum DownloadTarget {
        case toBookmarkCache
        case toFixedURL(URL)
    }
    
    static var _willDownload:(Queue, Request, Int64, Int64, (URLSession.ResponseDisposition) -> Void) -> Void = { (queue, request, totalSize, localSize, completionHandler) in
        completionHandler(.becomeDownload)
    }
    
    public static func willDownload(_ callback: @escaping (Queue, Request, Int64, Int64, (URLSession.ResponseDisposition) -> Void) -> Void) {
        _willDownload = callback
    }
}

extension HTTP.Request {
    
    public mutating func downloadToBookmarkCache(_ previewCacheIfExists: ((URL) -> Void)? = nil) {
        _downloadTarget = .toBookmarkCache
        _previewCacheIfExists(previewCacheIfExists)
    }
    
    public mutating func download(to url:URL, _ previewCacheIfExists: ((URL) -> Void)? = nil) {
        _downloadTarget = .toFixedURL(url)
        _previewCacheIfExists(previewCacheIfExists)
    }
    
    public mutating func download(to path:String, _ previewCacheIfExists: ((URL) -> Void)? = nil) {
        _downloadTarget = .toFixedURL(URL(fileURLWithPath: path))
        _previewCacheIfExists(previewCacheIfExists)
    }
    
    private mutating func _previewCacheIfExists(_ method: ((URL) -> Void)?) {
        _previewDownCache = method
    }
}
