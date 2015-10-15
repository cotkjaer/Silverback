//
//  Random.swift
//  SilverbackFramework
//
//  Created by Christian Otkjær on 20/04/15.
//  Copyright (c) 2015 Christian Otkjær. All rights reserved.
//

import Foundation
import UIKit


public extension Int
{
    /**
    Random integer in the open range [_lower_;_upper_[, ie. an integer between lower (_inclusive_) and upper (_exclusive_)
    
    NB! _lower_ **must** be less than _upper_
    
    - parameter lower: lower limit - inclusive
    - parameter upper: upper limit - exclusive
    - returns: Random integer in the open range [_lower_;_upper_[
    */
    static func random(lower lower: Int = min, upper: Int = max) -> Int
    {
        return Int(Int64.random(Int64(lower), upper: Int64(upper)))
    }
}

/**
Arc Random for Double and Float
*/
public func arc4random <T: IntegerLiteralConvertible> (type: T.Type) -> T
{
    var r: T = 0
    
    arc4random_buf(&r, sizeof(T))
    
    return r
}


public extension UInt64
{
    static func random(lower: UInt64 = min, upper: UInt64 = max) -> UInt64
    {
        var m: UInt64
        let u = upper - lower
        var r = arc4random(UInt64)
        
        if u > UInt64(Int64.max)
        {
            m = 1 + ~u
        }
        else
        {
            m = ((max - (u * 2)) + 1) % u
        }
        
        while r < m
        {
            r = arc4random(UInt64)
        }
        
        return (r % u) + lower
    }
}

public extension Int64
{
    static func random(lower: Int64 = min, upper: Int64 = max) -> Int64
    {
        let (s, overflow) = Int64.subtractWithOverflow(upper, lower)
        let u = overflow ? UInt64.max - UInt64(~s) : UInt64(s)
        let r = UInt64.random(upper: u)
        
        if r > UInt64(Int64.max)
        {
            return Int64(r - (UInt64(~lower) + 1))
        }
        else
        {
            return Int64(r) + lower
        }
    }
}

public extension UInt32
{
    static func random(lower: UInt32 = min, upper: UInt32 = max) -> UInt32
    {
        return arc4random_uniform(upper - lower) + lower
    }
}

public extension Int32
{
    static func random(lower: Int32 = min, upper: Int32 = max) -> Int32
    {
        let r = arc4random_uniform(UInt32(Int64(upper) - Int64(lower)))
        return Int32(Int64(r) + Int64(lower))
    }
}

public extension UInt
{
    static func random(lower: UInt = min, upper: UInt = max) -> UInt
    {
        return UInt(UInt64.random(UInt64(lower), upper: UInt64(upper)))
    }
}

public extension Double
{
    /**
    Create a random num Double
    - parameter lower: number Double
    - parameter upper: number Double
    :return: random number Double
    */
    public static func random(lower lower: Double, upper: Double) -> Double
    {
        let r = Double(arc4random(UInt64)) / Double(UInt64.max)
        return (r * (upper - lower)) + lower
    }
}

// MARK: - Random Color

extension UIColor
{
    static func randomColor() -> UIColor
    {
        return UIColor(red: CGFloat(Double.random(lower: 0, upper: 1)),
            green: CGFloat(Double.random(lower: 0, upper: 1)),
            blue: CGFloat(Double.random(lower: 0, upper: 1)),
            alpha: 1)
    }
}

