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

