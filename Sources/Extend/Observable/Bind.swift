//
//  File.swift
//  
//
//  Created by 慧趣小歪 on 2019/11/13.
//

import Foundation

#if swift(>=5.1)

@propertyWrapper
@dynamicMemberLookup
public struct Bind<T:AnyObject> {
    
    public var wrappedValue: T
    
    public init(wrappedValue: T) {
        self.wrappedValue = wrappedValue
    }
    
    public subscript<Subject>(dynamicMember keyPath: WritableKeyPath<T, Subject>) -> Observable<Subject> {
        nonmutating set {
            let this = wrappedValue
            let updateBlock:(Observed<T, Subject>) -> Void = { [weak this] changed in
                this?[keyPath: keyPath] = changed.new
            }
            newValue.notify(this, didChange: updateBlock)
            updateBlock(Observed<T, Subject>(setValue:newValue.wrappedValue, notify: this))
        }
        get {
            let this = wrappedValue
            let value = wrappedValue[keyPath: keyPath]
            let observerValue = Observable<Subject>(wrappedValue: value)

            observerValue.notify(this) { [weak this] changed in
                this?[keyPath: keyPath] = changed.new
            }
            return observerValue
        }
    }
    
    
    public subscript<Subject:Defaultable>(dynamicMember keyPath: WritableKeyPath<T, Subject?>) -> Observable<Subject> {
        nonmutating set {
            let this = wrappedValue
            let updateBlock:(Observed<T, Subject>) -> Void = { [weak this] changed in
                this?[keyPath: keyPath] = changed.new
            }
            newValue.notify(this, didChange: updateBlock)
            updateBlock(Observed<T, Subject>(setValue:newValue.wrappedValue, notify: this))
        }
        get {
            let this = wrappedValue
            let value = wrappedValue[keyPath: keyPath] ?? Subject.defaultValue
            let observerValue = Observable<Subject>(wrappedValue: value)

            observerValue.notify(this) { [weak this] changed in
                this?[keyPath: keyPath] = changed.new
            }
            return observerValue
        }
    }
    
    public subscript(dynamicMember keyPath: WritableKeyPath<T, String?>) -> ObservableString {
        nonmutating set {
            let this = wrappedValue
            let updateBlock:() -> Void = { [weak this] in
                this?[keyPath: keyPath] = newValue.description
            }
            for comment in newValue.comments {
                if case .observable(let delegate) = comment {
                    delegate.notify(this, updateBlock)
                }
            }
            updateBlock()
        }
        get {
            let this = wrappedValue
            let value = wrappedValue[keyPath: keyPath] ?? ""
            let observerValue = Observable<String>(wrappedValue: value)

            observerValue.notify(this) { [weak this] changed in
                this?[keyPath: keyPath] = changed.new
            }
            return "\(observerValue)"
        }
    }
}


extension NSObjectProtocol {
    public var bind:Bind<Self> { return Bind<Self>(wrappedValue: self) }
}
#endif
