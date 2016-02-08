//
//  Sign.swift
//  Silverback
//
//  Created by Christian Otkjær on 10/12/15.
//  Copyright © 2015 Christian Otkjær. All rights reserved.
//

import CoreGraphics

//MARK: - Sign

public func sign<N:IntegerLiteralConvertible where N:Comparable>(n: N) -> N
{
    if n < 0
    {
        return -1
    }
    
    return 1
}

public func sameSign<N:IntegerLiteralConvertible where N:Comparable>(lhs: N, _ rhs: N) -> Bool
{
    if lhs < 0 && rhs < 0
    {
        return true
    }
    
    if lhs >= 0 && rhs >= 0
    {
        return true
    }
    
    return false
}


public func degrees2radians(degrees: Float) -> Float
{
    return (degrees * Float(M_PI)) / Float(180)
}

public func degrees2radians(degrees: CGFloat) -> CGFloat
{
    return (degrees * CGFloat(M_PI)) / CGFloat(180)
}

public func degrees2radians(degrees: Double) -> Double
{
    return degrees * M_PI / Double(180)
}

public func radians2degrees(radians: Float) -> Float
{
    return (radians * Float(180)) / Float(M_PI)
}

public func radians2degrees(radians: CGFloat) -> CGFloat
{
    return (radians * CGFloat(180)) / CGFloat(M_PI)
}

public func radians2degrees(radians: Double) -> Double
{
    return radians * Double(180) / M_PI
}