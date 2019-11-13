//
//  Calculable+CGValue.swift
//  Protocolar
//
//  Created by bujiandi on 2019/4/18.
//

#if canImport(CoreGraphics)
import CoreGraphics

extension CGFloat   : Calculable {}
extension CGPoint   : Calculable {
    
    //@inline(__always)
    @inlinable public static func + (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
    
    @inlinable public static func - (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }
    
    @inlinable public static func * (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x * rhs.x, y: lhs.y * rhs.y)
    }
    
    @inlinable public static func / (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x / rhs.x, y: lhs.y / rhs.y)
    }
    
    @inlinable public static func < (lhs: CGPoint, rhs: CGPoint) -> Bool {
        return lhs.x < rhs.x && lhs.y < rhs.y
    }
}
extension CGSize    : Calculable {
    
    @inlinable public static func + (lhs: CGSize, rhs: CGSize) -> CGSize {
        return CGSize(width: lhs.width + rhs.width, height: lhs.height + rhs.height)
    }
    
    @inlinable public static func - (lhs: CGSize, rhs: CGSize) -> CGSize {
        return CGSize(width: lhs.width - rhs.width, height: lhs.height - rhs.height)
    }
    
    @inlinable public static func * (lhs: CGSize, rhs: CGSize) -> CGSize {
        return CGSize(width: lhs.width * rhs.width, height: lhs.height * rhs.height)
    }
    
    @inlinable public static func / (lhs: CGSize, rhs: CGSize) -> CGSize {
        return CGSize(width: lhs.width / rhs.width, height: lhs.height / rhs.height)
    }
    
    @inlinable public static func < (lhs: CGSize, rhs: CGSize) -> Bool {
        return lhs.width < rhs.width && lhs.height < rhs.height
    }
}
extension CGRect    : Calculable {
    
    @inlinable public static func + (lhs: CGRect, rhs: CGRect) -> CGRect {
        return CGRect(origin: lhs.origin + rhs.origin, size: lhs.size + rhs.size)
    }
    
    @inlinable public static func - (lhs: CGRect, rhs: CGRect) -> CGRect {
        return CGRect(origin: lhs.origin - rhs.origin, size: lhs.size - rhs.size)
    }
    
    @inlinable public static func * (lhs: CGRect, rhs: CGRect) -> CGRect {
        return CGRect(origin: lhs.origin * rhs.origin, size: lhs.size * rhs.size)
    }
    
    @inlinable public static func / (lhs: CGRect, rhs: CGRect) -> CGRect {
        return CGRect(origin: lhs.origin / rhs.origin, size: lhs.size / rhs.size)
    }
    
    @inlinable public static func < (lhs: CGRect, rhs: CGRect) -> Bool {
        return lhs.origin < rhs.origin && lhs.size < rhs.size
    }
}
#endif
