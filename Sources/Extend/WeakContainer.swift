//
//  WeakContainer.swift
//  Tools
//
//  Created by 慧趣小歪 on 2017/8/8.
//
//

#if canImport(ObjectiveC)
import ObjectiveC

private var kAutoReleaseContainer = "auto.release.container"
extension NSObjectProtocol {
    
    public func deinitAutoRelease<T:Releasable>(_ obj:T?) {
        if let item = obj {
            objc_setAssociatedObject(self, &kAutoReleaseContainer, WeakAutoRelease<T>(item), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        } else {
            objc_setAssociatedObject(self, &kAutoReleaseContainer, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
}

#endif

public protocol ContainerType:class {
    
    associatedtype Element
    
    var obj:Element? { get set }
    
    init(_ obj:Element)
}

open class StrongContainer<T:AnyObject> : ContainerType {
    
    public typealias Element = T
    
    open var obj: Element?
    
    public required init(_ obj: Element) {
        self.obj = obj
    }

}

open class WeakContainer<T:AnyObject> : ContainerType {
    
    public typealias Element = T
    
    weak open var obj:Element?
    
    public required init(_ obj:Element) {
        self.obj = obj
    }
    
}

public protocol Releasable : class {
    func destory()
}

open class WeakAutoRelease<T:Releasable> : ContainerType {
    
    public typealias Element = T
    
    weak open var obj:Element?
    
    public required init(_ obj:Element) {
        self.obj = obj
    }

    deinit { obj?.destory() }
}

