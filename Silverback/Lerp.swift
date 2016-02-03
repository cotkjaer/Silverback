//
//  Lerp.swift
//  Silverback
//
//  Created by Christian Otkjær on 14/12/15.
//  Copyright © 2015 Christian Otkjær. All rights reserved.
//
import CoreGraphics


public protocol Lerpable : Addable
{
    typealias FactorType
    
    func * (lhs: Self, rhs: FactorType) -> Self
}

/// Precise generic linear interpolation function which guarantees 
///```swift
///lerp(a,b,0) == a && lerp(a,b,1) == b
public func lerp <L: Lerpable, F: Subtractable where F: FloatLiteralConvertible, F == L.FactorType> (lower: L, _ upper: L, _ factor: F) -> L
{
    return lower * (1.0 - factor) + upper * factor
}

///Linear interpolation for array of Lerpables
public func lerp <L: Lerpable, F: Subtractable where F: FloatLiteralConvertible, F == L.FactorType>(lerpables: [L], _ factor: F) -> [L]
{
    let count = lerpables.count
    
    guard count > 1 else { return lerpables }
    
    return 1.stride(to: count, by: 1).map { i in lerp(lerpables[i - 1], lerpables[i], factor) }
}

extension Double: Lerpable
{
    public typealias FactorType = Double
}

extension CGFloat: Lerpable
{
    public typealias FactorType = CGFloat
}

extension CGPoint: Lerpable
{
    public typealias FactorType = CGFloat
}

///**
// Precise linear interpolation function which guarantees *lerp(a,b,0) == a && lerp(a,b,1) == b*
// 
// - parameter a: begin point
// - parameter b: end point
// - parameter t: 'time' traveled from *a* to *b*, **must** be in the closed unit interval [0,1], defaults to 0.5
// - returns: An interpolation between points *a* and *b* for the 'time' parameter *t*
// */
//public func lerp(a: CGPoint, _ b: CGPoint, _ t: CGFloat = 0.5) -> CGPoint
//{
//    return CGPoint(x: lerp(a.x, b.x, t), y: lerp(a.y,b.y,t))
//}

extension CGSize: Lerpable
{
    public typealias FactorType = CGFloat
}

public func lerp(lower: CGRect, _ upper: CGRect, _ factor: CGFloat) -> CGRect
{
    return CGRect(
        origin: lerp(lower.origin, upper.origin, factor),
        size: lerp(lower.size, upper.size, factor)
    )
}