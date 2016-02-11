//
//  Float.swift
//  SilverbackFramework
//
//  Created by Christian Otkjær on 20/04/15.
//  Copyright (c) 2015 Christian Otkjær. All rights reserved.
//

import Foundation

public extension Float
{
    /**
    Absolute value.
    
    - returns: fabs(self)
    */
    public var abs: Float
        {
            return fabsf(self)
    }
    
    /**
    Squareroot.
    
    - returns: sqrtf(self)
    */
    public var sqrt: Float
        {
            return sqrtf(self)
    }
    
    /**
    Round to largest integral value not greater than self
    
    - returns: floorf(self)
    */
    public var floor: Float
        {
            return floorf(self)
    }
    
    /**
    Round to smallest integral value not less than self
    
    - returns: ceilf(self)
    */
    public var ceil: Float
        {
            return ceilf(self)
    }
    
    /**
    Rounds self to the nearest integral value
    
    - returns: roundf(self)
    */
    public var round: Float
        {
            return roundf(self)
    }
    
    /**
    Clamps self to a specified range.
    
    - parameter min: Lower bound
    - parameter max: Upper bound
    - returns: Clamped value
    */
    public func clamp (lower: Float, _ upper: Float) -> Float
    {
        return Swift.max(lower, Swift.min(upper, self))
    }
    
    public static func random() -> Float
    {
        return random(lower: 0.0, upper: HUGE)
    }
    
    /**
    Create a random Float between lower and upper bounds (inclusive)
    
    - parameter lower: number Float
    - parameter upper: number Float
    :return: random number Float
    */
    public static func random(lower lower: Float, upper: Float) -> Float
    {
        if lower > upper
        { return random(lower: upper, upper: lower) }
        
        let r = Float(arc4random(UInt32)) / Float(UInt32.max)
        return (r * (upper - lower)) + lower
    }
}

public extension Float
{
    public func format(format: String? = "") -> String
    {
        return String(format: "%\(format)f", self)
    }
}

public func rms(xs: Float...)
{
    
}


///The root mean square (abbreviated RMS or rms), also known as the quadratic mean, in statistics is a statistical measure defined as the square root of the mean of the squares of a sample
/// - Note: With large numbers this may overrun
@warn_unused_result
public func rms<S: SequenceType where S.Generator.Element == Float>(xs: S) -> Float
{
    let count = xs.count{ _ in true }
    
    guard count > 0 else { return 0 }
    
    let sum = xs.reduce(Float(0), combine: { $0 + $1*$1 })
    
    return sqrtf(sum / Float(count))
}

public func rms(xs: [Float], firstIndex: Int, lastIndex: Int) -> Float
{
    return rms(xs[firstIndex...lastIndex])
}

///The simplest (and by no means ideal) low-pass filter is given by the following difference equation: 
///```swift
/// y(n) = x(n) + x(n - 1)
///```
///where `x(n)` is the filter input amplitude at time (or sample) `n` , and `y(n)` is the output amplitude at time `n`
//func lowpass(x: [Float], inout y: [Float], xm1: Float, m: Int, offset: Int) -> Float
//{
//    y[offset] = x[offset] + xm1
//    
//    for var n = 1; n < m ; n++
//    {
//        y[offset + n] =  x[offset + n] + x[offset + n-1]
//    }
//    
//    return x[offset + m-1]
//}

public func lowpass(xs: [Float]) -> [Float]
{
    let M = xs.count
    
    guard M > 0 else { return [] }
    
    var ys = Array<Float>(count: xs.count, repeatedValue: Float(0))
    
    ys[0] = xs[0]
    
    for var n = 1; n < M; n++
    {
        ys[n] = xs[n] + xs[n-1]
    }

    return ys
}

// MARK: - Int interoperability

public func * (rhs: Float, lhs: Int) -> Float
{
    return rhs * Float(lhs)
}

public func * (rhs: Int, lhs: Float) -> Float
{
    return Float(rhs) * lhs
}

public func *= (inout rhs: Float, lhs: Int)
{
    rhs *= Float(lhs)
}


public func / (rhs: Float, lhs: Int) -> Float
{
    return rhs / Float(lhs)
}

public func / (rhs: Int, lhs: Float) -> Float
{
    return Float(rhs) / lhs
}

public func /= (inout rhs: Float, lhs: Int)
{
    rhs /= Float(lhs)
}


public func + (rhs: Float, lhs: Int) -> Float
{
    return rhs + Float(lhs)
}

public func + (rhs: Int, lhs: Float) -> Float
{
    return Float(rhs) + lhs
}

public func += (inout rhs: Float, lhs: Int)
{
    rhs += Float(lhs)
}


public func - (rhs: Float, lhs: Int) -> Float
{
    return rhs - Float(lhs)
}

public func - (rhs: Int, lhs: Float) -> Float
{
    return Float(rhs) - lhs
}

public func -= (inout rhs: Float, lhs: Int)
{
    rhs -= Float(lhs)
}

