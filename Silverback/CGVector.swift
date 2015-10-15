//
//  CGVector.swift
//  SilverbackFramework
//
//  Created by Christian Otkjær on 20/04/15.
//  Copyright (c) 2015 Christian Otkjær. All rights reserved.
//

import CoreGraphics

// MARK: - CGVector

public let CGVectorZero = CGVector(0,0)

extension CGVector
{
    public init(_ dx: CGFloat, _ dy: CGFloat)
    {
        self.dx = dx
        self.dy = dy
    }
    
    public init(_ point:CGPoint)
    {
        dx = point.x
        dy = point.y
    }
    
    public init(_ from:CGPoint, to: CGPoint)
    {
        dx = to.x - from.x
        dy = to.x - from.x
    }
    
    // MARK: with
    
    public func with(dx  dx: CGFloat) -> CGVector
    {
        return CGVector(dx, dy)
    }
    
    public func with(dy  dy: CGFloat) -> CGVector
    {
        return CGVector(dx, dy)
    }
    
    // MARK: length
    
    public var length : CGFloat
        { get
        { return sqrt(pow(dx, 2) + pow(dy, 2)) }}
    
    // MARK: rotation
    
    /// angle is in radians
    public mutating func rotate(theta:CGFloat)
    {
        let sinTheta = sin(theta)
        let cosTheta = cos(theta)
        
        dx = (dx * cosTheta - dy * sinTheta)
        dy = (dx * sinTheta + dy * cosTheta)
    }
    
    public var angle : CGFloat
        { return atan2(dy, dx) }
}

func length(vector: CGVector) -> CGFloat
{
    return vector.length
}

func midPoint(between vector1:CGVector, and vector2:CGVector) -> CGVector
{
    return CGVector((vector1.dx + vector2.dx) / 2.0, (vector1.dy + vector2.dy) / 2.0)
}

// MARK: Equatable

extension CGVector//: Equatable
{
    func isEqualTo(vector: CGVector, withPrecision precision:CGFloat) -> Bool
    {
        return  (self - vector).length < abs(precision)
    }
    
    //    public func isEqualTo(vector:CGVector) -> Bool
    //{
    //        return self == vector
    //    }
}

//public func == (vector1: CGVector, vector2: CGVector) -> Bool
//{
//    return vector1.dx == vector2.dx && vector1.dy == vector2.dy
//}

func isEqual(vector1: CGVector, vector2: CGVector, precision:CGFloat) -> Bool
{
    return (vector1 - vector2).length < abs(precision)
}

// MARK: operators

public func + (vector1: CGVector, vector2: CGVector) -> CGVector
{
    return CGVector(vector1.dx + vector2.dx, vector1.dy + vector2.dy)
}

public func += (inout vector1: CGVector, vector2: CGVector)
{
    vector1.dx += vector2.dx
    vector1.dy += vector2.dy
}

public func - (vector1: CGVector, vector2: CGVector) -> CGVector
{
    return CGVector(vector1.dx - vector2.dx, vector1.dy - vector2.dy)
}

public func -= (inout vector1: CGVector, vector2: CGVector)
{
    vector1.dx -= vector2.dx
    vector1.dy -= vector2.dy
}

public func + (vector: CGVector, size: CGSize) -> CGVector
{
    return CGVector(vector.dx + size.width, vector.dy + size.height)
}

public func += (inout vector: CGVector, size: CGSize)
{
    vector.dx += size.width
    vector.dy += size.height
}

public func - (vector: CGVector, size: CGSize) -> CGVector
{
    return CGVector(vector.dx - size.width, vector.dy - size.height)
}

public func -= (inout vector: CGVector, size: CGSize)
{
    vector.dx -= size.width
    vector.dy -= size.height
}

public func * (factor: CGFloat, vector: CGVector) -> CGVector
{
    return CGVector(vector.dx * factor, vector.dy * factor)
}

public func * (vector: CGVector, factor: CGFloat) -> CGVector
{
    return CGVector(vector.dx * factor, vector.dy * factor)
}

public func *= (inout vector: CGVector, factor: CGFloat)
{
    vector.dx *= factor
    vector.dy *= factor
}

public func / (vector: CGVector, factor: CGFloat) -> CGVector
{
    return CGVector(vector.dx / factor, vector.dy / factor)
}

public func /= (inout vector: CGVector, factor: CGFloat)
{
    vector.dx /= factor
    vector.dy /= factor
}
