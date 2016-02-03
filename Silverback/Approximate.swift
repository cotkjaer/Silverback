//
//  Approximate.swift
//  Silverback
//
//  Created by Christian Otkjær on 14/12/15.
//  Copyright © 2015 Christian Otkjær. All rights reserved.
//

import CoreGraphics

//MARK: - Approximate equals

public func equal<C:Comparable where C:Subtractable, C:AbsoluteValuable>(lhs: C, _ rhs: C, accuracy: C) -> Bool
{
    return abs(rhs - lhs) <= accuracy// || lhs - rhs <= accuracy
}
//
//public func equal(lhs: CGFloat, _ rhs: CGFloat, accuracy: CGFloat) -> Bool {
//    return abs(rhs - lhs) <= accuracy
//}
//
//public func equal(lhs: Float, _ rhs: Float, accuracy: Float) -> Bool {
//    return abs(rhs - lhs) <= accuracy
//}
//
//public func equal(lhs: Double, _ rhs: Double, accuracy: Double) -> Bool {
//    return abs(rhs - lhs) <= accuracy
//}

// MARK: Fuzzy equality

public protocol FuzzyEquatable
{
    func ==%(lhs: Self, rhs: Self) -> Bool
}

infix operator ==% { associativity none precedence 130 }

// MARK: Fuzzy inequality

infix operator !=% { associativity none precedence 130 }

public func !=% <T: FuzzyEquatable> (lhs: T, rhs: T) -> Bool
{
    return !(lhs ==% rhs)
}

// MARK: Float

extension Float: FuzzyEquatable {}

public func ==% (lhs: Float, rhs: Float) -> Bool
{
    let epsilon = Float(FLT_EPSILON) // TODO: FLT vs DBL
    return equal(lhs, rhs, accuracy: epsilon)
}

// MARK: Double

extension Double: FuzzyEquatable {}

public func ==% (lhs: Double, rhs: Double) -> Bool
{
    let epsilon = Double(FLT_EPSILON) // TODO: FLT vs DBL
    return equal(lhs, rhs, accuracy: epsilon)
}

// Mark: CGFloat

extension CGFloat: FuzzyEquatable {}

public func ==% (lhs: CGFloat, rhs: CGFloat) -> Bool {
    let epsilon = CGFloat(FLT_EPSILON) // TODO: FLT vs DBL
    return equal(lhs, rhs, accuracy: epsilon)
}

// MARK: CGPoint

extension CGPoint: FuzzyEquatable {}

public func ==% (lhs: CGPoint, rhs: CGPoint) -> Bool { return lhs.x ==% rhs.x && lhs.y ==% rhs.y }
