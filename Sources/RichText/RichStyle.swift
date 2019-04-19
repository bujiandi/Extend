//
//  RichStyle.swift
//  RichText
//
//  Created by 慧趣小歪 on 2018/6/12.
//

#if os(OSX)
import Cocoa
#elseif os(iOS)
import UIKit
#endif

public enum RichStyle {
    /// [paragraphStyle] default NSParagraphStyle defaultParagraphStyle
    case paragraph((NSMutableParagraphStyle)->Void)
    #if os(OSX)
    /// [font] default Helvetica(Neue) 12
    case font(NSFont)
    /// [foregroundColor] default blackColor
    case color(NSColor)
    /// [backgroundColor] default nil: no background
    case background(NSColor)
    /// [underlineColor], [underlineStyle]
    case underline(NSColor?, NSUnderlineStyle)
    /// [strokeColor] default nil: same as foreground color, [strokeWidth] default 0: no stroke; positive for stroke alone, negative for stroke and fill (a typical value for outlined text would be 3.0), minus strokeWidth is fill foregroundColor
    case stroke(NSColor?, CGFloat)
    /// [strikethroughColor] default nil: same as foreground color, [strikethroughStyle] default 0: no strikethrough
    case strikethrough(NSColor?, NSUnderlineStyle)
    /// [verticalGlyphForm] 0 means horizontal text.  1 indicates vertical text.  If not specified, it could follow higher-level vertical orientation settings.  Currently on iOS, it's always horizontal.  The behavior for any other value is undefined
    case verticalGlyphForm(Int)
    #elseif os(iOS)
    /// [font] default Helvetica(Neue) 12
    case font(UIFont)
    /// [foregroundColor] default blackColor
    case color(UIColor)
    /// [backgroundColor] default nil: no background
    case background(UIColor)
    /// [underlineColor], [underlineStyle]
    case underline(UIColor?, NSUnderlineStyle)
    /// [strokeColor] default nil: same as foreground color, [strokeWidth] default 0: no stroke; positive for stroke alone, negative for stroke and fill (a typical value for outlined text would be 3.0), minus strokeWidth is fill foregroundColor
    case stroke(UIColor?, CGFloat)
    /// [strikethroughColor] default nil: same as foreground color, [strikethroughStyle] default 0: no strikethrough
    case strikethrough(UIColor?, NSUnderlineStyle)
    #endif
    /// [ligature] default 1, 0: no ligatures
    case ligature(Int)
    /// [kern] default 0 means kerning is disabled.
    case kern(CGFloat)
    /// [expansion] default 0: no expansio, width for text
    case expansion(CGFloat)
    /// [obliqueness] default 0: no skew. skew to be applied to glyphs.
    case obliqueness(CGFloat)
    /// [shadow] default nil: no shadow
    case shadow(NSShadow)
    /// [textEffect] default nil: no text effect
    case textEffect(String)
    /// [attachment] default nil
    case attachment(NSTextAttachment)
    /// [link] default nil
    case linked(String)
    /// [link] default nil
    case link(URL)
    /// [baselineOffset] default 0 offset from baseline
    case baselineOffset(CGFloat)
//    case writingDirection()
/*
     
 @available(iOS 7.0, *)
 public static let writingDirection: NSAttributedStringKey // NSArray of NSNumbers representing the nested levels of writing direction overrides as defined by Unicode LRE, RLE, LRO, and RLO characters.  The control characters can be obtained by masking NSWritingDirection and NSWritingDirectionFormatType values.  LRE: NSWritingDirectionLeftToRight|NSWritingDirectionEmbedding, RLE: NSWritingDirectionRightToLeft|NSWritingDirectionEmbedding, LRO: NSWritingDirectionLeftToRight|NSWritingDirectionOverride, RLO: NSWritingDirectionRightToLeft|NSWritingDirectionOverride,
 */
}
