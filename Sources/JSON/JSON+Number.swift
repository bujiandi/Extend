//
//  JSON+Number.swift
//  TestJSON
//
//  Created by 李招利 on 2019/1/7.
//  Copyright © 2019 jwl. All rights reserved.
//

import Foundation

extension JSON {
    
    public struct Number: RawRepresentable {
        
        public typealias RawValue = String
        
        public let rawValue: String
        public let isNegative: Bool
        public let isInteger: Bool
        public let digitCount: Int
        public let exponent: Int
        
        public init(_ value:String, negative:Bool, integer:Bool, digit:Int, exponent exp:Int) {
            if integer, let index = value.firstIndex(of: ".") {
                rawValue = String(value[..<index])
            } else {
                rawValue = value
            }
            isNegative = negative
            isInteger = integer
            exponent = exp
            digitCount = digit
        }
        
        public init?(rawValue value: String) {
            guard let value = try? value.parseJSONNumber() else {
                return nil
            }
//            guard let data = value.data(using: .utf8),
//                let json = try? data.parseJSON(options: [.allowFragments]),
//                case .number(let value) = json else { return nil }
            
            self = value
        }
        
        public var stringValue:String { return rawValue }
    }
    
}

extension Decimal {
    
    public var doubleValue: Double {
        if _length == 0 {
            if _isNegative == 1 {
                return Double.nan
            } else {
                return 0
            }
        }
        
        var d = 0.0
        for idx in stride(from: min(_length, 8), to: 0, by: -1) {
            d = d * 65536 + Double(self[idx - 1])
        }
        
        if _exponent < 0 {
            for _ in _exponent..<0 {
                d /= 10.0
            }
        } else {
            for _ in 0..<_exponent {
                d *= 10.0
            }
        }
        return _isNegative != 0 ? -d : d
    }
    
    fileprivate subscript(index:UInt32) -> UInt16 {
        get {
            switch index {
            case 0: return _mantissa.0
            case 1: return _mantissa.1
            case 2: return _mantissa.2
            case 3: return _mantissa.3
            case 4: return _mantissa.4
            case 5: return _mantissa.5
            case 6: return _mantissa.6
            case 7: return _mantissa.7
            default: fatalError("Invalid index \(index) for _mantissa")
            }
        }
        set {
            switch index {
            case 0: _mantissa.0 = newValue
            case 1: _mantissa.1 = newValue
            case 2: _mantissa.2 = newValue
            case 3: _mantissa.3 = newValue
            case 4: _mantissa.4 = newValue
            case 5: _mantissa.5 = newValue
            case 6: _mantissa.6 = newValue
            case 7: _mantissa.7 = newValue
            default: fatalError("Invalid index \(index) for _mantissa")
            }
        }
    }
}

extension JSON.Number {
    
    public init(_ value: NSNumber) {
        self.init(stringLiteral: value.stringValue)
    }

    public init(_ value: UInt) {
        let rawValue = value.description
        self.init(rawValue, negative: false, integer: true, digit: rawValue.count , exponent: 0)
    }
    
    public init(_ value: UInt64) {
        let rawValue = value.description
        self.init(rawValue, negative: false, integer: true, digit: rawValue.count , exponent: 0)
    }
    
    public init(_ value: UInt32) {
        let rawValue = value.description
        self.init(rawValue, negative: false, integer: true, digit: rawValue.count , exponent: 0)
    }
    
    public init(_ value: UInt16) {
        let rawValue = value.description
        self.init(rawValue, negative: false, integer: true, digit: rawValue.count , exponent: 0)
    }
    
    public init(_ value: UInt8) {
        let rawValue = value.description
        self.init(rawValue, negative: false, integer: true, digit: rawValue.count , exponent: 0)
    }
    
    public init(_ value: Int) {
        let rawValue = value.description
        self.init(rawValue, negative: value < 0, integer: true, digit: value < 0 ? rawValue.count - 1 : rawValue.count , exponent: 0)
    }
    
    public init(_ value: Int64) {
        let rawValue = value.description
        self.init(rawValue, negative: value < 0, integer: true, digit: value < 0 ? rawValue.count - 1 : rawValue.count , exponent: 0)
    }
    
    public init(_ value: Int32) {
        let rawValue = value.description
        self.init(rawValue, negative: value < 0, integer: true, digit: value < 0 ? rawValue.count - 1 : rawValue.count , exponent: 0)
    }
    
    public init(_ value: Int16) {
        let rawValue = value.description
        self.init(rawValue, negative: value < 0, integer: true, digit: value < 0 ? rawValue.count - 1 : rawValue.count , exponent: 0)
    }
    
    public init(_ value: Int8) {
        let rawValue = value.description
        self.init(rawValue, negative: value < 0, integer: true, digit: value < 0 ? rawValue.count - 1 : rawValue.count , exponent: 0)
    }
    
    public init(_ value: Decimal) {
        self.init(floatLiteral: value.doubleValue)
    }
    
    public init(_ value: Double) {
        self.init(floatLiteral: value)
    }
    
    public init(_ value: Float) {
        self.init(floatLiteral: Double(exactly: value) ?? Double(value))
    }
    #if os(macOS)
    public init(_ value: Float80) {
        self.init(floatLiteral: Double(exactly: value) ?? Double(value))
    }
    #endif
}

extension JSON.Number : CustomStringConvertible {
    
    public var description: String { return rawValue }
    
}

extension JSON.Number : CustomDebugStringConvertible {
    
    public var debugDescription: String { return rawValue }
    
}

extension JSON.Number : ExpressibleByFloatLiteral {
    
    public typealias FloatLiteralType = Double
    
    public init(floatLiteral value:Double) {
        let rawValue = value.description
        self.init(rawValue, negative: value < 0, integer: rawValue.hasSuffix(".0"), digit: value.significandWidth, exponent: value.exponent)
    }
    
}

extension JSON.Number : ExpressibleByIntegerLiteral {
    
    public typealias IntegerLiteralType = Int
    
    public init(integerLiteral value: Int) {
        let rawValue = value.description
        self.init(rawValue, negative: value < 0, integer: true, digit: value < 0 ? rawValue.count - 1 : rawValue.count , exponent: 0)
    }
    
}

extension JSON.Number : ExpressibleByStringLiteral {
    
    public typealias StringLiteralType = String
    
    public init(stringLiteral value: String) {
        if let value = try? value.parseJSONNumber() {
            self = value
        } else if let double = Double(value) {
            self.init(floatLiteral: double)
        } else {
            self.init(integerLiteral: 0)
        }
    }
    
}


extension JSON.Number : Hashable, Comparable {
    
    public var boolValue: Bool {
        return doubleValue != 0
    }
    
    public var uintValue: UInt {
        return UInt(truncatingIfNeeded: uint64Value)
    }
    
    public var uint8Value: UInt8 {
        return UInt8(truncatingIfNeeded: uint64Value)
    }
    
    public var uint16Value: UInt16 {
        return UInt16(truncatingIfNeeded: uint64Value)
    }
    
    public var uint32Value: UInt32 {
        return UInt32(truncatingIfNeeded: uint64Value)
    }
    
    public var intValue: Int {
        return Int(truncatingIfNeeded: int64Value)
    }
    
    public var int8Value: Int8 {
        return Int8(truncatingIfNeeded: int64Value)
    }
    
    public var int16Value: Int16 {
        return Int16(truncatingIfNeeded: int64Value)
    }
    
    public var int32Value: Int32 {
        return Int32(truncatingIfNeeded: int64Value)
    }
    
    public var uint64Value: UInt64 {
        if isInteger {
            let result:UInt64?
            if let index = rawValue.firstIndex(of: ".") {
                result = UInt64(rawValue[..<index])
            } else {
                result = UInt64(rawValue)
            }
            return result ?? 0
        }
        let double = doubleValue
        return UInt64(exactly: double) ?? UInt64(double)
    }
    
    public var int64Value: Int64 {
        if isInteger {
            let result:Int64?
            if let index = rawValue.firstIndex(of: ".") {
                result = Int64(rawValue[..<index])
            } else {
                result = Int64(rawValue)
            }
            return result ?? 0
        }
        let double = doubleValue
        return Int64(exactly: double) ?? Int64(double)
    }
    
    public var decimalValue: Decimal {
        let _length = rawValue.count
        if _length == 0 {
            if isNegative {
                return Decimal.nan
            } else {
                return 0
            }
        }
        return Decimal(string: rawValue) ?? 0
    }
    
    public var floatValue: Float {
        let _length = rawValue.count
        if _length == 0 {
            if isNegative {
                return Float.nan
            } else {
                return 0
            }
        }
        return Float(rawValue) ?? 0
    }
    
    public var doubleValue: Double {
        let _length = rawValue.count
        if _length == 0 {
            if isNegative {
                return Double.nan
            } else {
                return 0
            }
        }
        
        return Double(rawValue) ?? 0
    }
    
    public var hashValue: Int {
        return doubleValue.hashValue
    }
    
    public static func ==(lhs: JSON.Number, rhs: JSON.Number) -> Bool {
        if lhs.isNaN {
            return rhs.isNaN
        } else if lhs.isInteger, rhs.isInteger {
            return lhs.int64Value == rhs.int64Value
        }
        return lhs.decimalValue == rhs.decimalValue
    }
    public static func <(lhs: JSON.Number, rhs: JSON.Number) -> Bool {
        if lhs.isInteger, rhs.isInteger {
            return lhs.int64Value < rhs.int64Value
        }
        return lhs.decimalValue < rhs.decimalValue
    }
}


extension JSON {
    
    public static func numberAdd(_ result: UnsafeMutablePointer<JSON.Number>, _ leftOperand: UnsafePointer<JSON.Number>, _ rightOperand: UnsafePointer<JSON.Number>, _ roundingMode: NSDecimalNumber.RoundingMode) -> NSDecimalNumber.CalculationError {
        if leftOperand.pointee.isInteger && rightOperand.pointee.isInteger {
            result.pointee = JSON.Number(leftOperand.pointee.int64Value + rightOperand.pointee.int64Value)
            return .noError
        }
        var lhs = leftOperand.pointee.decimalValue
        var rhs = rightOperand.pointee.decimalValue
        var r = Decimal()
        let error = NSDecimalAdd(&r, &lhs, &rhs, roundingMode)
        result.pointee = JSON.Number(r)
        return error
    }
    
    public static func numberSubtract(_ result: UnsafeMutablePointer<JSON.Number>, _ leftOperand: UnsafePointer<JSON.Number>, _ rightOperand: UnsafePointer<JSON.Number>, _ roundingMode: NSDecimalNumber.RoundingMode) -> NSDecimalNumber.CalculationError {
        
        if leftOperand.pointee.isInteger && rightOperand.pointee.isInteger {
            result.pointee = JSON.Number(leftOperand.pointee.int64Value - rightOperand.pointee.int64Value)
            return .noError
        }
        var lhs = leftOperand.pointee.decimalValue
        var rhs = rightOperand.pointee.decimalValue
        var r = Decimal()
        rhs.negate()
        let error = NSDecimalAdd(&r, &lhs, &rhs, roundingMode)
        result.pointee = JSON.Number(r)
        return error
    }
    
    
    public static func numberMultiply(_ result: UnsafeMutablePointer<JSON.Number>, _ leftOperand: UnsafePointer<JSON.Number>, _ rightOperand: UnsafePointer<JSON.Number>, _ roundingMode: NSDecimalNumber.RoundingMode) -> NSDecimalNumber.CalculationError {
        if leftOperand.pointee.isInteger && rightOperand.pointee.isInteger {
            result.pointee = JSON.Number(leftOperand.pointee.int64Value * rightOperand.pointee.int64Value)
            return .noError
        }
        var lhs = leftOperand.pointee.decimalValue
        var rhs = rightOperand.pointee.decimalValue
        var r = Decimal()
        let error = NSDecimalMultiply(&r, &lhs, &rhs, roundingMode)
        result.pointee = JSON.Number(r)
        return error
    }
    
    
    public static func numberDivide(_ result: UnsafeMutablePointer<JSON.Number>, _ leftOperand: UnsafePointer<JSON.Number>, _ rightOperand: UnsafePointer<JSON.Number>, _ roundingMode: NSDecimalNumber.RoundingMode) -> NSDecimalNumber.CalculationError {
        
        if leftOperand.pointee.isInteger && rightOperand.pointee.isInteger {
            let rhs = rightOperand.pointee.int64Value
            if rhs == 0 {
                return .divideByZero
            } else {
                result.pointee = JSON.Number(leftOperand.pointee.int64Value / rhs)
                return .noError
            }
        }
        var lhs = leftOperand.pointee.decimalValue
        var rhs = rightOperand.pointee.decimalValue
        var r = Decimal()
        let error = NSDecimalDivide(&r, &lhs, &rhs, roundingMode)
        result.pointee = JSON.Number(r)
        return error
    }
}


extension JSON.Number : SignedNumeric {
    
    public var magnitude: JSON.Number {
        return JSON.Number(decimalValue.magnitude)
    }
    
    // FIXME(integers): implement properly
    public init?<T : BinaryInteger>(exactly source: T) {
        fatalError()
    }
    
    public static func +=(_ lhs: inout JSON.Number, _ rhs: JSON.Number) {
        var leftOp = lhs
        var rightOp = rhs
        _ = JSON.numberAdd(&lhs, &leftOp, &rightOp, .plain)
    }
    
    public static func -=(_ lhs: inout JSON.Number, _ rhs: JSON.Number) {
        var leftOp = lhs
        var rightOp = rhs
        _ = JSON.numberSubtract(&lhs, &leftOp, &rightOp, .plain)
    }
    
    public static func *=(_ lhs: inout JSON.Number, _ rhs: JSON.Number) {
        var leftOp = lhs
        var rightOp = rhs
        _ = JSON.numberMultiply(&lhs, &leftOp, &rightOp, .plain)
    }
    
    public static func /=(_ lhs: inout JSON.Number, _ rhs: JSON.Number) {
        var leftOp = lhs
        var rightOp = rhs
        _ = JSON.numberDivide(&lhs, &leftOp, &rightOp, .plain)
    }
    
    public static func +(lhs: JSON.Number, rhs: JSON.Number) -> JSON.Number {
        var answer = lhs
        answer += rhs
        return answer;
    }
    
    public static func -(lhs: JSON.Number, rhs: JSON.Number) -> JSON.Number {
        var answer = lhs
        answer -= rhs
        return answer;
    }
    
    public static func /(lhs: JSON.Number, rhs: JSON.Number) -> JSON.Number {
        var answer = lhs
        answer /= rhs
        return answer;
    }
    
    public static func *(lhs: JSON.Number, rhs: JSON.Number) -> JSON.Number {
        var answer = lhs
        answer *= rhs
        return answer;
    }
    
//    @available(*, unavailable, message: "Decimal does not yet fully adopt FloatingPoint.")
//    public mutating func formTruncatingRemainder(dividingBy other: Decimal) { fatalError("Decimal does not yet fully adopt FloatingPoint") }
//
//    public mutating func negate() {
//        guard _length != 0 else { return }
//        _isNegative = _isNegative == 0 ? 1 : 0
//    }
}

extension JSON.Number : Strideable {
    public func distance(to other: JSON.Number) -> JSON.Number {
        return self - other
    }
    public func advanced(by n: JSON.Number) -> JSON.Number {
        return self + n
    }
}

extension JSON.Number {
    public typealias RoundingMode = NSDecimalNumber.RoundingMode
    public typealias CalculationError = NSDecimalNumber.CalculationError

    public var isSignalingNaN: Bool {
        return false
    }
    
    public static var nan: JSON.Number {
        return quietNaN
    }
    
    public static var infinity: JSON.Number {
        return JSON.Number(Double.infinity)
    }
    
    public static var quietNaN: JSON.Number {
        return JSON.Number("", negative: true, integer: false, digit: 0, exponent: 0)
    }
    
    public var floatingPointClass: FloatingPointClassification {
        let _length = rawValue.count
        if _length == 0 && isNegative {
            return .quietNaN
        } else if _length == 0 {
            return .positiveZero
        }
        if isNegative {
            return .negativeNormal
        } else {
            return .positiveNormal
        }
    }
    public var isSignMinus: Bool {
        return isNegative
    }
    public var isNormal: Bool {
        return !isZero && !isInfinite && !isNaN
    }
    public var isFinite: Bool {
        return !isNaN
    }
    public var isZero: Bool {
        let _length = rawValue.count
        return (_length == 0 && !isNegative) || doubleValue == 0
    }
    public var isSubnormal: Bool {
        return false
    }
    public var isInfinite: Bool {
        return false
    }
    public var isNaN: Bool {
        return rawValue.count == 0 && isNegative
    }
    public var isSignaling: Bool {
        return false
    }
}

//
//public func NSDecimalIsNotANumber(_ dcm: UnsafePointer<Decimal>) -> Bool {
//    return dcm.pointee.isNaN
//}
//
///***************    Operations        ***********/
//public func JSONNumberCopy(_ destination: UnsafeMutablePointer<JSON.Number>, _ source: UnsafePointer<JSON.Number>) {
//    destination.pointee = JSON.Number(source.pointee.rawValue, negative: source.pointee.isNegative, integer: source.pointee.isInteger, digit: source.pointee.digitCount, exponent: source.pointee.exponent)
//}
//
//public func NSDecimalCompact(_ number: UnsafeMutablePointer<JSON.Number>) {
//    number.pointee.compact()
//}
//
//// NSDecimalCompare:Compares leftOperand and rightOperand.
//public func NSDecimalCompare(_ leftOperand: UnsafePointer<JSON.Number>, _ rightOperand: UnsafePointer<JSON.Number>) -> ComparisonResult {
//    let left = leftOperand.pointee
//    let right = rightOperand.pointee
//    return left.compare(to: right)
//}
//
//public func NSDecimalRound(_ result: UnsafeMutablePointer<JSON.Number>, _ number: UnsafePointer<JSON.Number>, _ scale: Int, _ roundingMode: NSDecimalNumber.RoundingMode) {
//    JSONNumberCopy(result,number) // this is unnecessary if they are the same address, but we can't test that here
//    result.pointee.round(scale: scale,roundingMode: roundingMode)
//}
//// Rounds num to the given scale using the given mode.
//// result may be a pointer to same space as num.
//// scale indicates number of significant digits after the decimal point
//
//public func NSDecimalNormalize(_ a: UnsafeMutablePointer<JSON.Number>, _ b: UnsafeMutablePointer<JSON.Number>, _ roundingMode: NSDecimalNumber.RoundingMode) -> NSDecimalNumber.CalculationError {
//    var diffexp = a.pointee.__exponent - b.pointee.__exponent
//    var result = Decimal()
//
//    //
//    // If the two numbers share the same exponents,
//    // the normalisation is already done
//    //
//    if diffexp == 0 {
//        return .noError
//    }
//
//    //
//    // Put the smallest of the two in aa
//    //
//    var aa: UnsafeMutablePointer<JSON.Number>
//    var bb: UnsafeMutablePointer<JSON.Number>
//
//    if diffexp < 0 {
//        aa = b
//        bb = a
//        diffexp = -diffexp
//    } else {
//        aa = a
//        bb = b
//    }
//
//    //
//    // Build a backup for aa
//    //
//    var backup = Decimal()
//
//    NSDecimalCopy(&backup,aa)
//
//    //
//    // Try to multiply aa to reach the same exponent level than bb
//    //
//
//    if integerMultiplyByPowerOf10(&result, aa.pointee, Int(diffexp)) == .noError {
//        // Succeed. Adjust the length/exponent info
//        // and return no errorNSDecimalNormalize
//        aa.pointee.copyMantissa(from: result)
//        aa.pointee._exponent = bb.pointee._exponent
//        return .noError;
//    }
//
//    //
//    // Failed, restart from scratch
//    //
//    NSDecimalCopy(aa, &backup);
//
//    //
//    // What is the maximum pow10 we can apply to aa ?
//    //
//    let logBase10of2to16 = 4.81647993
//    let aaLength = aa.pointee._length
//    let maxpow10 = Int8(floor(Double(Decimal.maxSize - aaLength) * logBase10of2to16))
//
//    //
//    // Divide bb by this value
//    //
//    _ = integerMultiplyByPowerOf10(&result, bb.pointee, Int(maxpow10 - diffexp))
//
//    bb.pointee.copyMantissa(from: result)
//    bb.pointee._exponent -= Int32(maxpow10 - diffexp);
//
//    //
//    // If bb > 0 multiply aa by the same value
//    //
//    if !bb.pointee.isZero {
//        _ = integerMultiplyByPowerOf10(&result, aa.pointee, Int(maxpow10))
//        aa.pointee.copyMantissa(from: result)
//        aa.pointee._exponent -= Int32(maxpow10)
//    } else {
//        bb.pointee._exponent = aa.pointee._exponent;
//    }
//
//    //
//    // the two exponents are now identical, but we've lost some digits in the operation.
//    //
//    return .lossOfPrecision;
//}
//
//
//fileprivate func integerAdd(_ result: inout JSON.Number, _ left: inout JSON.Number, _ right: inout JSON.Number) -> NSDecimalNumber.CalculationError {
//    var idx: UInt32 = 0
//    var carry: UInt16 = 0
//    let maxIndex: UInt32 = min(left._length, right._length) // The highest index with bits set in both values
//
//    while idx < maxIndex {
//        let li = UInt32(left[idx])
//        let ri = UInt32(right[idx])
//        let sum = li + ri + UInt32(carry)
//        carry = UInt16(truncatingIfNeeded: sum >> 16)
//        result[idx] = UInt16(truncatingIfNeeded: sum)
//        idx += 1
//    }
//
//    while idx < left._length {
//        if carry != 0 {
//            let li = UInt32(left[idx])
//            let sum = li + UInt32(carry)
//            carry = UInt16(truncatingIfNeeded: sum >> 16)
//            result[idx] = UInt16(truncatingIfNeeded: sum)
//            idx += 1
//        } else {
//            while idx < left._length {
//                result[idx] = left[idx]
//                idx += 1
//            }
//            break
//        }
//    }
//    while idx < right._length {
//        if carry != 0 {
//            let ri = UInt32(right[idx])
//            let sum = ri + UInt32(carry)
//            carry = UInt16(truncatingIfNeeded: sum >> 16)
//            result[idx] = UInt16(truncatingIfNeeded: sum)
//            idx += 1
//        } else {
//            while idx < right._length {
//                result[idx] = right[idx]
//                idx += 1
//            }
//            break
//        }
//    }
//    result._length = idx
//
//    if carry != 0 {
//        result[idx] = carry
//        idx += 1
//        result._length = idx
//    }
//    if idx > Decimal.maxSize {
//        return .overflow
//    }
//
//    return .noError;
//}
//
//// integerSubtract: Subtract b from a, put the result in result, and
////     modify resultLen to match the length of the result.
//// Result may be a pointer to same space as a or b.
//// resultLen must be >= Max(aLen,bLen).
//// Could return NSCalculationOverflow if b > a. In this case 0 - result
////    give b-a...
////
//fileprivate func integerSubtract(_ result: inout JSON.Number, _ left: inout JSON.Number, _ right: inout JSON.Number) -> NSDecimalNumber.CalculationError {
//    var idx: UInt32 = 0
//    let maxIndex: UInt32 = min(left._length, right._length) // The highest index with bits set in both values
//    var borrow: UInt16 = 0
//
//    while idx < maxIndex {
//        let li = UInt32(left[idx])
//        let ri = UInt32(right[idx])
//        // 0x10000 is to borrow in advance to avoid underflow.
//        let difference: UInt32 = (0x10000 + li) - UInt32(borrow) - ri
//        result[idx] = UInt16(truncatingIfNeeded: difference)
//        // borrow = 1 if the borrow was used.
//        borrow = 1 - UInt16(truncatingIfNeeded: difference >> 16)
//        idx += 1
//    }
//
//    while idx < left._length {
//        if borrow != 0 {
//            let li = UInt32(left[idx])
//            let sum = 0xffff + li // + no carry
//            borrow = 1 - UInt16(truncatingIfNeeded: sum >> 16)
//            result[idx] = UInt16(truncatingIfNeeded: sum)
//            idx += 1
//        } else {
//            while idx < left._length {
//                result[idx] = left[idx]
//                idx += 1
//            }
//            break
//        }
//    }
//    while idx < right._length {
//        let ri = UInt32(right[idx])
//        let difference = 0xffff - ri + UInt32(borrow)
//        borrow = 1 - UInt16(truncatingIfNeeded: difference >> 16)
//        result[idx] = UInt16(truncatingIfNeeded: difference)
//        idx += 1
//    }
//
//    if borrow != 0 {
//        return .overflow
//    }
//    result._length = idx;
//    result.trimTrailingZeros()
//
//    return .noError;
//}
//
//
//public func NSDecimalPower(_ result: UnsafeMutablePointer<JSON.Number>, _ number: UnsafePointer<JSON.Number>, _ power: Int, _ roundingMode: NSDecimalNumber.RoundingMode) -> NSDecimalNumber.CalculationError {
//
//    if number.pointee.isNaN {
//        result.pointee.setNaN()
//        return .overflow
//    }
//    JSONNumberCopy(result,number)
//    return result.pointee.power(UInt(power), roundingMode:roundingMode)
//}
//
//public func NSDecimalMultiplyByPowerOf10(_ result: UnsafeMutablePointer<JSON.Number>, _ number: UnsafePointer<JSON.Number>, _ power: Int16, _ roundingMode: NSDecimalNumber.RoundingMode) -> NSDecimalNumber.CalculationError {
//    JSONNumberCopy(result,number)
//    return result.pointee.multiply(byPowerOf10: power)
//}
//
//public func NSDecimalString(_ dcm: UnsafePointer<JSON.Number>) -> String {
//
//    return dcm.pointee.description
//}
//
//private func multiplyBy10(_ dcm: inout JSON.Number, andAdd extra:Int) -> NSDecimalNumber.CalculationError {
//    let backup = dcm
//
//    if multiplyByShort(&dcm, 10) == .noError && addShort(&dcm, UInt16(extra)) == .noError {
//        return .noError
//    } else {
//        dcm = backup // restore the old values
//        return .overflow // this is the only possible error
//    }
//}

// == Internal (Swifty) functions ==

extension JSON.Number {
//
//    internal func compare(to other:JSON.Number) -> ComparisonResult {
//        // NaN is a special case and is arbitrary ordered before everything else
//        // Conceptually comparing with NaN is bogus anyway but raising or
//        // always returning the same answer will confuse the sorting algorithms
//        if self.isNaN {
//            return other.isNaN ? .orderedSame : .orderedAscending
//        }
//        if other.isNaN {
//            return .orderedDescending
//        }
//        // Check the sign
//        if isNegative && !other.isNegative {
//            return .orderedAscending
//        }
//        if !isNegative && other.isNegative {
//            return .orderedDescending
//        }
//
//        // If one of the two is == 0, the other is bigger
//        // because 0 implies isNegative = 0...
//        if isZero && other.isZero {
//            return .orderedSame
//        }
//        if isZero {
//            return .orderedAscending
//        }
//        if other.isZero {
//            return .orderedDescending
//        }
//
//        var selfNormal = self
//        var otherNormal = other
//        _ = NSDecimalNormalize(&selfNormal, &otherNormal, .down)
//        let comparison = mantissaCompare(selfNormal,otherNormal)
//        if selfNormal._isNegative == 1 {
//            if comparison == .orderedDescending {
//                return .orderedAscending
//            } else if comparison == .orderedAscending {
//                return .orderedDescending
//            } else {
//                return .orderedSame
//            }
//        }
//        return comparison
//    }
}


extension JSON.Number : Codable {
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(Double.self)
        self.init(floatLiteral: value)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(doubleValue)
    }
}
