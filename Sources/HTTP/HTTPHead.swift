//
//  HTTPHead.swift
//  HTTP
//
//  Created by 李招利 on 2019/4/19.
//

import Foundation

extension HTTP {
    
    public static var acceptLanguage = Locale
        .preferredLanguages
        .prefix(6)
        .enumerated()
        .map { "\($1);q=\(1.0 - (Double($0) * 0.1))" } // $1 = languageCode, $0 = index
        .joined(separator: ", ")
    
    
    public static var userAgent: String = {
        
        let netFrameworkVersion: String = {
            guard
                let afInfo = Bundle(for: HTTP.Client.self).infoDictionary,
                let build = afInfo["CFBundleShortVersionString"]
                else { return "Unknown" }
            
            return "fenfen/\(build)"
        }()
        
        if let info = Bundle.main.infoDictionary {
            let executable = info[kCFBundleExecutableKey as String] as? String ?? "Unknown"
            let bundle = info[kCFBundleIdentifierKey as String] as? String ?? "Unknown"
            let appVersion = info["CFBundleShortVersionString"] as? String ?? "Unknown"
            let appBuild = info[kCFBundleVersionKey as String] as? String ?? "Unknown"
            
            let osNameVersion: String = {
                let version = ProcessInfo.processInfo.operatingSystemVersion
                let versionString = "\(version.majorVersion).\(version.minorVersion).\(version.patchVersion)"
                
                let osName: String = {
                    #if os(iOS)
                    return "iOS"
                    #elseif os(watchOS)
                    return "watchOS"
                    #elseif os(tvOS)
                    return "tvOS"
                    #elseif os(macOS)
                    return "OS X"
                    #elseif os(Linux)
                    return "Linux"
                    #else
                    return "Unknown"
                    #endif
                }()
                
                return "\(osName) \(versionString)"
            }()
            
            return "\(executable)/\(appVersion) (\(bundle); build:\(appBuild); \(osNameVersion)) \(netFrameworkVersion)"
        }
        return netFrameworkVersion
    }()
}
