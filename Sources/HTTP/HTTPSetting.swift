//
//  HTTPSetting.swift
//  HTTP
//
//  Created by 李招利 on 2019/4/19.
//

import Foundation

extension HTTP {
    
    public static var timeout:TimeInterval = 15
    /// 服务器时间 至少有一次网络请求成功才正确
    public static var serverDate:Date {
        return Date(timeIntervalSince1970: Date().timeIntervalSince1970 + timeOffset)
    }
    
    internal static var timeOffset:TimeInterval = 0

}
