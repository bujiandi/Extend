//
//  Animation.swift
//  CoreAnimations
//
//  Created by bujiandi on 2017/11/26.
//  Copyright © 2017 bujiandi. All rights reserved.
//

import QuartzCore

extension TransitionMaker {
    /// 创建 指定转场动画方向 并执行 duration 秒的动画
    
    @discardableResult
    public func from(_ direction:Value, duration:TimeInterval) -> AnimationTransition<Value> {
        return animate(from: direction, duration: duration)
    }
    
    // 如果想不起来from 用统一的value开头
    @discardableResult
    public func value(from direction:Value, duration:TimeInterval) -> AnimationTransition<Value> {
        return animate(from: direction, duration: duration)
    }
    
}

extension TransitionMaker where Value == TransitionNone {
    
    /// 创建 转场动画 并执行 duration 秒的动画
    @discardableResult
    public func value(duration:TimeInterval) -> AnimationTransition<Value> {
        return animate(from: .none, duration: duration)
    }
}

extension AnimationMaker {
    
    
    /// 创建 指定变化值的帧动画 并执行 duration 秒的弹性动画
    @discardableResult
    public func values(_ values:[Value], duration:TimeInterval) -> Animation<CAKeyframeAnimation, Value> {
        return animate(duration: duration, values: values)
    }
    
    /// 创建从 begin 到 over 并执行 duration 秒的弹性动画
    @available(OSX 10.11, *)
    @available(iOS 9.0, *)
    @discardableResult
    public func value(from begin:Value, to over:Value, damping:CGFloat, duration:TimeInterval) -> Animation<CASpringAnimation, Value> {
        return animate(duration: duration, damping:damping, from: begin, to: over)
    }

    /// 创建从 begin 到 over 并执行 duration 秒的动画
    @discardableResult
    public func value(from begin:Value, to over:Value, duration:TimeInterval) -> Animation<CABasicAnimation, Value> {
        return animate(duration: duration, from: begin, to: over)
    }
    
    /// 创建从 当前已动画到的值 更新到 over 并执行 duration 秒的动画
    @discardableResult
    public func value(to over:Value, duration:TimeInterval) -> Animation<CABasicAnimation, Value> {
        let begin = maker.layer.presentation()?.value(forKeyPath: keyPath) ?? maker.layer.value(forKeyPath: keyPath)
        return animate(duration: duration, from: begin, to: over)
    }
    
}


extension AnimationsMaker {
    
    /// 转场动画
    public var transition:UnknowMaker<Layer, TransitionStyle> {
        return UnknowMaker(maker: self, keyPath: "transition")
    }
    
    /// 对 cornerRadius 属性进行动画 默认 0
    public var cornerRadius:AnimationMaker<Layer, CGFloat> {
        return AnimationMaker<Layer, CGFloat>(maker:self, keyPath:"cornerRadius")
    }
    
    /// 对 bounds 属性进行动画.
    public var bounds:AnimationMaker<Layer, CGRect> {
        return AnimationMaker<Layer, CGRect>(maker:self, keyPath:"bounds")
    }
    
    /// 对 size 属性进行动画
    public var size:AnimationMaker<Layer, CGSize> {
        return AnimationMaker<Layer, CGSize>(maker:self, keyPath:"bounds.size")
    }
    
    /// 对 position 属性进行动画
    public var position:AnimationMaker<Layer, CGPoint> {
        return AnimationMaker<Layer, CGPoint>(maker:self, keyPath:"position")
    }
    
    /// 对 zPosition 属性进行动画 默认 0
    public var zPosition:AnimationMaker<Layer, CGFloat> {
        return AnimationMaker<Layer, CGFloat>(maker:self, keyPath:"zPosition")
    }
    
    /// 对 transform 属性进行动画
    public var transform:AnimationMaker<Layer, CATransform3D> {
        return AnimationMaker<Layer, CATransform3D>(maker:self, keyPath:"transform")
    }
    
//
//    /* Convenience methods for accessing the `transform' property as an
//     * affine transform. */
//
//    open func affineTransform() -> CGAffineTransform
//
//    open func setAffineTransform(_ m: CGAffineTransform)
    
//    /// 对 frame 属性进行动画
//    public var frame:AnimationMaker<Layer, CGRect> {
//        return AnimationMaker<Layer, CGRect>(maker:self, keyPath:"frame")
//    }
    
    /// 对 anchorPoint 属性进行动画 (0, 0) - (1, 1) default (0.5, 0.5)
    public var anchorPoint:AnimationMaker<Layer, CGPoint> {
        return AnimationMaker<Layer, CGPoint>(maker:self, keyPath:"anchorPoint")
    }
    
    /// 对 anchorPointZ 属性进行动画 默认 0
    public var anchorPointZ:AnimationMaker<Layer, CGFloat> {
        return AnimationMaker<Layer, CGFloat>(maker:self, keyPath:"anchorPointZ")
    }
    
    /// 对 doubleSided 属性进行动画 默认 true
    public var doubleSided:AnimationMaker<Layer, Bool> {
        return AnimationMaker<Layer, Bool>(maker:self, keyPath:"doubleSided")
    }
    
    /// 对 transform 属性进行动画
    public var sublayerTransform:AnimationMaker<Layer, CATransform3D> {
        return AnimationMaker<Layer, CATransform3D>(maker:self, keyPath:"sublayerTransform")
    }

    /// 对 masksToBounds 属性进行动画 默认 false
    public var masksToBounds:AnimationMaker<Layer, Bool> {
        return AnimationMaker<Layer, Bool>(maker:self, keyPath:"masksToBounds")
    }
    
    /* An object providing the contents of the layer, typically a CGImageRef,
     * but may be something else. (For example, NSImage objects are
     * supported on Mac OS X 10.6 and later.) Default value is nil.
     * Animatable. */
    /// 对 contents 属性进行动画 默认 nil
    public var contents:AnimationMaker<Layer, CGImage?> {
        return AnimationMaker<Layer, CGImage?>(maker:self, keyPath:"contents")
    }
    
    /// 对 contentsRect 属性进行动画 取值范围 [0 0 1 1].
    public var contentsRect:AnimationMaker<Layer, CGRect> {
        return AnimationMaker<Layer, CGRect>(maker:self, keyPath:"contentsRect")
    }
    
    /// 对 contentsScale 属性进行动画 默认 1
    @available(iOS 4.0, *)
    public var contentsScale:AnimationMaker<Layer, CGFloat> {
        return AnimationMaker<Layer, CGFloat>(maker:self, keyPath:"contentsScale")
    }
    
    /// 对 contentsRect 属性进行动画 取值范围 [0 0 1 1].
    public var contentsCenter:AnimationMaker<Layer, CGRect> {
        return AnimationMaker<Layer, CGRect>(maker:self, keyPath:"contentsCenter")
    }
    
    /// 对 minificationFilterBias 属性进行动画 默认 0
    public var minificationFilterBias:AnimationMaker<Layer, Float> {
        return AnimationMaker<Layer, Float>(maker:self, keyPath:"minificationFilterBias")
    }
    
    /// 对 backgroundColor 属性进行动画 默认 nil
    public var backgroundColor:AnimationMaker<Layer, CGColor?> {
        return AnimationMaker<Layer, CGColor?>(maker:self, keyPath:"backgroundColor")
    }
    
    /// 对 borderWidth 属性进行动画 默认 0
    public var borderWidth:AnimationMaker<Layer, CGFloat> {
        return AnimationMaker<Layer, CGFloat>(maker:self, keyPath:"borderWidth")
    }
    
    /// 对 borderColor 属性进行动画 默认 黑色
    public var borderColor:AnimationMaker<Layer, CGColor?> {
        return AnimationMaker<Layer, CGColor?>(maker:self, keyPath:"borderColor")
    }
    
    /// 对 opacity 属性进行动画 默认 1 取值范围 [0, 1]
    public var opacity:AnimationMaker<Layer, Float> {
        return AnimationMaker<Layer, Float>(maker:self, keyPath:"opacity")
    }
    
    /// 对 alpha (= opacity) 属性进行动画 默认 1 取值范围 [0, 1]
    public var alpha:AnimationMaker<Layer, CGFloat> {
        return AnimationMaker<Layer, CGFloat>(maker:self, keyPath:"opacity")
    }
    
    /// 对 shouldRasterize(格栅化) 属性进行动画 默认 false
    public var shouldRasterize:AnimationMaker<Layer, Bool> {
        return AnimationMaker<Layer, Bool>(maker:self, keyPath:"shouldRasterize")
    }
    
    /// 对 rasterizationScale (格栅化比例) 属性进行动画 默认 1 取值范围 [0, 1]
    public var rasterizationScale:AnimationMaker<Layer, CGFloat> {
        return AnimationMaker<Layer, CGFloat>(maker:self, keyPath:"rasterizationScale")
    }
    
    /// 对 shadowColor 属性进行动画 默认 黑色
    public var shadowColor:AnimationMaker<Layer, CGColor?> {
        return AnimationMaker<Layer, CGColor?>(maker:self, keyPath:"shadowColor")
    }
    
    /// 对 shadowOpacity 属性进行动画 默认 0 取值范围 [0, 1]
    public var shadowOpacity:AnimationMaker<Layer, Float> {
        return AnimationMaker<Layer, Float>(maker:self, keyPath:"shadowOpacity")
    }
    
    /// 对 shadowOffset 属性进行动画 默认 (0, -3)
    public var shadowOffset:AnimationMaker<Layer, CGSize> {
        return AnimationMaker<Layer, CGSize>(maker:self, keyPath:"shadowOffset")
    }
    
    /// 对 shadowRadius (阴影圆角) 属性进行动画 默认 3
    public var shadowRadius:AnimationMaker<Layer, CGFloat> {
        return AnimationMaker<Layer, CGFloat>(maker:self, keyPath:"shadowRadius")
    }
    
    /// 对 shadowPath 属性进行动画 默认 nil
    public var shadowPath:AnimationMaker<Layer, CGPath?> {
        return AnimationMaker<Layer, CGPath?>(maker:self, keyPath:"shadowPath")
    }
    
//    MARK: 不了解过滤器的用法和值 暂未添加
//
//    /* A filter object used to composite the layer with its (possibly
//     * filtered) background. Default value is nil, which implies source-
//     * over compositing. Animatable.
//     *
//     * Note that if the inputs of the filter are modified directly after
//     * the filter is attached to a layer, the behavior is undefined. The
//     * filter must either be reattached to the layer, or filter properties
//     * should be modified by calling -setValue:forKeyPath: on each layer
//     * that the filter is attached to. (This also applies to the `filters'
//     * and `backgroundFilters' properties.) */
//
//    open var compositingFilter: Any?
//
//
//    /* An array of filters that will be applied to the contents of the
//     * layer and its sublayers. Defaults to nil. Animatable. */
//
//    open var filters: [Any]?
//
//
//    /* An array of filters that are applied to the background of the layer.
//     * The root layer ignores this property. Animatable. */
//
//    open var backgroundFilters: [Any]?

}

extension AnimationsMaker where Layer : CAShapeLayer {
    
    /// 对 fillColor 属性进行动画 默认 黑色
    public var fillColor:AnimationMaker<Layer, CGColor?> {
        return AnimationMaker<Layer, CGColor?>(maker:self, keyPath:"fillColor")
    }
    
    /// 对 strokeColor 属性进行动画 默认 黑色
    public var strokeColor:AnimationMaker<Layer, CGColor?> {
        return AnimationMaker<Layer, CGColor?>(maker:self, keyPath:"strokeColor")
    }
    
    /// 对 strokeStart (线条起始) 属性进行动画 默认 0
    public var strokeStart:AnimationMaker<Layer, CGFloat> {
        return AnimationMaker<Layer, CGFloat>(maker:self, keyPath:"strokeStart")
    }
    
    /// 对 strokeEnd (线条结束) 属性进行动画 默认 1
    public var strokeEnd:AnimationMaker<Layer, CGFloat> {
        return AnimationMaker<Layer, CGFloat>(maker:self, keyPath:"strokeEnd")
    }
    
    /// 对 lineWidth (线条结束弧度) 属性进行动画 默认 1
    public var lineWidth:AnimationMaker<Layer, CGFloat> {
        return AnimationMaker<Layer, CGFloat>(maker:self, keyPath:"lineWidth")
    }

    /// 对 miterLimit 属性进行动画 默认 10
    public var miterLimit:AnimationMaker<Layer, CGFloat> {
        return AnimationMaker<Layer, CGFloat>(maker:self, keyPath:"miterLimit")
    }
    
    /// 对 lineDashPhase (线段样式) 属性进行动画 默认 0
    public var lineDashPhase:AnimationMaker<Layer, CGFloat> {
        return AnimationMaker<Layer, CGFloat>(maker:self, keyPath:"lineDashPhase")
    }
}


extension AnimationsMaker where Layer : CAGradientLayer {
    
    /* The array of CGColorRef objects defining the color of each gradient
     * stop. Defaults to nil. Animatable. */
    public var colors:AnimationMaker<Layer, [CGColor]> {
        return AnimationMaker<Layer, [CGColor]>(maker:self, keyPath:"colors")
    }
    
    /* An optional array of NSNumber objects defining the location of each
     * gradient stop as a value in the range [0,1]. The values must be
     * monotonically increasing. If a nil array is given, the stops are
     * assumed to spread uniformly across the [0,1] range. When rendered,
     * the colors are mapped to the output colorspace before being
     * interpolated. Defaults to nil. Animatable. */
    public var locations:AnimationMaker<Layer, [NSNumber]> {
        return AnimationMaker<Layer, [NSNumber]>(maker:self, keyPath:"locations")
    }
    
    /* The start and end points of the gradient when drawn into the layer's
     * coordinate space. The start point corresponds to the first gradient
     * stop, the end point to the last gradient stop. Both points are
     * defined in a unit coordinate space that is then mapped to the
     * layer's bounds rectangle when drawn. (I.e. [0,0] is the bottom-left
     * corner of the layer, [1,1] is the top-right corner.) The default values
     * are [.5,0] and [.5,1] respectively. Both are animatable. */
    public var startPoint:AnimationMaker<Layer, CGPoint> {
        return AnimationMaker<Layer, CGPoint>(maker:self, keyPath:"startPoint")
    }
    
    public var endPoint:AnimationMaker<Layer, CGPoint> {
        return AnimationMaker<Layer, CGPoint>(maker:self, keyPath:"endPoint")
    }

}

extension AnimationMaker where Value == CGSize {
    
    /// 对 size 的 width 属性进行动画
    public var width:AnimationMaker<Layer, CGFloat> {
        
        return AnimationMaker<Layer, CGFloat>(maker:maker, keyPath:"\(keyPath).width")
    }
    
    /// 对 size 的 height 属性进行动画
    public var height:AnimationMaker<Layer, CGFloat> {
        return AnimationMaker<Layer, CGFloat>(maker:maker, keyPath:"\(keyPath).height")
    }
}

extension AnimationMaker where Value == CGPoint {
    
    /// 创建按 path 轨迹移动 duration 秒的动画
    @discardableResult
    public func value(along path:CGPath, duration:TimeInterval) -> Animation<CAKeyframeAnimation, Value> {
        return animate(duration: duration, path: path)
    }
    
    /// 对 point 的 x 属性进行动画
    public var x:AnimationMaker<Layer, CGFloat> {
        return AnimationMaker<Layer, CGFloat>(maker:maker, keyPath:"\(keyPath).x")
    }
    
    /// 对 point 的 y 属性进行动画
    public var y:AnimationMaker<Layer, CGFloat> {
        return AnimationMaker<Layer, CGFloat>(maker:maker, keyPath:"\(keyPath).y")
    }
}

extension AnimationMaker where Value == CGRect {
    
    /// 对 rect 的 origin 属性进行动画
    public var origin:AnimationMaker<Layer, CGPoint> {
        return AnimationMaker<Layer, CGPoint>(maker:maker, keyPath:"\(keyPath).origin")
    }
    
    /// 对 rect.origin 的 x 属性进行动画
    public var x:AnimationMaker<Layer, CGFloat> {
        return AnimationMaker<Layer, CGFloat>(maker:maker, keyPath:"\(keyPath).origin.x")
    }
    
    /// 对 rect.origin 的 y 属性进行动画
    public var y:AnimationMaker<Layer, CGFloat> {
        return AnimationMaker<Layer, CGFloat>(maker:maker, keyPath:"\(keyPath).origin.y")
    }
    
    /// 对 rect 的 size 属性进行动画
    public var size:AnimationMaker<Layer, CGSize> {
        return AnimationMaker<Layer, CGSize>(maker:maker, keyPath:"\(keyPath).size")
    }
    
    /// 对 rect.size 的 width 属性进行动画
    public var width:AnimationMaker<Layer, CGFloat> {
        return AnimationMaker<Layer, CGFloat>(maker:maker, keyPath:"\(keyPath).size.width")
    }
    
    /// 对 rect.size 的 height 属性进行动画
    public var height:AnimationMaker<Layer, CGFloat> {
        return AnimationMaker<Layer, CGFloat>(maker:maker, keyPath:"\(keyPath).size.height")
    }
}

extension AnimationMaker where Value == CATransform3D {
    
    
    /// 对 transform 的 translation(位移) 属性进行动画
    public var translation:UnknowMaker<Layer, CGAffineTransform> {
        return UnknowMaker<Layer, CGAffineTransform>(maker:maker, keyPath:"\(keyPath).translation")
    }
    
    /// 对 transform 的 rotation(旋转) 属性进行动画
    public var rotation:UnknowMaker<Layer, CGAffineTransform> {
        return UnknowMaker<Layer, CGAffineTransform>(maker:maker, keyPath:"\(keyPath).rotation")
    }
    
}

extension UnknowMaker where Value == TransitionStyle {
    
    /// 推入效果 kCATransitionPush
    public var push:TransitionMaker<Layer, TransitionDirection> {
        return TransitionMaker<Layer, TransitionDirection>(maker: maker, style: .push)
    }
    /// 移入效果 kCATransitionMoveIn
    public var moveIn:TransitionMaker<Layer, TransitionDirection> {
        return TransitionMaker<Layer, TransitionDirection>(maker: maker, style: .moveIn)
    }
    /// 截开效果 kCATransitionReveal
    public var reveal:TransitionMaker<Layer, TransitionDirection> {
        return TransitionMaker<Layer, TransitionDirection>(maker: maker, style: .reveal)
    }
    /// 渐入渐出 kCATransitionFade
    public var fade:TransitionMaker<Layer, TransitionNone> {
        return TransitionMaker<Layer, TransitionNone>(maker: maker, style: .fade)
    }
    
    /// 方块
    public var cube:TransitionMaker<Layer, TransitionDirection> {
        return TransitionMaker<Layer, TransitionDirection>(maker: maker, style: .cube)
    }
    /// 三角
    public var suckEffect:TransitionMaker<Layer, TransitionDirection> {
        return TransitionMaker<Layer, TransitionDirection>(maker: maker, style: .suckEffect)
    }
    /// 水波抖动
    public var rippleEffect:TransitionMaker<Layer, TransitionNone> {
        return TransitionMaker<Layer, TransitionNone>(maker: maker, style: .rippleEffect)
    }
    /// 上翻页
    public var pageCurl:TransitionMaker<Layer, TransitionDirection> {
        return TransitionMaker<Layer, TransitionDirection>(maker: maker, style: .pageCurl)
    }
    // 下翻页
    public var pageUnCurl:TransitionMaker<Layer, TransitionDirection> {
        return TransitionMaker<Layer, TransitionDirection>(maker: maker, style: .pageUnCurl)
    }
    // 上下翻转
    public var oglFlip:TransitionMaker<Layer, TransitionDirection> {
        return TransitionMaker<Layer, TransitionDirection>(maker: maker, style: .oglFlip)
    }
    // 镜头快门开
    public var cameraIrisHollowOpen:TransitionMaker<Layer, TransitionNone> {
        return TransitionMaker<Layer, TransitionNone>(maker: maker, style: .cameraIrisHollowOpen)
    }
    // 镜头快门开
    public var cameraIrisHollowClose:TransitionMaker<Layer, TransitionNone> {
        return TransitionMaker<Layer, TransitionNone>(maker: maker, style: .cameraIrisHollowClose)
    }
    
    // MARK: 以下API效果请慎用
    // 新版面在屏幕下方中间位置被释放出来覆盖旧版面.
    public var spewEffect:TransitionMaker<Layer, TransitionDirection> {
        return TransitionMaker<Layer, TransitionDirection>(maker: maker, style: .spewEffect)
    }
    // 旧版面在屏幕左下方或右下方被吸走, 显示下面的新版面
    public var genieEffect:TransitionMaker<Layer, TransitionHorizontal> {
        return TransitionMaker<Layer, TransitionHorizontal>(maker: maker, style: .genieEffect)
    }
    // 新版面在屏幕左下方或右下方被释放出来覆盖旧版面.
    public var unGenieEffect:TransitionMaker<Layer, TransitionHorizontal> {
        return TransitionMaker<Layer, TransitionHorizontal>(maker: maker, style: .unGenieEffect)
    }
    // 版面以水平方向像龙卷风式转出来.
    public var twist:TransitionMaker<Layer, TransitionHorizontal> {
        return TransitionMaker<Layer, TransitionHorizontal>(maker: maker, style: .twist)
    }
    // 版面垂直附有弹性的转出来.
    public var tubey:TransitionMaker<Layer, TransitionVertical> {
        return TransitionMaker<Layer, TransitionVertical>(maker: maker, style: .tubey)
    }
    // 旧版面360度旋转并淡出, 显示出新版面.
    public var swirl:TransitionMaker<Layer, TransitionDirection> {
        return TransitionMaker<Layer, TransitionDirection>(maker: maker, style: .swirl)
    }
    // 旧版面淡出并显示新版面.
    public var charminUltra:TransitionMaker<Layer, TransitionDirection> {
        return TransitionMaker<Layer, TransitionDirection>(maker: maker, style: .charminUltra)
    }
    // 新版面由小放大走到前面, 旧版面放大由前面消失.
    public var zoomyIn:TransitionMaker<Layer, TransitionDirection> {
        return TransitionMaker<Layer, TransitionDirection>(maker: maker, style: .zoomyIn)
    }
    // 新版面屏幕外面缩放出现, 旧版面缩小消失.
    public var zoomyOut:TransitionMaker<Layer, TransitionDirection> {
        return TransitionMaker<Layer, TransitionDirection>(maker: maker, style: .zoomyOut)
    }
    // 像按 ”home” 按钮的效果.
    public var oglApplicationSuspend:TransitionMaker<Layer, TransitionDirection> {
        return TransitionMaker<Layer, TransitionDirection>(maker: maker, style: .oglApplicationSuspend)
    }

}

extension UnknowMaker where Value == CGAffineTransform {
    /// 对 transform 的 x 属性进行动画
    public var x:AnimationMaker<Layer, CGFloat> {
        return AnimationMaker<Layer, CGFloat>(maker:maker, keyPath:"\(keyPath).x")
    }
    
    /// 对 transform 的 y 属性进行动画
    public var y:AnimationMaker<Layer, CGFloat> {
        return AnimationMaker<Layer, CGFloat>(maker:maker, keyPath:"\(keyPath).y")
    }
    
    /// 对 transform 的 z 属性进行动画
    public var z:AnimationMaker<Layer, CGFloat> {
        return AnimationMaker<Layer, CGFloat>(maker:maker, keyPath:"\(keyPath).z")
    }
}

extension CAMediaTiming where Self : CALayer {
    
    /// CALayer 创建动画构造器
    public func animate(forKey key:String? = nil, by makerFunc:(AnimationsMaker<Self>) -> Void) {
        
        // 移除同 key 的未执行完的动画
        if let idefiniter = key {
            removeAnimation(forKey: idefiniter)
        }
        // 创建动画构造器 并 开始构造动画
        let maker = AnimationsMaker<Self>(layer: self)
        makerFunc(maker)
        
        // 如果只有一个属性做了动画, 则忽略动画组
        if maker.animations.count == 1 {
            return add(maker.animations.first!, forKey: key)
        }
        
        // 创建动画组
        let group = maker.caAnimation
        group.animations = maker.animations
        // 如果未设定动画时间, 则采用所有动画中最长的时间做动画时间
        group.duration = maker._duration ?? maker.animations.reduce(0) { max($0, $1.duration + $1.beginTime) }
    
        // 开始执行动画
        add(group, forKey: key)
    }
}

/// 动画过渡 曲线
extension CAMediaTimingFunction {
    public static let easeInOut:CAMediaTimingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
    public static let easeOut:CAMediaTimingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
    public static let easeIn:CAMediaTimingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)
    public static let linear:CAMediaTimingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
    public static let `default`:CAMediaTimingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.default)
}



/// 动画停止执行回调代理
open class CAAnimationStopDelegate :NSObject, CAAnimationDelegate {
    
    let onStop: @convention(block) (Bool) -> Void
    init(_ onStop:@escaping @convention(block) (Bool) -> Void) {
        self.onStop = onStop
    }
    
    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        onStop(flag)
    }
}

extension CALayer {
    public var alpha:Float {
        set { opacity = newValue }
        get { return opacity }
    }
}
