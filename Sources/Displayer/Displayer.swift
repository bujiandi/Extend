public protocol Displayer {
    
    associatedtype View
    associatedtype Data
    
    func update(_ view:View, by data:Data)
}
