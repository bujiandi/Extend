public protocol Viewer {
    
}

extension Viewer {
    
    public func display<A:Adapter>(_ binder:A, by data:A.Data) where Self == A.View {
        binder.update(self, by: data)
    }
    
}
