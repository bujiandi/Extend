//
//  NSObject+Tag.swift
//  Tools
//
//  Created by 慧趣小歪 on 17/4/18.
//
//

#if canImport(Foundation)

import Foundation
import ObjectiveC.runtime
//import Foundation.NSObjCRuntime

private var KEY_OBJ_UNOWNED_TAG:String = "obj.unowned.tag"
private var KEY_OBJ_STRONG_TAG:String = "obj.strong.tag"
private var KEY_OBJ_WEAK_TAG:String = "obj.weak.tag"
private var KEY_OBJ_WEAK_ITEM:String = "obj.weak.item"

private class WeakObject {
    weak var obj:NSObject?
    
    deinit {
        guard let item = obj else { return }
        objc_setAssociatedObject(item, &KEY_OBJ_WEAK_TAG, nil, .OBJC_ASSOCIATION_ASSIGN)
    }
}

extension NSObject {
    
    public var weakTag:Any? {
        get {
            return objc_getAssociatedObject(self, &KEY_OBJ_WEAK_TAG)
        }
        set {
            objc_setAssociatedObject(self, &KEY_OBJ_WEAK_TAG, newValue, .OBJC_ASSOCIATION_ASSIGN)
            // 定义一个跟随对象绑定到 目标, 当目标释放时 , 利用绑定对象的析构函数将属性设为nil
            if let v = newValue {
                let weakObj:WeakObject = objc_getAssociatedObject(v, &KEY_OBJ_WEAK_ITEM) as? WeakObject ?? WeakObject()
                weakObj.obj = self
                objc_setAssociatedObject(v, &KEY_OBJ_WEAK_ITEM, weakObj, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
    
    public var unownedTag:Any? {
        get {
            return objc_getAssociatedObject(self, &KEY_OBJ_UNOWNED_TAG)
        }
        set {
            objc_setAssociatedObject(self, &KEY_OBJ_UNOWNED_TAG, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
    
    public var strongTag:Any? {
        get {
            return objc_getAssociatedObject(self, &KEY_OBJ_STRONG_TAG)
        }
        set {
            objc_setAssociatedObject(self, &KEY_OBJ_STRONG_TAG, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    public var classNameForCoder:String {
        return NSStringFromClass(classForCoder)
    }
    
}


public protocol PropertyCreatable {
    
    func createIfNeed<Item>(_ item: inout Item?, `init` initFunc:(Item)->Void) -> Item where Item : NSObject
    
}

extension PropertyCreatable {
    
    public func createIfNeed<Item>(_ item: inout Item?, `init` initFunc:(Item)->Void) -> Item where Item : NSObject {
        guard let value = item else {
            let value = Item()
            initFunc(value)
            item = value
            return value
        }
        return value
    }
}

extension NSObject : PropertyCreatable {}
#endif
