public protocol Viewer {
    
}

extension Viewer {
    
    public func display<D:Displayer>(_ binder:D, by data:D.Data) where Self == D.View {
        binder.update(self, by: data)
    }
    
}
