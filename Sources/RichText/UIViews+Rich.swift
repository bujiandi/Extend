//
//  UIViews+Rich.swift
//  Toast
//
//  Created by 慧趣小歪 on 2018/6/11.
//  Copyright © 2018年 yFenFen. All rights reserved.
//

#if os(OSX)
import Cocoa
#elseif os(iOS)
import UIKit
#endif

public protocol Richable : class {
    var text: String? { get set }
    var attributedText:NSAttributedString? { get set }
}

extension Richable {
    public var rich:Rich? {
        set {
            if let value = newValue {
                switch value {
                case let .text(v):
                    if self.attributedText != nil { self.attributedText = nil }
                    self.text = v
                case let .rich(v):
                    self.attributedText = v
                }
            } else {
                self.text = nil
            }
        }
        get {
            if let v = attributedText {
                let value = NSMutableAttributedString(attributedString: v)
                return Rich.rich(value)
            } else if let value = text {
                return Rich.text(value)
            }
            return nil
        }
    }

}


#if os(OSX)

extension NSTextField : Richable {
    
    public var text: String? {
        get { return stringValue }
        set { stringValue = newValue ?? "" }
    }
    
    public var attributedText: NSAttributedString? {
        get { return attributedStringValue }
        set { attributedStringValue = newValue ?? NSAttributedString() }
    }
}

#elseif os(iOS)

extension UILabel : Richable {}

extension UIButton {
    
    open func setRichTitle(_ rich:Rich?, for versionState:UIControl.State) {
        guard let value = rich else {
            if attributedTitle(for: versionState) != nil {
                setAttributedTitle(nil, for: versionState)
            }
            return setTitle(nil, for: versionState)
        }
        switch value {
        case let .text(text):
            if attributedTitle(for: versionState) != nil {
                setAttributedTitle(nil, for: versionState)
            }
            setTitle(text, for: versionState)
        case let .rich(attr): setAttributedTitle(attr, for: versionState)
        }
    }
    
    open func richTitle(for versionState: UIControl.State) -> Rich? {
        if let v = attributedTitle(for: versionState) {
            let value = NSMutableAttributedString(attributedString: v)
            return Rich.rich(value)
        } else if let value = title(for: versionState) {
            return Rich.text(value)
        }
        return nil
    }
    
}

#endif
