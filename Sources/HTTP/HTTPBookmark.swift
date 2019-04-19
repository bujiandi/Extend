//
//  HTTPBookmark.swift
//  HTTP
//
//  Created by bujiandi on 2019/4/19.
//

import Foundation
import MD5

extension HTTP {
    
    /// 下载文件路径 从文件标签获得
    public static func filePathBy(bookmark:String) -> String {
        let fileManager = FileManager.default
        
        // 文件不存在或不是目录 则创建
        var isDir:ObjCBool = false
        if !fileManager.fileExists(atPath: bookmark, isDirectory: &isDir) || isDir.boolValue {
            return String.Empty
        }
        
        // 如果 下载文件标签0字节 则直接开始下载
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: bookmark)), data.count > 0 else {
            return String.Empty
        }
        // 如果 下载文件标签无效 则直接开始下载
        var isStale = false
        guard let fileURL = try? URL(resolvingBookmarkData: data, bookmarkDataIsStale: &isStale) else {
            return String.Empty
        }
        
        // 如果书签数据不存在或者已删除 则 删除书签 并 重新下载
        let filePath = fileURL.relativePath
        if !fileManager.fileExists(atPath: filePath, isDirectory: &isDir) || isDir.boolValue {
            return String.Empty
        }
        
        return filePath
    }
    
    /// 文件标签对应下载文件的尺寸
    public static func fileSizeBy(bookmark:String) -> Int {
        let filePath = filePathBy(bookmark: bookmark)
        
        if filePath.length == 0 { return 0 }
        
        guard let fileAttr = try? FileManager.default.attributesOfItem(atPath: filePath) else {
            return 0
        }
        
        let size = "\(String(describing: fileAttr[FileAttributeKey.size]))" as NSString
        return size.integerValue
    }
    
    /// url对应已下载的尺寸
    public static func fileSizeBy(url:URL) -> Int {
        return fileSizeBy(bookmark: bookmarkFileFor(key: url.absoluteString))
    }
    
    /// 文件标签二进制路径
    public static func bookmarkFileFor(key:String) -> String {
        return bookmarkPathFor(key: key).stringByAppending(pathComponent: "download.mark")
        
    }
    
    /// 文件标签目录
    public static func bookmarkPathFor(key:String) -> String {
        let fileName = createFileNameFor(key: key)
        
        let identifier = Bundle.main.bundleIdentifier ?? "com.appfenfen.downloads"
        
        let downRoot = getDiskCachePathFor(nameSpace: identifier)
        let bookmark = downRoot.stringByAppending(pathComponent: "bookmarks")
        
        return bookmark.stringByAppending(pathComponent: fileName)
    }
    
    /// 用key的哈希值来生成文件名
    public static func createFileNameFor(key:String) -> String {
        return key.md5
    }
    
    /// 获取磁盘缓存路径 根据命名空间
    public static func getDiskCachePathFor(nameSpace:String) -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)
        return paths[0].stringByAppending(pathComponent: nameSpace)
    }
    
}
