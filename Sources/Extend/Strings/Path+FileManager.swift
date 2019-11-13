//
//  Path+FileManager.swift
//  Extend
//
//  Created by 李招利 on 2019/4/18.
//

#if canImport(Foundation)
import Foundation

extension Path {
    
    public var url:URL { return URL(fileURLWithPath: absolute) }
    
    // MARK: 文件属性
    public func loadAttributes() throws -> [FileAttributeKey : Any] {
        return try FileManager.default.attributesOfItem(atPath: absolute)
    }
    
    // MARK: 文件路径
    
    // MARK: 文件大小
    public func fileSize() -> UInt64 {
        let fileManager:FileManager = FileManager.default
        let fullPath = absolute
        var directory:ObjCBool = false
        let exists = fileManager.fileExists(atPath: fullPath, isDirectory: &directory)
        if (exists && !directory.boolValue) {
            let attributes = (try? fileManager.attributesOfItem(atPath: fullPath)) ?? [:]
            let size:UInt64 = attributes[.size] as! UInt64
            return size
        }
        return 0
    }
    
    // MARK: 判断目录中存在指定 1-n个文件名
    public func exists(subNames:[String]) throws -> Bool {
        if subNames.count == 0 { return false }
        var names = subNames
        let fileManager:FileManager = FileManager.default
        do {
            let fileNames:[String] = try fileManager.contentsOfDirectory(atPath: absolute)
            for fileName in fileNames {
                if names.count == 0 { break }
                if let index = names.firstIndex(where: { $0 == fileName })  {
                    names.remove(at: index)
                }
            }
            return names.count == 0
        } catch {}
        return false
    }
    
    //删除文件或文件夹
    public func delete() throws {
        let fullPath = absolute
        let fileManager = FileManager.default
        var directory:ObjCBool = false
        let exists = fileManager.fileExists(atPath: fullPath, isDirectory: &directory)
        var deleteSubPathError:Error? = nil
        if exists, directory.boolValue {
            let subs = try subPaths()
            // 确保删除所有可以删除的, 不能删除的暂时跳过
            for sub in subs {
                do {
                    try sub.delete()
                } catch let error {
                    deleteSubPathError = error
                }
            }
        }
        try FileManager.default.removeItem(atPath: fullPath)
        if let error = deleteSubPathError { throw error }
    }
    
    // MARK: 创建所有不存在的父路径
    public func makeParentDirs(attributes: [FileAttributeKey : Any]? = nil) throws {
        if components.count <= 1 { return }
        let fileManager = FileManager.default
        var pathComponents = components
        pathComponents.removeLast()
        let parentPath = Path(pathComponents).absolute
        var directory:ObjCBool = false
        let exists = fileManager.fileExists(atPath: parentPath, isDirectory: &directory)
        if !(exists && directory.boolValue) {
            try fileManager.createDirectory(atPath: parentPath, withIntermediateDirectories: true, attributes: attributes)
        }
    }
    
    // MARK: 拷贝文件到指定路径 自动创建所有父路径
    @inlinable public func copy(toPath path:Path) throws {
        try path.makeParentDirs()
        try FileManager.default.copyItem(atPath: absolute, toPath: path.absolute)
    }
    
    // MARK: 移动文件到指定路径 自动创建所有父路径
    @inlinable public func move(toPath path:Path) throws {
        try path.makeParentDirs()
        try FileManager.default.moveItem(atPath: absolute, toPath: path.absolute)
    }
    
    // MARK: 文件重命名
    @inlinable public mutating func rename(to newFileName:String) throws {
        if components.isEmpty {
            throw "Rename to \(newFileName) error: because it's root path" as StringError
        }
        var newComponents = components
        newComponents.removeLast()
        newComponents.append(newFileName)
        try move(toPath: Path(newComponents))
        components = newComponents
    }
    
    // MARK: 文件状态
    public var isExists:Bool {
        return FileManager.default.fileExists(atPath: absolute)
    }
    public var isExecutable:Bool {
        return FileManager.default.isExecutableFile(atPath: absolute)
    }
    public var isDeletable:Bool {
        return FileManager.default.isDeletableFile(atPath: absolute)
    }
    public var isDirectory:Bool {
        var directory:ObjCBool = false
        FileManager.default.fileExists(atPath: absolute, isDirectory: &directory)
        return directory.boolValue
    }
    
    public subscript(subFileName:String) -> Path? {
        let names:[String]
        do {
            names = try FileManager.default.contentsOfDirectory(atPath: absolute)
        } catch let error {
            print(error.localizedDescription)
            return nil
        }
        if names.contains(subFileName) {
            return Path(components + [subFileName])
        }
        return nil
    }
    // MARK: 所有子文件
    public func subPaths() throws -> [Path] {
        var paths:[Path] = []
        let fileManager:FileManager = FileManager.default
        let fileNames:[String] = try fileManager.contentsOfDirectory(atPath: absolute)
        for fileName in fileNames {
            paths.append(Path(components + [fileName]))
        }
        return paths
    }
    
    // MARK: - 系统默认文件路径
    public static func systemDirectory(pathType:FileManager.SearchPathDirectory, domainMask:FileManager.SearchPathDomainMask = .userDomainMask) -> Path {
        let path = NSSearchPathForDirectoriesInDomains(pathType, domainMask, true)[0]
        return Path(path)
    }
    
    public static var documentDirectory:Path { return systemDirectory(pathType: .documentDirectory) }
    public static var downloadDirectory:Path { return systemDirectory(pathType: .downloadsDirectory) }
    public static var cacheDirectory:Path { return systemDirectory(pathType: .cachesDirectory) }
    
    public static func homeDirectoryForUser(userName:String) -> Path {
        if let path = NSHomeDirectoryForUser(userName) {
            return Path(path)
        }
        return Path(NSHomeDirectory())
    }
    public static var homeDirectory:Path { return Path(NSHomeDirectory()) }
    public static var temporaryDirectory:Path { return Path(NSTemporaryDirectory()) }
    public static var openStepRootDirectory:Path { return Path(NSOpenStepRootDirectory()) }
    public static var fullUserName:String { return NSFullUserName() }
    public static var userName:String { return NSUserName() }
}
#endif
