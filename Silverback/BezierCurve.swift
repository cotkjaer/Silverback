//
//  BezierCurve.swift
//  Silverback
//
//  Created by Christian Otkjær on 24/11/15.
//  Copyright © 2015 Christian Otkjær. All rights reserved.
//

import UIKit

public class BezierCurve
{
    private let order : BezierCurveEnum
    
    public let beginPoint : CGPoint
    
    public let endPoint : CGPoint
    
    public lazy var length : CGFloat = { return self.order.lengthWithThreshold(CGFloat(1) / UIScreen.mainScreen().scale) }()

    // MARK: - Init
    
    convenience init(points:[CGPoint])
    {
        self.init(order: BezierCurveEnum(points: points))
    }
    
    private init(order: BezierCurveEnum)
    {
        self.order = order
        self.endPoint = order.endPoint
        self.beginPoint = order.beginPoint
    }
    
    public func split(at t: CGFloat = 0.5) -> (BezierCurve, BezierCurve)
    {
        let parts = order.splitAt(t)
        
        return (BezierCurve(order: parts.0), BezierCurve(order: parts.1))
    }
    
    public func pointAt(t: CGFloat) -> CGPoint
    {
        return order.pointAt(t)
    }
    
    public func angleAt(t: CGFloat) -> CGFloat
    {
        return order.angleAt(t)
    }
}

enum BezierCurveEnum
{
    case Point(CGPoint)
    case Liniar(CGPoint, CGPoint)
    case Quadratic(CGPoint, CGPoint, CGPoint)
    case Cubic(CGPoint, CGPoint, CGPoint, CGPoint)
    case Generic([CGPoint])
    
    init(points:[CGPoint])
    {
        switch points.count
        {
        case 1: self = .Point(points[0])
        case 2: self = .Liniar(points[0], points[1])
        case 3: self = .Quadratic(points[0], points[1], points[2])
        case 4: self = .Cubic(points[0], points[1], points[2], points[3])
        default: self = .Generic(points)
        }
    }
    
    func splitAt(t: CGFloat = 0.5) -> (BezierCurveEnum, BezierCurveEnum)
    {
        switch self
        {
        case let .Point(p):
            return (.Point(p), .Point(p))
            
        case let .Liniar(a, b):
            let ab = lerp(a,b,t)           // point between a and b
            return (.Liniar(a, ab), .Liniar(ab, b))
            
        case let .Quadratic(a,b,c):
            let ab = lerp(a,b,t)           // point between a and b
            let bc = lerp(b,c,t)           // point between b and c
            
            let ab_bc = lerp(ab,bc,t)       // point between ab and bc
            
            return (.Quadratic(a, ab, ab_bc), .Quadratic(ab_bc, bc, c))
            
        case let .Cubic(a,b,c,d):
            let ab = lerp(a,b,t)           // point between a and b
            let bc = lerp(b,c,t)           // point between b and c
            let cd = lerp(c,d,t)           // point between c and d
            
            let ab_bc = lerp(ab,bc,t)       // point between ab and bc
            let bc_cd = lerp(bc,cd,t)       // point between bc and cd
            
            let abbc_bccd = lerp(ab_bc,bc_cd,t) // point between ab_bc and bc_cd
            
            return (.Cubic(a, ab, ab_bc, abbc_bccd), .Cubic(abbc_bccd, bc_cd, cd, d))
            
        case let .Generic(ps):
            fatalError("TODO: implement spilt for curve of order \(ps.count)")
        }
    }
    
    func pointAt(t: CGFloat) -> CGPoint
    {
        switch self
        {
        case let .Point(p):
            return p
            
        case let .Liniar(a, b):
            return lerp(a,b,t)           // point between a and b
            
        case let .Quadratic(a,b,c):
            let ab = lerp(a,b,t)           // point between a and b
            let bc = lerp(b,c,t)           // point between b and c
            
            return lerp(ab,bc,t)       // point between ab and bc
            
        case let .Cubic(a,b,c,d):
            let ab = lerp(a,b,t)           // point between a and b
            let bc = lerp(b,c,t)           // point between b and c
            let cd = lerp(c,d,t)           // point between c and d
            
            let ab_bc = lerp(ab,bc,t)       // point between ab and bc
            let bc_cd = lerp(bc,cd,t)       // point between bc and cd
            
            return lerp(ab_bc,bc_cd,t) // point between ab_bc and bc_cd
            
        case let .Generic(points):
            
            var ps = points
            
            while ps.count > 2
            {
                ps = lerp(ps, t)
            }
            
            return lerp(ps.first ?? CGPointZero, ps.last ?? CGPointZero, t)
            
//            fatalError("TODO: implement pointAt for curve of order \(points.count)")
        }
    }
    
    
    func angleAt(t: CGFloat) -> CGFloat
    {
        switch self
        {
        case let .Point(p):
            return CGPointZero.angleToPoint(p)
            
        case let .Liniar(a, b):
            return a.angleToPoint(b)
            
        case let .Quadratic(a,b,c):
            let ab = lerp(a,b,t)           // point between a and b
            let bc = lerp(b,c,t)           // point between b and c
            
            return ab.angleToPoint(bc)
            
        case let .Cubic(a,b,c,d):
            let ab = lerp(a,b,t)           // point between a and b
            let bc = lerp(b,c,t)           // point between b and c
            let cd = lerp(c,d,t)           // point between c and d
            
            let ab_bc = lerp(ab,bc,t)       // point between ab and bc
            let bc_cd = lerp(bc,cd,t)       // point between bc and cd
            
            return ab_bc.angleToPoint(bc_cd)
            
        case let .Generic(points):
            var ps = points
            
            while ps.count > 2
            {
                ps = lerp(ps, t)
            }
            
            return (ps.first ?? CGPointZero).angleToPoint(ps.last ?? CGPointZero)
            }
    }
    
    var endPoint : CGPoint
        {
            switch self
            {
            case let .Point(point): return point
                
            case let .Liniar(_, endPoint): return endPoint
                
            case let .Quadratic(_, _, endPoint): return endPoint
                
            case let .Cubic(_, _, _, endPoint): return endPoint
                
            case let .Generic(ps) : return ps.last ?? CGPointZero
            }
    }
    
    var beginPoint : CGPoint
        {
            switch self
            {
            case let .Point(point): return point
                
            case let .Liniar(point, _): return point
                
            case let .Quadratic(point, _, _): return point
                
            case let .Cubic(point, _, _, _): return point
                
            case let .Generic(points) : return points.first ?? CGPointZero
                
            }
    }
    
    func lengthWithThreshold(threshold: CGFloat) -> CGFloat
    {
        let d = distance(beginPoint, endPoint)
        
        if d < threshold
        {
            return d
        }
        
        let parts = splitAt()
        return parts.0.lengthWithThreshold(threshold) + parts.1.lengthWithThreshold(threshold)
    }
    
    var length : CGFloat { return lengthWithThreshold(CGFloat(1) / UIScreen.mainScreen().scale) }
}
