//
//  Updatable.swift
//  Basic
//
//  Created by 李招利 on 2018/9/28.
//

//import Foundation


/// A type that supports incremental updates. For example Digest or Cipher may be updatable
/// and calculate result incerementally.

protocol Updatable {
    
    /// Update given bytes in chunks.
    ///
    /// - parameter bytes: Bytes to process.
    /// - parameter isLast: Indicate if given chunk is the last one. No more updates after this call.
    /// - returns: Processed partial result data or empty array.
    mutating func update(withBytes bytes: ArraySlice<UInt8>, isLast: Bool) throws -> Array<UInt8>
    
    /// Update given bytes in chunks.
    ///
    /// - Parameters:
    ///   - bytes: Bytes to process.
    ///   - isLast: Indicate if given chunk is the last one. No more updates after this call.
    ///   - output: Resulting bytes callback.
    /// - Returns: Processed partial result data or empty array.
    mutating func update(withBytes bytes: ArraySlice<UInt8>, isLast: Bool, output: (_ bytes: Array<UInt8>) -> Void) throws
}

extension Updatable {
    
    mutating func update(withBytes bytes: ArraySlice<UInt8>, isLast: Bool = false, output: (_ bytes: Array<UInt8>) -> Void) throws {
        let processed = try update(withBytes: bytes, isLast: isLast)
        if !processed.isEmpty {
            output(processed)
        }
    }
    
    mutating func update(withBytes bytes: ArraySlice<UInt8>, isLast: Bool = false) throws -> Array<UInt8> {
        return try update(withBytes: bytes, isLast: isLast)
    }
    
    mutating func update(withBytes bytes: Array<UInt8>, isLast: Bool = false) throws -> Array<UInt8> {
        return try update(withBytes: bytes.slice, isLast: isLast)
    }
    
    mutating func update(withBytes bytes: Array<UInt8>, isLast: Bool = false, output: (_ bytes: Array<UInt8>) -> Void) throws {
        return try update(withBytes: bytes.slice, isLast: isLast, output: output)
    }
    
    /// Finish updates. This may apply padding.
    /// - parameter bytes: Bytes to process
    /// - returns: Processed data.
    mutating func finish(withBytes bytes: ArraySlice<UInt8>) throws -> Array<UInt8> {
        return try update(withBytes: bytes, isLast: true)
    }
    
    mutating func finish(withBytes bytes: Array<UInt8>) throws -> Array<UInt8> {
        return try finish(withBytes: bytes.slice)
    }
    
    
    /// Finish updates. May add padding.
    ///
    /// - Returns: Processed data
    /// - Throws: Error
    mutating func finish() throws -> Array<UInt8> {
        return try update(withBytes: [], isLast: true)
    }
    
    /// Finish updates. This may apply padding.
    /// - parameter bytes: Bytes to process
    /// - parameter output: Resulting data
    /// - returns: Processed data.
    mutating func finish(withBytes bytes: ArraySlice<UInt8>, output: (_ bytes: Array<UInt8>) -> Void) throws {
        let processed = try update(withBytes: bytes, isLast: true)
        if !processed.isEmpty {
            output(processed)
        }
    }
    
    mutating func finish(withBytes bytes: Array<UInt8>, output: (_ bytes: Array<UInt8>) -> Void) throws {
        return try finish(withBytes: bytes.slice, output: output)
    }
    
    /// Finish updates. May add padding.
    ///
    /// - Parameter output: Processed data
    /// - Throws: Error
    mutating func finish(output: (Array<UInt8>) -> Void) throws {
        try finish(withBytes: [], output: output)
    }
}
