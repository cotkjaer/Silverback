//
//  CGFloat.swift
//  Pods
//
//  Created by Christian Otkjær on 20/04/15.
//
//

import CoreGraphics

// MARK: - Equals

public let CGFloatZero = CGFloat(0.0)

extension CGFloat
{
    public func isEqualWithin(precision: CGFloat, to: CGFloat) -> Bool
    {
        return abs(self - to) < abs(precision)
    }
}

public func equalsWithin(precision: CGFloat, f1: CGFloat, to f2: CGFloat) -> Bool
{
    return abs(f1 - f2) < abs(precision)
}

public func * (rhs: CGFloat, lhs: Int) -> CGFloat
{
    return rhs * CGFloat(lhs)
}

public func * (rhs: Int, lhs: CGFloat) -> CGFloat
{
    return CGFloat(rhs) * lhs
}

public func += (inout rhs: CGFloat, lhs: Int)
{
    rhs += CGFloat(lhs)
}

public func -= (inout rhs: CGFloat, lhs: Int)
{
    rhs += CGFloat(lhs)
}

public func *= (inout rhs: CGFloat, lhs: Int)
{
    rhs *= CGFloat(lhs)
}

public func /= (inout rhs: CGFloat, lhs: Int)
{
    rhs /= CGFloat(lhs)
}

// MARK: - Angles

internal let sin60 : CGFloat = 0.866025403784439

public extension CGFloat
{
    /// Normalizes self to be in ]-π;π]
    public var normalizedRadians: CGFloat
        {
            return self - ( ceil( self / π2 - 0.5 ) ) * π2
    }
}

/// Normalizes angle to be in ]-π;π]
public func normalizeRadians(radians: CGFloat) -> CGFloat
{
    return radians - ( ceil( radians / π2 - 0.5 ) ) * π2
}

// MARK: - Random

extension CGFloat
{
    /**
    Create a random CGFloat
    - parameter lower: bounds
    - parameter upper: bounds
    :return: random number CGFloat
    */
    public static func random(lower lower: CGFloat, upper: CGFloat) -> CGFloat
    {
        let r = CGFloat(arc4random(UInt32)) / CGFloat(UInt32.max)
        return (r * (upper - lower)) + lower
    }
}

public extension CGFloat
{
    public func format(format: String? = "") -> String
    {
        return String(format: "%\(format)f", self)
    }
}

