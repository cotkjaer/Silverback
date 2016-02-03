//
//  Curve.swift
//  Silverback
//
//  Created by Christian Otkjær on 25/11/15.
//  Copyright © 2015 Christian Otkjær. All rights reserved.
//

import UIKit
/*
public protocol GraphicsCurve
{
    var beginPoint : CGPoint { get }
    var endPoint : CGPoint { get }
    var length : CGFloat { get }
    
    init?(points: Array<CGPoint>)
    
    func splitAt(t: CGFloat) -> (GraphicsCurve, GraphicsCurve)
    
    func pointAt(t: CGFloat) -> CGPoint
    
    func angleAt(t: CGFloat) -> CGFloat
}

class GraphicsCurvePoint: GraphicsCurve
{
    var point = CGPointZero
    
    required init?(points: Array<CGPoint>)
    {
        guard let point = points.first else { return nil }
        
        self.point = point
    }
    
    init(point: CGPoint)
    {
        self.point = point
    }
    
    var beginPoint : CGPoint { return point }

    var endPoint : CGPoint { return point }
    
    var length : CGFloat { return 0 }
    
    func splitAt(t: CGFloat) -> (GraphicsCurve, GraphicsCurve)
    {
        return (GraphicsCurvePoint(point: point), GraphicsCurvePoint(point: point))
    }
    
    func pointAt(t: CGFloat) -> CGPoint
    {
        return point
    }
    
    func angleAt(t: CGFloat) -> CGFloat
    {
        return 0
    }
}

class GraphicsCurvePoint: GraphicsCurve
{
    let point: CGPoint
    
    init(point: CGPoint)
    {
        self.point = point
    }
    
    var beginPoint : CGPoint { return point }
    
    var endPoint : CGPoint { return point }
    
    var length : CGFloat { return 0 }
    
    func splitAt(t: CGFloat) -> (GraphicsCurve, GraphicsCurve)
    {
        return (GraphicsCurvePoint(point: point), GraphicsCurvePoint(point: point))
    }
    
    func pointAt(t: CGFloat) -> CGPoint
    {
        return point
    }
    
    func angleAt(t: CGFloat) -> CGFloat
    {
        return 0
    }
}
*/