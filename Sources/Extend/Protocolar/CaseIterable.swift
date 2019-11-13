//
//  CaseIterable.swift
//  Protocolar
//
//  Created by bujiandi on 2019/4/18.
//

#if swift(<4.2)
public protocol CaseIterable {
    static func enumerate() -> AnyIterator<(Int, Self)>
}
#endif

extension CaseIterable where Self : Hashable {
    
    private static func enumerateEnum<T: Hashable>(_: T.Type) -> AnyIterator<(Int, T)> {
        var i = 0
        return AnyIterator {
            let next = withUnsafePointer(to: &i) { p in
                p.withMemoryRebound(to: T.self, capacity: 1) { $0.pointee }
            }
            defer { i += 1 }
            return next.hashValue == i ? (i, next) : nil
        }
    }
    
    public static func enumerate() -> AnyIterator<(Int, Self)> {
        return enumerateEnum(Self.self)
    }
    
    #if swift(<4.2)
    public static var allCases:[Self] {
        var list:[Self] = []
        for item in enumerateEnum(Self.self) {
            list.append(item.1)
        }
        return list
    }
    #endif
}
