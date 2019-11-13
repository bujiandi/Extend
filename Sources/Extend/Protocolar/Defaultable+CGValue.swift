//
//  File.swift
//  
//
//  Created by 慧趣小歪 on 2019/11/13.
//

#if canImport(CoreGraphics)
import CoreGraphics

extension CGFloat: Defaultable {
    
    public static let defaultValue:CGFloat = 0
}
extension CGPoint: Defaultable {
    public static let defaultValue = Self.zero
}
extension CGSize: Defaultable {
    public static let defaultValue = Self.zero
}
extension CGRect: Defaultable {
    public static let defaultValue = Self.zero
}

#endif
