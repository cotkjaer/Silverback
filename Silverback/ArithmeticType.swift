//
//  ArithmeticType.swift
//  Silverback
//
//  Created by Christian Otkjær on 14/12/15.
//  Copyright © 2015 Christian Otkjær. All rights reserved.
//

public protocol ArithmeticType: Comparable
{
    func +(lhs: Self, rhs: Self) -> Self
    func -(lhs: Self, rhs: Self) -> Self
    func *(lhs: Self, rhs: Self) -> Self
    func /(lhs: Self, rhs: Self) -> Self
}

extension Double: ArithmeticType {}
extension Float: ArithmeticType {}
extension Int: ArithmeticType {}
extension UInt: ArithmeticType {}
