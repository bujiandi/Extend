//
//  Rich.swift
//  Toast
//
//  Created by 慧趣小歪 on 2017/11/9.
//  Copyright © 2017年 yFenFen. All rights reserved.
//
import Foundation
import CoreGraphics

#if os(iOS)
import UIKit
#elseif os(macOS)
import Cocoa
#endif

public enum Rich: ExpressibleByStringLiteral {
    case text(String)
    case rich(NSMutableAttributedString)
    
    public typealias StringLiteralType = String
    
    public init(stringLiteral value: StringLiteralType) {
        self = .text(value)
    }
    
    public var string:String {
        switch self {
        case let .text(value): return value
        case let .rich(value): return value.string
        }
    }
    
    public var attributedString:NSAttributedString {
        switch self {
        case let .text(value): return NSAttributedString(string: value)
        case let .rich(value): return value
        }
    }
    
    public subscript(_ style:RichStyle) -> Rich {
        
        var rich:NSMutableAttributedString!
        switch self {
        case let .rich(value): rich = value
        case let .text(value): rich = NSMutableAttributedString(string: value)
        }
        let range = NSRange(location: 0, length: rich.length)
        switch style {
        /// [paragraphStyle] default NSParagraphStyle defaultParagraphStyle
        case let .paragraph(value):
            let paragraph = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
            value(paragraph)
            rich.addAttribute(.paragraphStyle, value: paragraph, range: range)
        /// [font] default Helvetica(Neue) 12
        case let .font(value):
            rich.addAttribute(.font, value: value, range: range)
        /// [foregroundColor] default blackColor
        case let .color(value):
            rich.addAttribute(.foregroundColor, value: value, range: range)
        /// [backgroundColor] default nil: no background
        case let .background(value):
            rich.addAttribute(.backgroundColor, value: value, range: range)
        /// [ligature] default 1, 0: no ligatures
        case let .ligature(value):
            rich.addAttribute(.ligature, value: value, range: range)
        /// [kern] default 0 means kerning is disabled.
        case let .kern(value):
            rich.addAttribute(.kern, value: value, range: range)
        /// [expansion] default 0: no expansio, width for text
        case let .expansion(value):
            rich.addAttribute(.expansion, value: value, range: range)
        /// [obliqueness] default 0: no skew. skew to be applied to glyphs.
        case let .obliqueness(value):
            rich.addAttribute(.obliqueness, value: value, range: range)
        /// [underlineColor], [underlineStyle]
        case let .underline(color, value):
            rich.addAttribute(.underlineStyle, value: value.rawValue, range: range)
            if let color = color {
                rich.addAttribute(.underlineColor, value: color, range: range)
            }
        /// [strikethroughColor] default nil: same as foreground color, [strikethroughStyle] default 0: no strikethrough
        case let .strikethrough(color, value):
            rich.addAttribute(.strikethroughStyle, value: value.rawValue, range: range)
            if let color = color {
                rich.addAttribute(.strikethroughColor, value: color, range: range)
            }
        /// [strokeColor] default nil: same as foreground color, [strokeWidth] default 0: no stroke; positive for stroke alone, negative for stroke and fill (a typical value for outlined text would be 3.0)
        case let .stroke(color, value):
            rich.addAttribute(.strokeWidth, value: value, range: range)
            if let color = color {
                rich.addAttribute(.strokeColor, value: color, range: range)
            }
        /// [shadow] default nil: no shadow
        case let .shadow(value):
            rich.addAttribute(.shadow, value: value, range: range)
        /// [textEffect] default nil: no text effect
        case let .textEffect(value):
            rich.addAttribute(.textEffect, value: value, range: range)
        /// [attachment] default nil
        case let .attachment(value):
            rich.addAttribute(.attachment, value: value, range: range)
        /// [link] default nil
        case let .linked(value):
            rich.addAttribute(.link, value: value, range: range)
        /// [link] default nil
        case let .link(value):
            rich.addAttribute(.link, value: value, range: range)
        /// [baselineOffset] default 0 offset from baseline
        case let .baselineOffset(value):
            rich.addAttribute(.baselineOffset, value: value, range: range)
        #if os(macOS)
        case let .verticalGlyphForm(value):
            rich.addAttribute(.verticalGlyphForm, value: value, range: range)
        #endif
        }
        return Rich.rich(rich)
    }
    
    public static func +(lhs:Rich, rhs:Rich) -> Rich {
        let rich = NSMutableAttributedString()
        switch lhs {
        case let .rich(value): rich.append(value)
        case let .text(value): rich.append(NSAttributedString(string: value))
        }
        switch rhs {
        case let .rich(value): rich.append(value)
        case let .text(value): rich.append(NSAttributedString(string: value))
        }
        return Rich.rich(rich)
    }
    
    #if os(iOS)
    public static func +(lhs:Rich, rhs:UIImage) -> Rich {
        var rich:NSMutableAttributedString!
        switch lhs {
        case let .rich(value): rich = value
        case let .text(value): rich = NSMutableAttributedString(string: value)
        }

        let attachment = NSTextAttachment()
        attachment.image = rhs
        attachment.bounds = CGRect(origin: CGPoint(x: 0, y: -2), size: rhs.size)
        
        rich.append(NSAttributedString(attachment: attachment))
        return Rich.rich(rich)
    }
    
    public static func +(lhs:UIImage, rhs:Rich) -> Rich {
        var rich:NSMutableAttributedString!
        switch rhs {
        case let .rich(value): rich = value
        case let .text(value): rich = NSMutableAttributedString(string: value)
        }
        let attachment = NSTextAttachment()
        attachment.image = lhs
        attachment.bounds = CGRect(origin: CGPoint(x: 0, y: -2), size: lhs.size)
        rich.insert(NSAttributedString(attachment: attachment), at: 0)
        return Rich.rich(rich)
    }
    #elseif os(macOS)
    public static func +(lhs:Rich, rhs:NSImage) -> Rich {
        var rich:NSMutableAttributedString!
        switch lhs {
        case let .rich(value): rich = value
        case let .text(value): rich = NSMutableAttributedString(string: value)
        }
        
        let attachment = NSTextAttachment()
        if #available(OSX 10.11, *) {
            attachment.image = rhs
            attachment.bounds = CGRect(origin: CGPoint(x: 0, y: -2), size: rhs.size)
        } else {
            // Fallback on earlier versions
        }
        
        rich.append(NSAttributedString(attachment: attachment))
        return Rich.rich(rich)
    }
    
    public static func +(lhs:NSImage, rhs:Rich) -> Rich {
        var rich:NSMutableAttributedString!
        switch rhs {
        case let .rich(value): rich = value
        case let .text(value): rich = NSMutableAttributedString(string: value)
        }
        let attachment = NSTextAttachment()
        if #available(OSX 10.11, *) {
            attachment.image = lhs
            attachment.bounds = CGRect(origin: CGPoint(x: 0, y: -2), size: lhs.size)
        } else {
            // Fallback on earlier versions
        }
        rich.insert(NSAttributedString(attachment: attachment), at: 0)
        return Rich.rich(rich)
    }
    #endif
}


extension Array where Element == String {
    
    public subscript(_ style:RichStyle) -> [Rich] {
        return map { $0[style] }
    }
    
}

extension Array where Element == Rich {
    
    public subscript(_ style:RichStyle) -> [Rich] {
        return map { $0[style] }
    }
}

extension Array where Element == Optional<String> {
    
    public subscript(_ style:RichStyle) -> [Rich?] {
        return map { $0?[style] }
    }
    
}

extension Array where Element == Optional<Rich> {
    
    public subscript(_ style:RichStyle) -> [Rich?] {
        return map { $0?[style] }
    }
    
}


extension String {
    
    public subscript(_ style:RichStyle) -> Rich {
        return Rich.text(self)[style]
    }
    #if os(iOS)
    public static func +(lhs:String, rhs:UIImage) -> Rich {
        let attachment = NSTextAttachment()
        attachment.image = rhs
        attachment.bounds = CGRect(origin: CGPoint(x: 0, y: -2), size: rhs.size)
        let rich = NSMutableAttributedString(string: lhs)
        rich.append(NSAttributedString(attachment: attachment))
        return Rich.rich(rich)
    }
    
    public static func +(lhs:UIImage, rhs:String) -> NSAttributedString {
        let attachment = NSTextAttachment()
        attachment.image = lhs
        attachment.bounds = CGRect(origin: CGPoint(x: 0, y: -2), size: lhs.size)
        let rich = NSMutableAttributedString()
        rich.append(NSAttributedString(attachment: attachment))
        rich.append(NSAttributedString(string: rhs))
        return rich
    }
    
    #elseif os(macOS)
    public static func +(lhs:String, rhs:NSImage) -> Rich {
        let attachment = NSTextAttachment()
        if #available(OSX 10.11, *) {
            attachment.image = rhs
            attachment.bounds = CGRect(origin: CGPoint(x: 0, y: -2), size: rhs.size)
        } else {
            // Fallback on earlier versions
        }
        let rich = NSMutableAttributedString(string: lhs)
        rich.append(NSAttributedString(attachment: attachment))
        return Rich.rich(rich)
    }
    
    public static func +(lhs:NSImage, rhs:String) -> NSAttributedString {
        let attachment = NSTextAttachment()
        if #available(OSX 10.11, *) {
            attachment.image = lhs
            attachment.bounds = CGRect(origin: CGPoint(x: 0, y: -2), size: lhs.size)
        } else {
            // Fallback on earlier versions
        }
        let rich = NSMutableAttributedString()
        rich.append(NSAttributedString(attachment: attachment))
        rich.append(NSAttributedString(string: rhs))
        return rich
    }
    #endif
}

extension NSAttributedString {
    
    #if os(iOS)

    public static func +(lhs:NSAttributedString, rhs:UIImage) -> NSAttributedString {
        let attachment = NSTextAttachment()
        attachment.image = rhs
        attachment.bounds = CGRect(origin: CGPoint(x: 0, y: -2), size: rhs.size)
        let rich = NSMutableAttributedString(attributedString: lhs)
        rich.append(NSAttributedString(attachment: attachment))
        return rich
    }
    
    public static func +(lhs:UIImage, rhs:NSAttributedString) -> NSAttributedString {
        let attachment = NSTextAttachment()
        attachment.image = lhs
        attachment.bounds = CGRect(origin: CGPoint(x: 0, y: -2), size: lhs.size)
        let rich = NSMutableAttributedString()
        rich.append(NSAttributedString(attachment: attachment))
        rich.append(NSAttributedString(attributedString: rhs))
        return rich
    }
    #elseif os(macOS)
    public static func +(lhs:NSAttributedString, rhs:NSImage) -> NSAttributedString {
        let attachment = NSTextAttachment()
        if #available(OSX 10.11, *) {
            attachment.image = rhs
            attachment.bounds = CGRect(origin: CGPoint(x: 0, y: -2), size: rhs.size)
        } else {
            // Fallback on earlier versions
        }
        let rich = NSMutableAttributedString(attributedString: lhs)
        rich.append(NSAttributedString(attachment: attachment))
        return rich
    }
    
    public static func +(lhs:NSImage, rhs:NSAttributedString) -> NSAttributedString {
        let attachment = NSTextAttachment()
        if #available(OSX 10.11, *) {
            attachment.image = lhs
            attachment.bounds = CGRect(origin: CGPoint(x: 0, y: -2), size: lhs.size)
        } else {
            // Fallback on earlier versions
        }
        let rich = NSMutableAttributedString()
        rich.append(NSAttributedString(attachment: attachment))
        rich.append(NSAttributedString(attributedString: rhs))
        return rich
    }
    #endif

}
