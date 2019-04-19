//
//  NSBundle + ZS.swift
//  Tools
//
//  Created by KellenのMac on 2017/5/2.
//  Copyright © 2017年 cn.steven. All rights reserved.
//

import Foundation

extension Bundle {
    
    public var shortVersion:String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
    
    public var version:String? {
        return infoDictionary?["CFBundleVersion"] as? String
    }

}
