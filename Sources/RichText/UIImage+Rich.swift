//
//  UIImage+Rich.swift
//  RichText
//
//  Created by 小歪 on 2018/6/19.
//

#if os(OSX)
import Cocoa
#elseif os(iOS)
import UIKit

extension UIImage {
    
    public subscript(bounds:CGRect) -> Rich {
        let attachment = NSTextAttachment()
        attachment.image = self
        attachment.bounds = bounds
        let rich = NSMutableAttributedString()
        rich.append(NSAttributedString(attachment: attachment))
        return Rich.rich(rich)
    }
    
    public typealias YOffset = CGFloat
    public subscript(y:YOffset) -> Rich {
        return self[CGRect(origin: CGPoint(x: 0, y: y), size: size)]
    }
    
}

#endif



