//
//  CGFloat.swift
//  Pods
//
//  Created by Christian Otkjær on 20/04/15.
//
//

import CoreGraphics

//MARK: - Math

extension CGFloat
{
    static let 𝑒 = CGFloat(M_E)
    
    static let π_4 = CGFloat(M_PI_4)
    static let π_8 = CGFloat(M_PI_4 / 2)
}

extension CGFloat: ArithmeticType {}

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

public func *= (inout rhs: CGFloat, lhs: Int)
{
    rhs *= CGFloat(lhs)
}


public func / (rhs: CGFloat, lhs: Int) -> CGFloat
{
    return rhs / CGFloat(lhs)
}

public func / (rhs: Int, lhs: CGFloat) -> CGFloat
{
    return CGFloat(rhs) / lhs
}

public func /= (inout rhs: CGFloat, lhs: Int)
{
    rhs /= CGFloat(lhs)
}


public func + (rhs: CGFloat, lhs: Int) -> CGFloat
{
    return rhs + CGFloat(lhs)
}

public func + (rhs: Int, lhs: CGFloat) -> CGFloat
{
    return CGFloat(rhs) + lhs
}

public func += (inout rhs: CGFloat, lhs: Int)
{
    rhs += CGFloat(lhs)
}


public func - (rhs: CGFloat, lhs: Int) -> CGFloat
{
    return rhs - CGFloat(lhs)
}

public func - (rhs: Int, lhs: CGFloat) -> CGFloat
{
    return CGFloat(rhs) - lhs
}

public func -= (inout rhs: CGFloat, lhs: Int)
{
    rhs -= CGFloat(lhs)
}


// MARK: - Angles

extension CGFloat
{
//    static let π = CGFloat(M_PI)
//    static let π2 = CGFloat(M_PI * 2)
//    static let π_2 = CGFloat(M_PI_2)
    
    /**
    Normalize an angle in a 2π wide interval around a center value.
    - parameter φ: angle to normalize
    - parameter Φ: center of the desired 2π-interval for the result
    - returns: φ - 2πk; with integer k and Φ - π <= φ - 2πk <= Φ + π
    
    - Note: This method has three main uses:
    1. normalize an angle between 0 and 2π
    ```swift
    let a = CGFloat.normalizeAngle(a, π)
    ```
    
    2. normalize an angle between -π and +π
    ```swift
    let a = CGFloat.normalizeAngle(a, 0)
    ```
    
    3. compute the angle between two defining angular positions
    ```swift
    let angle = CGFloat.normalizeAngle(end, start) - start
    ```
    
    - Warning: Due to numerical accuracy and since π cannot be represented
    exactly, the result interval is **closed**, it cannot be half-closed
    as would be more satisfactory in a purely mathematical view.
    
    */
    public static func normalizeAngle(φ : CGFloat, _ Φ: CGFloat = π) -> CGFloat
    {
        return φ - π2 * floor((φ + π - Φ) / π2)
    }
    
    /// normalized value, as an angle between 0 and 2π
    public var asNormalizedAngle : CGFloat { return CGFloat.normalizeAngle(self) }

    
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

