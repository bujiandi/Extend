//
//  Slice.swift
//  Basic
//
//  Created by bujiandi on 2018/9/28.
//

//import Foundation


extension Array {
    
    public init(reserveCapacity: Int) {
        self = Array<Element>()
        self.reserveCapacity(reserveCapacity)
    }
    
    var slice: ArraySlice<Element> {
        return self[startIndex ..< endIndex]
    }
}

extension Array where Element == UInt8 {
    
    init(hex: String) {
        self.init(reserveCapacity: hex.unicodeScalars.lazy.underestimatedCount)
        var buffer: UInt8?
        var skip = hex.hasPrefix("0x") ? 2 : 0
        for char in hex.unicodeScalars.lazy {
            guard skip == 0 else {
                skip -= 1
                continue
            }
            guard char.value >= 48 && char.value <= 102 else {
                removeAll()
                return
            }
            let v: UInt8
            let c: UInt8 = UInt8(char.value)
            switch c {
            case let c where c <= 57:
                v = c - 48
            case let c where c >= 65 && c <= 70:
                v = c - 55
            case let c where c >= 97:
                v = c - 87
            default:
                removeAll()
                return
            }
            if let b = buffer {
                append(b << 4 | v)
                buffer = nil
            } else {
                buffer = v
            }
        }
        if let b = buffer {
            append(b)
        }
    }
    
    func toHexString() -> String {
        return `lazy`.reduce("") {
            var s = String($1, radix: 16)
            if s.count == 1 {
                s = "0" + s
            }
            return $0 + s
        }
    }
    
    var hexString: String {
        return toHexString()
    }
}

extension Array where Element == UInt8 {
//    /// split in chunks with given chunk size
//    @available(*, deprecated: 0.8.0, message: "")
//    public func chunks(size chunksize: Int) -> Array<Array<Element>> {
//        var words = Array<Array<Element>>()
//        words.reserveCapacity(count / chunksize)
//        for idx in stride(from: chunksize, through: count, by: chunksize) {
//            words.append(Array(self[idx - chunksize ..< idx])) // slow for large table
//        }
//        let remainder = suffix(count % chunksize)
//        if !remainder.isEmpty {
//            words.append(Array(remainder))
//        }
//        return words
//    }
    
//    public func md5() -> [Element] {
//        return Digest.md5(self)
//    }
//    
//    public func sha1() -> [Element] {
//        return Digest.sha1(self)
//    }
//    
//    public func sha224() -> [Element] {
//        return Digest.sha224(self)
//    }
//    
//    public func sha256() -> [Element] {
//        return Digest.sha256(self)
//    }
//    
//    public func sha384() -> [Element] {
//        return Digest.sha384(self)
//    }
//    
//    public func sha512() -> [Element] {
//        return Digest.sha512(self)
//    }
//    
//    public func sha2(_ variant: SHA2.Variant) -> [Element] {
//        return Digest.sha2(self, variant: variant)
//    }
//    
//    public func sha3(_ variant: SHA3.Variant) -> [Element] {
//        return Digest.sha3(self, variant: variant)
//    }
//    
//    public func crc32(seed: UInt32? = nil, reflect: Bool = true) -> UInt32 {
//        return Checksum.crc32(self, seed: seed, reflect: reflect)
//    }
//    
//    public func crc32c(seed: UInt32? = nil, reflect: Bool = true) -> UInt32 {
//        return Checksum.crc32c(self, seed: seed, reflect: reflect)
//    }
//    
//    public func crc16(seed: UInt16? = nil) -> UInt16 {
//        return Checksum.crc16(self, seed: seed)
//    }
//    
//    public func encrypt(cipher: Cipher) throws -> [Element] {
//        return try cipher.encrypt(slice)
//    }
//    
//    public func decrypt(cipher: Cipher) throws -> [Element] {
//        return try cipher.decrypt(slice)
//    }
//    
//    public func authenticate<A: Authenticator>(with authenticator: A) throws -> [Element] {
//        return try authenticator.authenticate(self)
//    }
}



struct BatchedCollectionIndex<Base: Collection> {
    let range: Range<Base.Index>
}

extension BatchedCollectionIndex: Comparable {
    static func == <Base>(lhs: BatchedCollectionIndex<Base>, rhs: BatchedCollectionIndex<Base>) -> Bool {
        return lhs.range.lowerBound == rhs.range.lowerBound
    }
    
    static func < <Base>(lhs: BatchedCollectionIndex<Base>, rhs: BatchedCollectionIndex<Base>) -> Bool {
        return lhs.range.lowerBound < rhs.range.lowerBound
    }
}

protocol BatchedCollectionType: Collection {
    associatedtype Base: Collection
}

struct BatchedCollection<Base: Collection>: Collection {
    let base: Base
    let size: Int
    typealias Index = BatchedCollectionIndex<Base>
    private func nextBreak(after idx: Base.Index) -> Base.Index {
        return base.index(idx, offsetBy: size, limitedBy: base.endIndex) ?? base.endIndex
    }
    
    var startIndex: Index {
        return Index(range: base.startIndex..<nextBreak(after: base.startIndex))
    }
    
    var endIndex: Index {
        return Index(range: base.endIndex..<base.endIndex)
    }
    
    func index(after idx: Index) -> Index {
        return Index(range: idx.range.upperBound..<nextBreak(after: idx.range.upperBound))
    }
    
    subscript(idx: Index) -> Base.SubSequence {
        return base[idx.range]
    }
}

extension Collection {
    func batched(by size: Int) -> BatchedCollection<Self> {
        return BatchedCollection(base: self, size: size)
    }
}
