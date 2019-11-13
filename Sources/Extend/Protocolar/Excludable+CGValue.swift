//
//  Excludable+CGValue.swift
//  Protocolar
//
//  Created by bujiandi on 2019/4/18.
//

#if canImport(CoreGraphics)
import CoreGraphics

extension CGFloat : Excludable {}
extension CGPoint : Excludable {}
extension CGSize  : Excludable {}
extension CGRect  : Excludable {}

#endif
