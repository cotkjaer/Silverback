//
//  CGVector.swift
//  SilverbackFramework
//
//  Created by Christian Otkjær on 20/04/15.
//  Copyright (c) 2015 Christian Otkjær. All rights reserved.
//

import CoreGraphics

// MARK: - CGVector

public let CGVectorZero = CGVector(dx:0, dy:0)

extension CGVector
{
    public init(point: CGPoint)
    {
        dx = point.x
        dy = point.y
    }
    
    public init(from:CGPoint, to: CGPoint)
    {
        dx = to.x - from.x
        dy = to.y - from.y
    }
    
    // MARK: with
    
    public func with(dx  dx: CGFloat) -> CGVector
    {
        return CGVector(dx:dx, dy:dy)
    }
    
    public func with(dy  dy: CGFloat) -> CGVector
    {
        return CGVector(dx:dx, dy:dy)
    }
    
    // MARK: length
    
    public var length : CGFloat { return sqrt(lengthSquared) }
    public var lengthSquared : CGFloat { return dx*dx + dy*dy }
    
    // MARK: - normalizing
    
    public mutating func normalize()
    {
        self /= length
    }
    
    public var normalized : CGVector { return self / length }
    
    // MARK: - Perpendicular
    
    /// returns: vector from rotation this by 90 degrees either clockwise or counterclockwise
    public func perpendicular(clockwise clockwise : Bool = true) -> CGVector
    {
        return clockwise ? CGVector(dx: dy, dy: -dx) : CGVector(dx: -dy, dy: dx)
    }
    
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
    return CGVector(dx: (vector1.dx + vector2.dx) / 2.0, dy: (vector1.dy + vector2.dy) / 2.0)
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
    return CGVector(dx: vector1.dx + vector2.dx, dy: vector1.dy + vector2.dy)
}

public func += (inout vector1: CGVector, vector2: CGVector)
{
    vector1.dx += vector2.dx
    vector1.dy += vector2.dy
}

public func - (vector1: CGVector, vector2: CGVector) -> CGVector
{
    return CGVector(dx: vector1.dx - vector2.dx, dy: vector1.dy - vector2.dy)
}

public func -= (inout vector1: CGVector, vector2: CGVector)
{
    vector1.dx -= vector2.dx
    vector1.dy -= vector2.dy
}

public func + (vector: CGVector, size: CGSize) -> CGVector
{
    return CGVector(dx: vector.dx + size.width, dy: vector.dy + size.height)
}

public func += (inout vector: CGVector, size: CGSize)
{
    vector.dx += size.width
    vector.dy += size.height
}

public func - (vector: CGVector, size: CGSize) -> CGVector
{
    return CGVector(dx: vector.dx - size.width, dy: vector.dy - size.height)
}

public func -= (inout vector: CGVector, size: CGSize)
{
    vector.dx -= size.width
    vector.dy -= size.height
}

public func * (factor: CGFloat, vector: CGVector) -> CGVector
{
    return CGVector(dx: vector.dx * factor, dy: vector.dy * factor)
}

public func * (vector: CGVector, factor: CGFloat) -> CGVector
{
    return CGVector(dx: vector.dx * factor, dy: vector.dy * factor)
}

public func *= (inout vector: CGVector, factor: CGFloat)
{
    vector.dx *= factor
    vector.dy *= factor
}

public func / (vector: CGVector, factor: CGFloat) -> CGVector
{
    return CGVector(dx: vector.dx / factor, dy: vector.dy / factor)
}

public func /= (inout vector: CGVector, factor: CGFloat)
{
    vector.dx /= factor
    vector.dy /= factor
}


//MARK: - Draw

import UIKit

extension CGVector
{
    func draw(atPoint point: CGPoint, withColor color: UIColor = UIColor.blueColor(), inContext: CGContextRef? = UIGraphicsGetCurrentContext())
    {
        guard let context = inContext else { return }
        
        let l = length
        
        guard l > 0  else { return }
        
        CGContextSaveGState(context)
        
        color.setStroke()
        
        let path = UIBezierPath()
        
        var vectorToDraw = self
        
        if length < 10
        {
            vectorToDraw *= 10 / length
        }
        
        path.moveToPoint(point)
        path.addLineToPoint(point + vectorToDraw)
        
        path.stroke()
        
        CGContextRestoreGState(context)
    }
    
    func bezierPathWithArrowFromPoint(startPoint: CGPoint) -> UIBezierPath
    {
        let toPoint = startPoint + self
        let tailWidth = max(1, length / 30)
        let headWidth = max(3, length / 10)
        
        let headStartPoint = lerp(startPoint, toPoint, 0.9)
        
        let p = perpendicular().normalized
        
        let path = UIBezierPath()
        
        path.moveToPoint(toPoint)
        path.addLineToPoint(headStartPoint + p * headWidth)
        path.addLineToPoint(headStartPoint + p * tailWidth)
        path.addLineToPoint(startPoint + p * tailWidth)
        
        path.addLineToPoint(startPoint - p * tailWidth)
        path.addLineToPoint(headStartPoint - p * tailWidth)
        path.addLineToPoint(headStartPoint - p * headWidth)
        
        path.closePath()
                
        return path
    }
}

