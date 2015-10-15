//
//  CGPoint.swift
//  SilverbackFramework
//
//  Created by Christian Otkjær on 20/04/15.
//  Copyright (c) 2015 Christian Otkjær. All rights reserved.
//

import CoreGraphics
import UIKit

// MARK: - CGPoint

extension CGPoint
{
//    public init(_ x: CGFloat, _ y: CGFloat)
//    {
//        self.x = x
//        self.y = y
//    }
    
    // MARK: with
    
    public func with(x  x: CGFloat) -> CGPoint
    {
        return CGPoint(x: x, y: y)
    }
    
    public func with(y  y: CGFloat) -> CGPoint
    {
        return CGPoint(x: x, y: y)
    }
    
    // MARK: distance
    
    public func distanceTo(point: CGPoint) -> CGFloat
    {
        return sqrt(distanceSquaredTo(point))
    }
    
    public func distanceSquaredTo(point: CGPoint) -> CGFloat
    {
        return pow(x - point.x, 2) + pow(y - point.y, 2)
    }
    
    // MARK: mid way
    
    public func midWayTo(p2:CGPoint) -> CGPoint
    {
        return CGPoint(x: (self.x + p2.x) / 2.0, y: (self.y + p2.y) / 2.0)
    }
    
    // MARK: rotation
    
    /// angle is in radians
    public mutating func rotate(theta:CGFloat, around center:CGPoint)
    {
        let sinTheta = sin(theta)
        let cosTheta = cos(theta)
        
        let transposedX = x - center.x
        let transposedY = y - center.y
        
        x = center.x + (transposedX * cosTheta - transposedY * sinTheta)
        y = center.y + (transposedX * sinTheta + transposedY * cosTheta)
    }
    
    public func angleToPoint(point: CGPoint) -> CGFloat
    {
        return atan2(point.y - y, point.x - x)
    }
}

public func dot(a: CGPoint, _ b: CGPoint) -> CGFloat
{
    return a.x * b.x + a.y * b.y
}

public func distance(a: CGPoint, _ b: CGPoint) -> CGFloat
{
    return a.distanceTo(b)
}

public func distanceSquared(a: CGPoint, _ b: CGPoint) -> CGFloat
{
    return pow(a.x - b.x, 2) + pow(a.y - b.y, 2)
}

/**
Distance between a line-segment and a point
- parameter lineSegment: line-segment
- parameter point: point
- returns: Minimum distance between a line-segment and a point
*/
public func distance(lineSegment:(CGPoint, CGPoint), _ point: CGPoint) -> CGFloat
{
    let v = lineSegment.0
    let w = lineSegment.1
    let p = point
    
    if v == w { return distance(v, p) }
    
    // Return minimum distance between line segment vw and point p
    
    let l = distanceSquared(v, w)
    
    // Consider the line extending the segment, parameterized as v + t (w - v).
    // We find projection of point p onto the line.
    // It falls where t = [(p-v) . (w-v)] / |w-v|^2
    let t = dot(p - v, w - v) / l
    
    if t < 0 // Beyond the 'v' end of the segment
    {
        return distance(p, v)
    }
    else if t > 1 // Beyond the 'w' end of the segment
    {
        return distance(p, w)
    }
    else // Projection falls on the segment
    {
        let projection = (1-t) * v + t * w// v + t * (w - v)
        return distance(p, projection)
    }
}

/**
Precise linear interpolation function which guarantees *lerp(a,b,0) == a && lerp(a,b,1) == b*

- parameter a: begin point
- parameter b: end point
- parameter t: 'time' traveled from *a* to *b*, **must** be in the closed unit interval [0,1], defaults to 0.5
- returns: An interpolation between points *a* and *b* for the 'time' parameter *t*
*/
public func lerp(a: CGPoint, _ b: CGPoint, _ t: CGFloat = 0.5) -> CGPoint
{
    // Should be return (1-t) * a + t * b
    // but this is more effective as it creates only one new CGPoint and performs minimum number of arithmetic operations
    return CGPoint(x: (1-t) * a.x + t * b.x, y: (1-t) * a.y + t * b.y)
}

/**
Linear interpolation for array of points, usefull for calculating Bézier curve points using DeCasteljau subdivision algorithm

- parameter ps: the points
- parameter t: 'time' traveled from *ps[i]* to *ps[i+1]*, **must** be in the closed unit interval [0,1], defaults to 0.5
- returns: If *ps.count < 2 ps* itself will be returned. Else an interpolation between all neighbouring points in *ps* for the 'time' parameter *t* (the resulting Array will be one shorter than  *ps*)
*/
public func lerp(ps: [CGPoint], t: CGFloat) -> [CGPoint]
{
    let count = ps.count
    
    if count < 2
    {
        return ps
    }
    
    return Array(1..<count).map( { lerp(ps[$0-1], ps[$0], t) } )
}


public func rotate(point p1:CGPoint, radians: CGFloat, around p2:CGPoint) -> CGPoint
{
    let sinTheta = sin(radians)
    let cosTheta = cos(radians)
    
    let transposedX = p1.x - p2.x
    let transposedY = p1.y - p2.y
    
    return CGPoint(x: p2.x + (transposedX * cosTheta - transposedY * sinTheta),
        y: p2.y + (transposedX * sinTheta + transposedY * cosTheta))
    
}

public func distanceFrom(p1:CGPoint, to p2:CGPoint) -> CGFloat
{
    return sqrt(pow((p2.x - p1.x), 2) + pow((p2.y - p1.y), 2))
}

public func midPoint(between p1:CGPoint, and p2:CGPoint) -> CGPoint
{
    return CGPoint(x: (p1.x + p2.x) / 2.0, y: (p1.y + p2.y) / 2.0)
}


// MARK: - Equatable

extension CGPoint//: Equatable
{
    public func isEqualTo(point: CGPoint, withPrecision precision:CGFloat) -> Bool
    {
        return  distanceTo(point) < abs(precision)
    }
    
    public func isEqualTo(point:CGPoint) -> Bool
    {
        return self == point
    }
}

//public func ==(lhs: CGPoint, rhs: CGPoint) -> Bool
//{
//    return lhs.x == rhs.x && lhs.y == rhs.y
//}

public func isEqual(p1: CGPoint, p2: CGPoint, withPrecision precision:CGFloat) -> Bool
{
    return distanceFrom(p1, to:p2) < abs(precision)
}


// MARK: - Comparable

extension CGPoint: Comparable
{
}

/// CAVEAT: first y then x comparison
public func > (p1: CGPoint, p2: CGPoint) -> Bool
{
    return (p1.y < p2.y) || ((p1.y == p2.y) && (p1.x < p2.x))
}

public func < (p1: CGPoint, p2: CGPoint) -> Bool
{
    return (p1.y > p2.y) || ((p1.y == p2.y) && (p1.x > p2.x))
}

// MARK: - Operators

public func + (p1: CGPoint, p2: CGPoint) -> CGPoint
{
    return CGPoint(x: p1.x + p2.x, y: p1.y + p2.y)
}

public func += (inout p1: CGPoint, p2: CGPoint)
{
    p1.x += p2.x
    p1.y += p2.y
}

public prefix func - (p: CGPoint) -> CGPoint
{
    return CGPoint(x: -p.x, y: -p.y)
}

public func - (p1: CGPoint, p2: CGPoint) -> CGPoint
{
    return CGPoint(x: p1.x - p2.x, y: p1.y - p2.y)
}

public func -= (inout p1: CGPoint, p2: CGPoint)
{
    p1.x -= p2.x
    p1.y -= p2.y
}

public func + (point: CGPoint, size: CGSize) -> CGPoint
{
    return CGPoint(x: point.x + size.width, y: point.y + size.height)
}

public func += (inout point: CGPoint, size: CGSize)
{
    point.x += size.width
    point.y += size.height
}

public func - (point: CGPoint, size: CGSize) -> CGPoint
{
    return CGPoint(x: point.x - size.width, y: point.y - size.height)
}

public func -= (inout point: CGPoint, size: CGSize)
{
    point.x -= size.width
    point.y -= size.height
}

public func * (factor: CGFloat, point: CGPoint) -> CGPoint
{
    return CGPoint(x: point.x * factor, y: point.y * factor)
}

public func * (point: CGPoint, factor: CGFloat) -> CGPoint
{
    return CGPoint(x: point.x * factor, y: point.y * factor)
}

public func *= (inout point: CGPoint, factor: CGFloat)
{
    point.x *= factor
    point.y *= factor
}

public func / (point: CGPoint, factor: CGFloat) -> CGPoint
{
    return CGPoint(x: point.x / factor, y: point.y / factor)
}

public func /= (inout point: CGPoint, factor: CGFloat)
{
    point.x /= factor
    point.y /= factor
}

public func * (point: CGPoint, transform: CGAffineTransform) -> CGPoint
{
    return CGPointApplyAffineTransform(point, transform)
}

public func *= (inout point: CGPoint, transform: CGAffineTransform)
{
    point = point * transform//CGPointApplyAffineTransform(point, transform)
}

// MARK: - Random

public extension CGPoint
{
    /**
    Create a random CGFloat
    - parameter center: center, defaults to (0, 0)
    - parameter lowerRadius: bounds, defaults to 0
    - parameter upperRadius: bounds
    :return: random number CGFloat
    */
    static func random(center: CGPoint = CGPointZero, lowerRadius: CGFloat = 0, upperRadius: CGFloat) -> CGPoint
    {
        let upper = max(abs(upperRadius), abs(lowerRadius))
        let lower = min(abs(upperRadius), abs(lowerRadius))
        
        let radius = CGFloat.random(lower: lower, upper: upper)
        let alpha = CGFloat.random(lower: 0, upper: 2 * π)
        
        return CGPoint(x: center.x + cos(alpha) * radius, y: center.y + sin(alpha) * radius)
    }
    
    /**
    Create a random CGFloat
    - parameter path,: bounding path for random point
    - parameter lowerRadius: bounds, defaults to 0
    - parameter upperRadius: bounds
    :return: random number CGFloat
    */
    static func random(insidePath: UIBezierPath) -> CGPoint?
    {
        let bounds = insidePath.bounds
        
        for _ in 0...100
        {
            let point =
            CGPoint(x: CGFloat.random(lower: bounds.minX, upper: bounds.maxX),
                y: CGFloat.random(lower: bounds.minY, upper: bounds.maxY))
            
            if insidePath.containsPoint(point)
            {
                return point
            }
        }
        
        return nil
    }
    
}



