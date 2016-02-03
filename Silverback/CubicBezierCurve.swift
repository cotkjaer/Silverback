//
//  CubicBezierCurve.swift
//  Silverback
//
//  Created by Christian Otkjær on 26/11/15.
//  Copyright © 2015 Christian Otkjær. All rights reserved.
//

import Foundation
import UIKit

public class CubicBezierCurve
{
    // MARK: - points
    
    var p0, p1, p2, p3: CGPoint
    
    // MARK: - coefficients
    
    var A, B, C, D, E, F, G, H : CGFloat
    
    public init(p0: CGPoint, p1: CGPoint, p2: CGPoint, p3: CGPoint)
    {
        self.p0 = p0
        self.p1 = p1
        self.p2 = p2
        self.p3 = p3
        
        A =  p3.x - 3 * p2.x + 3 * p1.x - p0.x
        B = 3 * p2.x - 6 * p1.x + 3 * p0.x
        C = 3 * p1.x - 3 * p0.x
        D = p0.x
        
        E = p3.y - 3 * p2.y + 3 * p1.y - p0.y
        F = 3 * p2.y - 6 * p1.y + 3 * p0.y
        G = 3 * p1.y - 3 * p0.y
        H = p0.y
    }
    
    // MARK: - Bézier formula
    
    /// Calculates the position of the Bézier curve at time `t` according to the definition, as a cubic polynomial
    /// paramter t: time, [0;1]
    func positionAt(t: CGFloat) -> CGPoint
    {
        let t² = t * t
        let t³ = t² * t
        
        let x = A * t³ + B * t² + C * t + D
        let y = E * t³ + F * t² + G * t + H
        
        return CGPoint(x: x, y: y)
    }
    
    /// Calculates the tangent vector for the Bézier curve at time `t`, as the derivative of the Bézier polynomial
    /// paramter t: time, [0;1]
    func tangentAt(t: CGFloat) -> CGVector
    {
        let t² = t * t
        
        let dx = 3 * A * t² + 2 * B * t + C
        let dy = 3 * E * t² + 2 * F * t + G
        
        return CGVector(dx: dx, dy: dy)
    }
    
    // MARK: - bounds
    
    public lazy var bounds : CGRect = {
        
        let minX = min(self.p0.x, self.p1.x, self.p2.x, self.p3.x)
        let minY = min(self.p0.y, self.p1.y, self.p2.y, self.p3.y)
        let maxX = max(self.p0.x, self.p1.x, self.p2.x, self.p3.x)
        let maxY = max(self.p0.y, self.p1.y, self.p2.y, self.p3.y)
        
        return CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
    }()
    
    // MARK: - convenience aliases
    
    var beginPoint : CGPoint { return p0 }
    var ctrlPoint1 : CGPoint { return p1 }
    var ctrlPoint2 : CGPoint { return p2 }
    var endPoint : CGPoint { return p3 }
    
    // MARK: - Length
    
    /// the approximated arc-length of the curve
    public var length : CGFloat { return self.positionsTangentsAndArcLengths.last?.arcLength ?? CGFloatZero }
    
    /// Table of positions, tangent-vectors, and approximated accumulated arc-lengths, used for mapping distance to time and approximate total arc-length of the curve
    /// Lazy as it may never be used, depending on what the curve is used for
    public private(set) lazy var positionsTangentsAndArcLengths : Array<(position: CGPoint, tangent: CGVector, arcLength: CGFloat)> =
    {
        // Empirical investigation has shown that 100 divisions will yield arc-length approximations with less than 0.1% error, which would be less than half a unit for a 500 units long curve.
        let divisions = 100
        
        var table = Array<(position: CGPoint, tangent: CGVector, arcLength: CGFloat)>(count: divisions + 1, repeatedValue: (CGPointZero, CGVectorZero, CGFloatZero))
        
        var lastPoint = self.positionAt(0)
        
        var length : CGFloat = 0
        
        for i in 0...divisions
        {
            let t = i / CGFloat(divisions)
            
            let point = self.positionAt(t)
            let tangent = self.tangentAt(t)
            
            length += lastPoint.distanceTo(point)
            
            table[i] = (position: point, tangent: tangent, arcLength: length)
            
            lastPoint = point
        }
        
        return table
    }()
    
    /// parameter distance: the parameterized distance, assumed to be in [0;1]
    func timeForDistance(distance: CGFloat) -> CGFloat
    {
        let lastIndex = positionsTangentsAndArcLengths.count - 1 //arcLengths.count - 1
        
        // get the target arc-length for distance parameter
        let targetArcLength = distance * length //positionsTangentsAndArcLengths[lastIndex].arcLength//arcLengths[lastIndex]
        
        // largest value smaller than targetArcLength, if none exist return time 0
        guard let (foundIndex, found) = positionsTangentsAndArcLengths.lastWhere({ $0.arcLength < targetArcLength }) else { return 0 }// arcLengths.lastWhere({ $0 <= targetArcLength }) else { return 0 }
        
        
        if found.arcLength == targetArcLength
        {
            // time based on found index
            return foundIndex / CGFloat(lastIndex)
        }
        else  // we need to interpolate between two points
        {
            let lengthBefore = found.arcLength//arcLengths[index]
            let lengthAfter = positionsTangentsAndArcLengths[foundIndex+1].arcLength//arcLengths[foundIndex+1]
            let segmentLength = lengthAfter - lengthBefore
            
            // find where we are between the 'before' and 'after' points, as a fraction
            let segmentFraction = (targetArcLength - lengthBefore) / segmentLength
            
            // approximate time by adding fraction to found index
            return (segmentFraction + foundIndex) / lastIndex
        }
    }
    
    func draw(inContext context: CGContextRef? = UIGraphicsGetCurrentContext())
    {
        CGContextSaveGState(context)
        
        UIColor.blackColor().setStroke()
        
        var path = UIBezierPath(withCubicBezierCurve: self)
        
        path.stroke()
        
        let red = UIColor.redColor()
        red.setStroke()
        red.setFill()
        
        let radius = max(3, min(distance(p0, p1), distance(p2, p3)) / 100)
        
        path = UIBezierPath()
        path.moveToPoint(p0)
        path.addLineToPoint(p1)
        path.addArcWithCenter(p1, radius: radius, startAngle: 0, endAngle: π2, clockwise: true)
        
        path.fill()
        path.stroke()
        
        path = UIBezierPath()
        path.moveToPoint(p3)
        path.addLineToPoint(p2)
        path.addArcWithCenter(p2, radius: radius, startAngle: 0, endAngle: π2, clockwise: true)
        
        path.fill()
        path.stroke()
        
        let blue = UIColor.blueColor()
        blue.setStroke()
        blue.setFill()
        
        for i in 0...20
        {
            let u = CGFloat(i) / 20
            
            let t = timeForDistance(u)
            
            let point = positionAt(t)
            
            path = UIBezierPath(rect: CGRect(center: point, size: CGSize(widthAndHeight: radius)))
            
            path.fill()
            
            let p = tangentAt(t).perpendicular(clockwise: false).normalized
            
            p.draw(atPoint: point)
        }
        
        CGContextRestoreGState(context)
    }
}

//MARK: - Warp

extension CubicBezierCurve
{
    // MARK: Text
    
    func warp(text: String, font: UIFont, textAlignment: NSTextAlignment = .Natural) -> UIBezierPath
    {
        let path = UIBezierPath(string: text, withFont: font)
        
        return warp(path, align: textAlignment)
    }
    
    public func approximateBoundsForFont(font: UIFont) -> CGRect
    {
        let decender = font.descender
        let ascender = font.ascender
        
        let points = positionsTangentsAndArcLengths.flatMap({ (position: CGPoint, tangent: CGVector, arcLength: CGFloat) -> [CGPoint] in
            let P = tangent.perpendicular(clockwise: false).normalized
            
            return [position, position + P * ascender, position + P * decender]
        })
        
        if let firstPoint = points.first
        {
            var maxX = firstPoint.x
            var minX = firstPoint.x
            
            var maxY = firstPoint.y
            var minY = firstPoint.y
            
            for p in points
            {
                maxX = max(p.x, maxX)
                maxY = max(p.y, maxY)
                
                minX = min(p.x, minX)
                minY = min(p.y, minY)
            }
            
            return CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
        }

        return CGRectZero
    }
    
    // MARK: Generic
    
    func warpPoint(point: CGPoint, width: CGFloat) -> CGPoint?
    {
        guard point.x >= 0 && point.x <= width else { return nil }
        
        let u = point.x / width //frame.maxX
        //            let t = point.x / frame.maxX
        
        let t = timeForDistance(u)
        
        let S = positionAt(t)
        
        let T = tangentAt(t)
        
        let P = point.y * CGVector(dx: -T.dy, dy: T.dx) / T.length
        
        let warpedPoint = S + P
        
        return warpedPoint
    }
    
    func warp(p: UIBezierPath, align: NSTextAlignment = .Justified) -> UIBezierPath
    {
        guard !p.elements.isEmpty else { return p }
        
        var path = p
        var width = path.bounds.maxX
        
        switch align
        {
        case .Center:
            path.applyTransform(CGAffineTransformMakeTranslation((length - path.bounds.width) / 2, 0))
            width = max(length, path.bounds.width)
            
        case .Left:
            path.applyTransform(CGAffineTransformMakeTranslation(-path.bounds.minX, 0))
            width = length
            
        case .Right:
            path.applyTransform(CGAffineTransformMakeTranslation(length - path.bounds.maxX, 0))
            width = length
            
        case .Justified:
            path.applyTransform(CGAffineTransformMakeTranslation(-path.bounds.minX, 0))
            width = path.bounds.width
            

        case .Natural:
            switch UIApplication.sharedApplication().userInterfaceLayoutDirection
            {
            case .LeftToRight:
                path.applyTransform(CGAffineTransformMakeTranslation(-path.bounds.minX, 0))
                width = length
                
            case .RightToLeft:
                path.applyTransform(CGAffineTransformMakeTranslation(length - path.bounds.maxX, 0))
                width = length
            }
        }
        
        let frame = path.bounds
        
        func warpPoint(point: CGPoint) -> CGPoint?
        {
            return self.warpPoint(point, width: width)
        }
        
        var subPathBeginPoint = CGPointZero
        var beginPoint = CGPointZero
        
        let warpedPath : UIBezierPath = UIBezierPath()
        
        for element in path.elements
        {
            switch element
            {
            case .MoveToPoint(let point):
                
                if let warpedPoint = warpPoint(point)
                {
                    subPathBeginPoint = point
                    beginPoint = point
                    
                    warpedPath.moveToPoint(warpedPoint)
                }
                
            case .AddLineToPoint(let endPoint):
                
                if let warpedCtrlPoint1 = warpPoint((2 * beginPoint + endPoint) / 3)
                    , let warpedCtrlPoint2 = warpPoint((beginPoint + 2 * endPoint) / 3)
                    , let warpedEndPoint = warpPoint(endPoint)
                {
                    
                    beginPoint = endPoint
                    
                    warpedPath.addCurveToPoint(warpedEndPoint, controlPoint1: warpedCtrlPoint1, controlPoint2: warpedCtrlPoint2)
                }
                
            case .AddQuadCurveToPoint(let ctrlPoint, let endPoint):
                
                if let warpedCtrlPoint1 = warpPoint((2 * ctrlPoint + beginPoint) / 3)
                    , let warpedCtrlPoint2 = warpPoint((2 * ctrlPoint + endPoint) / 3)
                    , let warpedEndPoint = warpPoint(endPoint)
                {
                    beginPoint = endPoint
                    
                    warpedPath.addCurveToPoint(warpedEndPoint, controlPoint1: warpedCtrlPoint1, controlPoint2: warpedCtrlPoint2)
                }
                
            case .AddCurveToPoint(let ctrlPoint1, let ctrlPoint2, let endPoint):
                
                if let warpedCtrlPoint1 = warpPoint(ctrlPoint1)
                    , let warpedCtrlPoint2 = warpPoint(ctrlPoint2)
                    , let warpedEndPoint = warpPoint(endPoint)
                {
                    beginPoint = endPoint
                    
                    warpedPath.addCurveToPoint(warpedEndPoint, controlPoint1: warpedCtrlPoint1, controlPoint2: warpedCtrlPoint2)
                }
                
            case .CloseSubpath:
                
                let endPoint = subPathBeginPoint
                
                if endPoint != beginPoint
                {
                    if let warpedCtrlPoint1 = warpPoint((2 * beginPoint + endPoint) / 3)
                        , let warpedCtrlPoint2 = warpPoint((beginPoint + 2 * endPoint) / 3)
                        , let warpedEndPoint = warpPoint(endPoint)
                    {
                        warpedPath.addCurveToPoint(warpedEndPoint, controlPoint1: warpedCtrlPoint1, controlPoint2: warpedCtrlPoint2)
                    }
                }
                
                warpedPath.closePath()
                
                beginPoint = CGPointZero
                subPathBeginPoint = CGPointZero
            }
        }
        
        return warpedPath
    }
}