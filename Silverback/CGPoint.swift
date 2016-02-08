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
    // MARK: init
    
    public init(x: CGFloat)
    {
        self.init(x:x, y:0)
    }
    
    public init(y: CGFloat)
    {
        self.init(x:0, y:y)
    }

    public init(size: CGSize)
    {
        self.init(x:size.width, y:size.height)
    }

    // MARK: clamp
    
    func clampedTo(rect: CGRect) -> CGPoint
    {
        return CGPoint(
            x: clamp(x, minimum: rect.minX, maximum: rect.maxX),
            y: clamp(y, minimum: rect.minY, maximum: rect.maxY)
        )
    }
    
    // MARK: map
    
    func map(transform: CGFloat -> CGFloat) -> CGPoint
    {
        return CGPoint(x: transform(x), y: transform(y))
    }
    
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
    public mutating func rotate(theta:CGFloat, around center:CGPoint = CGPointZero)
    {
        let sinTheta = sin(theta)
        let cosTheta = cos(theta)
        
        let transposedX = x - center.x
        let transposedY = y - center.y
        
        x = center.x + (transposedX * cosTheta - transposedY * sinTheta)
        y = center.y + (transposedX * sinTheta + transposedY * cosTheta)
    }

    /// angle is in radians
    public func rotated(theta:CGFloat, around center:CGPoint) -> CGPoint
    {
        return (self - center).rotated(theta) + center
    }
    
    /// angle is in radians
    public func rotated(theta:CGFloat) -> CGPoint
    {
        let sinTheta = sin(theta)
        let cosTheta = cos(theta)
        
        return CGPoint(x: x * cosTheta - y * sinTheta, y: x * sinTheta + y * cosTheta)
    }
    
    public func angleToPoint(point: CGPoint) -> CGFloat
    {
        return atan2(point.y - y, point.x - x)
    }
}

//MARK: - Convert
import UIKit
extension CGPoint
{
    public func convert(fromView fromView: UIView? = nil, toView: UIView) -> CGPoint
    {
        return toView.convertPoint(self, fromView: fromView)
    }
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

public func - (p1: CGPoint, p2: CGPoint?) -> CGPoint
{
    return p1 - (p2 ?? CGPointZero)
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


public func + (point: CGPoint, vector: CGVector) -> CGPoint
{
    return CGPoint(x: point.x + vector.dx, y: point.y + vector.dy)
}

public func += (inout point: CGPoint, vector: CGVector)
{
    point.x += vector.dx
    point.y += vector.dy
}

public func - (point: CGPoint, vector: CGVector) -> CGPoint
{
    return CGPoint(x: point.x - vector.dx, y: point.y - vector.dy)
}

public func -= (inout point: CGPoint, vector: CGVector)
{
    point.x -= vector.dx
    point.y -= vector.dy
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

//MARK: - Round

public func round(point: CGPoint, toDecimals: Int = 0) -> CGPoint
{
    let decimals = max(0, toDecimals)
    
    if decimals == 0
    {
        return CGPoint(x: round(point.x), y: round(point.y))
    }
    else
    {
        let factor = pow(10, CGFloat(max(decimals, 0)))
        
        return CGPoint(x: round(point.x * factor) / factor, y: round(point.y * factor) / factor)
    }
}

// MARK: - Tuples

public extension CGPoint
{
    init(_ tuple: (CGFloat, CGFloat))
    {
        (x, y) = tuple
    }
    
    var tuple: (CGFloat, CGFloat) { return (x, y) }
}

//MARK: - Zero

extension CGPoint
{
    static let zero = CGPointZero
    
    func isZero() -> Bool { return x == 0 && y == 0 }
}

// MARK: - Trigonometry

public func dotProduct(a: CGPoint, _ b: CGPoint) -> CGFloat {
    return a.x * b.x + a.y * b.y
}

public func dot(a: CGPoint, _ b: CGPoint) -> CGFloat
{
    return a.x * b.x + a.y * b.y
}

public func · (lhs: CGPoint, _ rhs: CGPoint) -> CGFloat {
    return lhs.x * rhs.x + lhs.y * rhs.y
}

public func distance(a: CGPoint, _ b: CGPoint) -> CGFloat
{
    return a.distanceTo(b)
}

public func distanceSquared(a: CGPoint, _ b: CGPoint) -> CGFloat
{
    return pow(a.x - b.x, 2) + pow(a.y - b.y, 2)
}


public func x(lhs: CGPoint, _ rhs: CGPoint) -> CGFloat
{
    return lhs.x * rhs.y - lhs.y * rhs.x
}

public func cross(lhs: CGPoint, _ rhs: CGPoint) -> CGFloat
{
    return lhs.x * rhs.y - lhs.y * rhs.x
}

public func crossProduct(lhs: CGPoint, _ rhs: CGPoint) -> CGFloat
{
    return lhs.x * rhs.y - lhs.y * rhs.x
}

public extension CGPoint
{
    init(magnitude: CGFloat, direction: CGFloat) {
        x = cos(direction) * magnitude
        y = sin(direction) * magnitude
    }
    
    var magnitude: CGFloat {
        get {
            return sqrt(x * x + y * y)
        }
        set(v) {
            self = CGPoint(magnitude: v, direction: direction)
        }
    }
    
    var magnitudeSquared: CGFloat {
        return x * x + y * y
    }
    
    var direction: CGFloat {
        get {
            return atan2(self)
        }
        set(v) {
            self = CGPoint(magnitude: magnitude, direction: v)
        }
    }
    
    var normalized: CGPoint {
        let len = magnitude
        return len ==% 0 ? self : CGPoint(x: x / len, y: y / len)
    }
    
    var orthogonal: CGPoint {
        return CGPoint(x: -y, y: x)
    }
    
    var transposed: CGPoint {
        return CGPoint(x: y, y: x)
    }
    
}

public func atan2(point: CGPoint) -> CGFloat {   // (-M_PI, M_PI]
    return atan2(point.y, point.x)
}

// MARK: - Translate

extension CGPoint
{
    public mutating func translate(dx: CGFloat? = nil, dy: CGFloat? = nil)
    {
        if let delta = dx
        {
            x += delta
        }
        
        if let delta = dy
        {
            y += delta
        }
    }
    
    public func translated(dx: CGFloat? = nil, dy: CGFloat? = nil) -> CGPoint
    {
        var p = CGPoint(x: x, y: y)
        
        if let delta = dx
        {
            p.x += delta
        }
        
        if let delta = dy
        {
            p.y += delta
        }
        
        return p
    }
}

