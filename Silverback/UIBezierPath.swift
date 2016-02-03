//
//  UIBezierPath.swift
//  Silverback
//
//  Created by Christian Otkjær on 22/10/15.
//  Copyright © 2015 Christian Otkjær. All rights reserved.
//

import UIKit

// MARK: - Elements

/// A Swiftified representation of a `CGPathElement`
///
/// Simpler and safer than `CGPathElement` because it doesn’t use a
/// C array for the associated points.
public enum PathElement
{
    case MoveToPoint(CGPoint)
    case AddLineToPoint(CGPoint)
    case AddQuadCurveToPoint(CGPoint, CGPoint)
    case AddCurveToPoint(CGPoint, CGPoint, CGPoint)
    case CloseSubpath
    
    init(element: CGPathElement)
    {
        switch element.type
        {
        case .MoveToPoint:
            self = .MoveToPoint(element.points[0])
        case .AddLineToPoint:
            self = .AddLineToPoint(element.points[0])
        case .AddQuadCurveToPoint:
            self = .AddQuadCurveToPoint(element.points[0], element.points[1])
        case .AddCurveToPoint:
            self = .AddCurveToPoint(element.points[0], element.points[1], element.points[2])
        case .CloseSubpath:
            self = .CloseSubpath
        }
    }
}

extension PathElement : CustomDebugStringConvertible
{
    public var debugDescription: String
        {
            switch self
            {
            case let .MoveToPoint(point):
                return "\(point.x) \(point.y) moveto"
            case let .AddLineToPoint(point):
                return "\(point.x) \(point.y) lineto"
            case let .AddQuadCurveToPoint(point1, point2):
                return "\(point1.x) \(point1.y) \(point2.x) \(point2.y) quadcurveto"
            case let .AddCurveToPoint(point1, point2, point3):
                return "\(point1.x) \(point1.y) \(point2.x) \(point2.y) \(point3.x) \(point3.y) curveto"
            case .CloseSubpath:
                return "closepath"
            }
    }
}

extension PathElement : Equatable { }

public func == (lhs: PathElement, rhs: PathElement) -> Bool
{
    switch(lhs, rhs) {
    case let (.MoveToPoint(l), .MoveToPoint(r)):
        return l == r
    case let (.AddLineToPoint(l), .AddLineToPoint(r)):
        return l == r
    case let (.AddQuadCurveToPoint(l1, l2), .AddQuadCurveToPoint(r1, r2)):
        return l1 == r1 && l2 == r2
    case let (.AddCurveToPoint(l1, l2, l3), .AddCurveToPoint(r1, r2, r3)):
        return l1 == r1 && l2 == r2 && l3 == r3
    case (.CloseSubpath, .CloseSubpath):
        return true
    case (_, _):
        return false
    }
}

extension UIBezierPath
{
    var elements: [PathElement]
        {
            var pathElements = [PathElement]()
            withUnsafeMutablePointer(&pathElements)
                { elementsPointer in
                    CGPathApply(CGPath, elementsPointer)
                        { (userInfo, nextElementPointer) in
                            let nextElement = PathElement(element: nextElementPointer.memory)
                            let elementsPointer = UnsafeMutablePointer<[PathElement]>(userInfo)
                            elementsPointer.memory.append(nextElement)
                    }
            }
            return pathElements
    }
}

extension UIBezierPath : SequenceType
{
    public func generate() -> AnyGenerator<PathElement>
    {
        return anyGenerator(elements.generate())
    }
}

extension UIBezierPath : CustomDebugStringConvertible
{
    public override var debugDescription: String
        {
            let cgPath = self.CGPath
            let bounds = CGPathGetPathBoundingBox(cgPath)
            let controlPointBounds = CGPathGetBoundingBox(cgPath)
            
            return (["\(self.dynamicType)", "bounds: \(bounds)", "control-point bounds: \(controlPointBounds)"] + elements.map({ $0.debugDescription })).joinWithSeparator(",\n     ")
    }
}

//MARK: - Init Elements

extension UIBezierPath
{
    public convenience init(elements: [PathElement])
    {
        self.init()
        
        for element in elements
        {
            switch element
            {
            case let .MoveToPoint(point):
                moveToPoint(point)
                
            case .CloseSubpath:
                closePath()
                
            case let .AddLineToPoint(point):
                addLineToPoint(point)
                
            case let .AddQuadCurveToPoint(ctrlPoint, endPoint):
                addQuadCurveToPoint(endPoint, controlPoint: ctrlPoint)
                
            case let .AddCurveToPoint(ctrlPoint1, ctrlPoint2, endPoint):
                addCurveToPoint(endPoint, controlPoint1: ctrlPoint1, controlPoint2: ctrlPoint2)
                
            }
        }
    }
}


//MARK: - Text

extension UIBezierPath
{
    public convenience init(attributedString: NSAttributedString)
    {
        self.init(CGPath: CGPathCreateSingleLineStringWithAttributedString(attributedString))
    }
    
    convenience init(string: String, withFont font: UIFont)
    {
        self.init(attributedString: NSAttributedString(string: string, attributes: [NSFontAttributeName : font]))
    }
}

//MARK: - Image

extension UIBezierPath
{
    func image(strokeColor: UIColor = UIColor.blackColor(), fillColor: UIColor = UIColor.clearColor(), lineWidth: CGFloat = 1, backgroundColor: UIColor? = nil) -> UIImage
    {
        let frame = bounds.insetBy(dx: -lineWidth, dy: -lineWidth).integral
        
        let path = self
        
        path.applyTransform(CGAffineTransformMakeTranslation(1 - frame.minX, -frame.size.height - frame.minY))
        path.applyTransform(CGAffineTransformMakeScale(1, -1))
        
        UIGraphicsBeginImageContextWithOptions(frame.size, false, 0); defer { UIGraphicsEndImageContext() }
        
        if let bgColor = backgroundColor
        {
            let bgPath = UIBezierPath(rect: path.bounds)
            
            bgColor.setFill()
            
            bgPath.fill()
        }
        
        //        if let context = UIGraphicsGetCurrentContext()
        //        {
        //            // Flip the context coordinates in iOS only.
        //            CGContextTranslateCTM(context, 0, size.height)
        //            CGContextScaleCTM(context, 1, -1)
        
        fillColor.setFill()
        strokeColor.setStroke()
        
        path.fill()
        path.stroke()
        //        }
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}

// MARK: - Cubic Bezier Curves

extension UIBezierPath
{
    public func cubicBezierCurves() -> [CubicBezierCurve]
    {
        var curves = Array<CubicBezierCurve>()
        
        var subPathBeginPoint = CGPointZero
        var beginPoint = CGPointZero
        
        for element in elements
        {
            switch element
            {
            case .MoveToPoint(let point):
                
                subPathBeginPoint = point
                beginPoint = point
                
                
            case .AddLineToPoint(let endPoint):
                
                let ctrlPoint1 = (2 * beginPoint + endPoint) / 3
                let ctrlPoint2 = (beginPoint + 2 * endPoint) / 3
                
                curves.append(CubicBezierCurve(p0: beginPoint, p1: ctrlPoint1, p2: ctrlPoint2, p3: endPoint))
                
                beginPoint = endPoint
                
                
            case .AddQuadCurveToPoint(let ctrlPoint, let endPoint):
                
                // A quadratic Bezier curve can be always represented by a cubic one by applying the degree elevation algorithm. The resulting cubic representation will share its anchor points with the original quadratic, while the control points will be at 2/3 of the quadratic handle segments:
                let ctrlPoint1 = (2 * ctrlPoint + beginPoint) / 3
                let ctrlPoint2 = (2 * ctrlPoint + endPoint) / 3
                
                curves.append(CubicBezierCurve(p0: beginPoint, p1: ctrlPoint1, p2: ctrlPoint2, p3: endPoint))
                
                beginPoint = endPoint
                
            case .AddCurveToPoint(let ctrlPoint1, let ctrlPoint2, let endPoint):
                
                curves.append(CubicBezierCurve(p0: beginPoint, p1: ctrlPoint1, p2: ctrlPoint2, p3: endPoint))
                
                beginPoint = endPoint
                
                
            case .CloseSubpath:
                
                let endPoint = subPathBeginPoint
                
                let ctrlPoint1 = (2 * beginPoint + endPoint) / 3
                let ctrlPoint2 = (beginPoint + 2 * endPoint) / 3
                
                curves.append(CubicBezierCurve(p0: beginPoint, p1: ctrlPoint1, p2: ctrlPoint2, p3: endPoint))
                
                beginPoint = CGPointZero
                subPathBeginPoint = CGPointZero
                
            }
        }
        
        return curves
    }
}

//MARK: - Warp

extension UIBezierPath
{
    // MARK: Text
    
    public func warp(text: String, font: UIFont, textAlignment: NSTextAlignment = .Natural) -> UIBezierPath
    {
        let path = UIBezierPath(string: text, withFont: font)
        
        return warp(path, align: textAlignment)
    }
    
    public func approximateBoundsForFont(font: UIFont) -> CGRect
    {
        let curves = cubicBezierCurves()
        
        let bounds = curves.map{ $0.approximateBoundsForFont(font) }
        
        guard let firstBounds = bounds.first else { return CGRectZero }
        
        return bounds.reduce(firstBounds) { return $0.union($1) }
    }
    
    // MARK: Generic
    
    private func handleAlignment(path: UIBezierPath, length: CGFloat, alignment: NSTextAlignment) -> CGFloat
    {
        // MARK alignment
        
        var width = CGFloatZero
        
        switch alignment
        {
        case .Center:
            width = max(length, path.bounds.width)
            path.applyTransform(CGAffineTransformMakeTranslation((width - path.bounds.width) / 2, 0))
            
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
        
        return width
    }
    
    private func warp(path: UIBezierPath, align: NSTextAlignment = .Justified) -> UIBezierPath
    {
        let curves = cubicBezierCurves()
        
        guard let firstCurve = curves.first else { return UIBezierPath() }
        
        let length = curves.reduce(0) { $0 + $1.length }
        
        var curveLength = CGFloatZero
        
        var distances = Array<CGFloat>()
        
        for curve in curves
        {
            distances.append(curveLength / length)
            
            curveLength += curve.length
        }
        
        distances.append(1)
        
        let width = handleAlignment(path, length: length, alignment: align)
        
        func warpPoint(point: CGPoint) -> CGPoint?
        {
            guard point.x >= 0 && point.x <= width else { return nil }
            
            let distanceOnPath = point.x / width
            
            let (index, distanceAtCurveStart) = distances.lastWhere{ $0 < distanceOnPath } ?? (0, 0)
            
            if let curve = curves.get(index), let distanceAtCurveEnd = distances.get(index + 1)
            {
                let distanceSpan = distanceAtCurveEnd - distanceAtCurveStart
                
                let distance = (distanceOnPath - distanceAtCurveStart) / distanceSpan
                
                //                let distance = (point.x - length) / curve.length
                
                //                let u = point.x / width
                
                let time = curve.timeForDistance(distance)
                
                let curvePosition = curve.positionAt(time)
                
                let perpendicular = curve.tangentAt(time).perpendicular(clockwise: false).normalized
                
                let warpedPoint = curvePosition + perpendicular * point.y
                
                return warpedPoint
            }
            
            return nil
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

//MARK: - Cubic Bezier Curves

extension UIBezierPath
{
    public convenience init(withCubicBezierCurve c: CubicBezierCurve)
    {
        self.init()
        
        moveToPoint(c.beginPoint)
        addCurveToPoint(c.endPoint, controlPoint1: c.ctrlPoint1, controlPoint2: c.ctrlPoint2)
    }
    
    public convenience init(withCubicBezierCurve p0: CGPoint, p1: CGPoint, p2: CGPoint, p3: CGPoint)
    {
        self.init()
        
        moveToPoint(p0)
        addCurveToPoint(p3, controlPoint1: p1, controlPoint2: p2)
    }
}


//MARK: - Transform

extension UIBezierPath
{
    public func translate(tx: CGFloat, ty: CGFloat)
    {
        applyTransform(CGAffineTransformMakeTranslation(tx, ty))
    }
    
    public func translate(v: CGVector)
    {
        applyTransform(CGAffineTransformMakeTranslation(v.dx, v.dy))
    }
    
    public func rotate(angle: CGFloat)
    {
        applyTransform(CGAffineTransformMakeRotation(angle))
    }
    
    public func scale(sx: CGFloat, sy: CGFloat)
    {
        applyTransform(CGAffineTransformMakeScale(sx, sy))
    }
}

//MARK: - Drop

extension UIBezierPath
{
    public convenience init(dropWithCenter center: CGPoint, radius: CGFloat)
    {
        self.init()
        
        let topPoint = CGPoint(x: 0, y: radius * 2)
        
        let topCtrlPoint = CGPoint(x: 0, y: radius)
        
        let leftCtrlPoint = CGPoint(x: -radius, y: radius * 0.75)
        let rightCtrlPoint = CGPoint(x: radius, y: radius * 0.75)
        
        moveToPoint(topPoint)
        
        addCurveToPoint(CGPoint(x: -radius, y: 0), controlPoint1: topCtrlPoint, controlPoint2: leftCtrlPoint)
        
        addArcWithCenter(CGPointZero, radius: radius, startAngle: π, endAngle: 0, clockwise: true)
        
        addCurveToPoint(topPoint, controlPoint1: rightCtrlPoint, controlPoint2: topCtrlPoint)
        
        closePath()
        
        applyTransform(CGAffineTransformMakeTranslation(center.x, center.y))
    }
    
    public func addDrop(center: CGPoint, radius: CGFloat)
    {
        appendPath(UIBezierPath(dropWithCenter: center, radius: radius))
    }
    
    /*
    func drop(radius: CGFloat) -> UIBezierPath
    {
    let topPoint = CGPoint(x: 0, y: radius * 2)
    
    let topCtrlPoint = CGPoint(x: 0, y: radius)
    
    let leftCtrlPoint = CGPoint(x: -radius, y: radius * 0.75)
    let rightCtrlPoint = CGPoint(x: radius, y: radius * 0.75)
    
    let drop = UIBezierPath()
    
    
    drop.moveToPoint(topPoint)
    
    drop.addCurveToPoint(CGPoint(x: -radius, y: 0), controlPoint1: topCtrlPoint, controlPoint2: leftCtrlPoint)
    
    drop.addArcWithCenter(CGPointZero, radius: radius, startAngle: π, endAngle: 0, clockwise: true)
    
    drop.addCurveToPoint(topPoint, controlPoint1: rightCtrlPoint, controlPoint2: topCtrlPoint)
    
    drop.closePath()
    
    return drop
    }
    
    */
}

//MARK: - Star

extension UIBezierPath
{
    public convenience init(starWithCenter center: CGPoint,
        innerRadius: CGFloat,
        outerRadius: CGFloat,
        spikes: Int)
    {
        self.init()
        
        guard spikes > 2 else { return }
        
        let angle = π / CGFloat(spikes)
        
        var radius = (outerRadius, innerRadius)
        
        moveToPoint(CGPoint(x: radius.0, y: 0))
        
        for _ in 0..<spikes*2
        {
            applyTransform(CGAffineTransformMakeRotation(angle))
            
            swap(&radius.0, &radius.1)
            
            addLineToPoint(CGPoint(x: radius.0, y: 0))
        }
        
        applyTransform(CGAffineTransformMakeTranslation(center.x, center.y))
        
        closePath()
    }
    
    public func addStar(center: CGPoint,
        innerRadius: CGFloat,
        outerRadius: CGFloat,
        spikes: Int)
    {
        appendPath(UIBezierPath(starWithCenter: center, innerRadius: innerRadius, outerRadius: outerRadius, spikes: spikes))
    }
}

//MARK: - Spiral

extension UIBezierPath
{
    func addArchimedeanSpiral(
        center: CGPoint,
        innerRadius: CGFloat,
        outerRadius: CGFloat,
        clockwise: Bool,
        inToOut: Bool,
        loops : CGFloat)
    {
        let spiral = UIBezierPath()
        
        let a = innerRadius
        let b = outerRadius - innerRadius
        
        var phiStep = π/2
        
        var lastPointAdded = CGPoint(x: a, y: 0)
        
        spiral.moveToPoint(lastPointAdded)
        
        for var phi: CGFloat = 0; phi < loops * π2; phi += phiStep
        {
            let c = a + b * phi / (loops * π2)
            
            let point = CGPoint(x: cos(phi) * c, y: sin(phi) * c)
            
            if pow(point.x - lastPointAdded.x,2) + pow(point.y - lastPointAdded.y,2) > c
            {
                phi -= phiStep
                phiStep /= 2
            }
            else
            {
                lastPointAdded = point
                spiral.addLineToPoint(point)
            }
        }
        
        spiral.applyTransform(CGAffineTransformMakeTranslation(center.x, center.y))
        
        appendPath(spiral)
    }
    
}

//MARK: - Cresent

extension UIBezierPath
{
    public func addCresentWithCenter(center: CGPoint, radius: CGFloat, centerAngle: CGFloat, angleWidth: CGFloat)
    {
        let alpha = min(π2, abs(angleWidth)) / 2
        
        let r1 = radius
        
        let d = (1.5 - sin(alpha)) * r1
        
        let c1 = CGPoint(x: 0, y: 0)
        let c2 = CGPoint(x: -d, y: 0)
        
        let p1 = CGPoint(x: cos(alpha) * r1, y: sin(alpha) * r1)
        
        let r2 = sqrt(pow(p1.x - c2.x, 2) + pow(p1.y - c2.y, 2))
        
        let beta = asin( sin(alpha) * r1 / r2 )
        
        let cresent = UIBezierPath()
        
        cresent.moveToPoint(p1)
        cresent.addArcWithCenter(c1, radius: r1, startAngle: alpha, endAngle: -alpha, clockwise: false)
        cresent.addArcWithCenter(c2, radius: r2, startAngle: -beta, endAngle: beta, clockwise: true)
        cresent.closePath()
        
        let rotation = centerAngle.asNormalizedAngle
        
        if rotation != 0
        {
            cresent.applyTransform(CGAffineTransformMakeRotation(-rotation))
        }
        
        if center != CGPointZero
        {
            cresent.applyTransform(CGAffineTransformMakeTranslation(center.x, center.y))
        }
        
        appendPath(cresent)
    }
    
    public func addCresentWithCenter(center: CGPoint, radius: CGFloat, startAngle: CGFloat, endAngle: CGFloat, clockwise: Bool)
    {
        let normalStartAngle = clockwise ? startAngle.asNormalizedAngle : endAngle.asNormalizedAngle
        let normalEndAngle = clockwise ? endAngle.asNormalizedAngle : startAngle.asNormalizedAngle
        
        var centerAngle = ((normalStartAngle + normalEndAngle) / 2).asNormalizedAngle
        var angleWidth = max(normalStartAngle, normalEndAngle) - min(normalStartAngle, normalEndAngle).asNormalizedAngle
        
        if !clockwise
        {
            angleWidth = π2 - angleWidth
            centerAngle += π
        }
        
        addCresentWithCenter(center, radius: radius, centerAngle: centerAngle, angleWidth: angleWidth)
    }
}

public extension UIBezierPath
{
    /**
     Initializeses the bezier curve as a N-Sided Convex Regular Polygon
     
     - parameter n: number of sides
     - parameter center: center og the polygon. Default is (0,0)
     - parameter radius: the radius of the circumscribed circle
     - parameter turned: if *true* the polygon is rotated (counterclockwise around center) to let the rightmost edge be vertical. If *false* the rightmost corner is directly right of the center. Default is *false*
     */
    convenience init(
        convexRegularPolygonWithNumberOfSides n: Int,
        center: CGPoint = CGPointZero,
        circumscribedCircleRadius radius: CGFloat,
        turned: Bool = false)
    {
        precondition(n > 2, "A polygon must have at least three sides")
        
        self.init()
        
        moveToPoint(CGPoint(x: radius, y: 0))
        
        for theta in (1 ..< n).map({ $0 * 2 * π / CGFloat(n)} )
        {
            addLineToPoint(CGPoint(x: radius * cos(theta), y: radius * sin(theta)))
        }
        
        closePath()
        
        if turned
        {
            applyTransform(CGAffineTransformMakeRotation(π / CGFloat(n)))
        }
        
        applyTransform(CGAffineTransformMakeTranslation(center.x, center.y))
    }
    
    convenience init(hexagonWithCenter center: CGPoint = CGPointZero, sideLength: CGFloat, orientation: HexOrientation = .Vertical)
    {
        self.init(convexRegularPolygonWithNumberOfSides: 6, center: center, circumscribedCircleRadius: sideLength, turned: orientation == HexOrientation.Vertical)
    }
    
    convenience init(pentagonWithCenter center: CGPoint = CGPointZero, sideLength: CGFloat, turned: Bool = false)
    {
        self.init(convexRegularPolygonWithNumberOfSides: 5, center: center, circumscribedCircleRadius: sideLength, turned: turned)
    }
}


//MARK: - Spiral

extension UIBezierPath
{
    public convenience init(spiralWithCenter center: CGPoint = CGPointZero, radius: CGFloat, steps: CGFloat, loopCount: CGFloat)
    {
        self.init()
        
        let away = radius / steps
        let around = loopCount / steps * 2 * CGFloat(M_PI)
        
        let points = 1.stride(through: Int(ceil(steps)), by: 1).map { (step) -> CGPoint in
            let x = cos(step * around) * step * away
            let y = sin(step * around) * step * away
            
            return CGPoint(x: x, y: y) + center
        }
        
        moveToPoint(center)
        
        points.forEach { addLineToPoint($0) }
    }
}

//: Playground - noun: a place where people can play

import UIKit

var str = "Hello, playground"

//MARK: - Interpolate

extension UIBezierPath
{
    static func interpolate(segmentPoints : [CGPoint], scale: CGFloat) -> [CGPoint]
    {
        guard segmentPoints.count > 1 else { return [] }
        
        var controlPoints = Array<CGPoint>()
        
        for (i, p1) in segmentPoints.enumerate()
        {
            if i == 0
            {
                let p2 = segmentPoints[i+1]
                
                let tangent = CGVector(from: p1, to: p2) * scale
                
                let q1 = p1 + tangent
                
                controlPoints.append(p1)
                controlPoints.append(q1)
            }
            else if i == segmentPoints.count - 1
            {
                let p0 = segmentPoints[i-1]

                let tangent = CGVector(from: p0, to: p1) * scale

                let q0 = p1 - tangent
                
                controlPoints.append(q0)
                controlPoints.append(p1)
            }
            else
            {
                let p0 = segmentPoints[i - 1]
                let p2 = segmentPoints[i + 1]
                let tangent = CGVector(from: p0, to: p2).normalized * scale
                
                let q0 = p1 - (distance(p1,p0) * tangent)
                let q1 = p1 + (distance(p2,p1) * tangent)
                
                controlPoints.append(q0)
                controlPoints.append(p1)
                controlPoints.append(q1)
            }
        }
        
        return controlPoints
    }
    
    public convenience init?(interpolatedPoints points: [CGPoint], scale: CGFloat = 0.5)
    {
        self.init()
        
        guard points.count > 1 else { return nil }

        let controlPoint = UIBezierPath.interpolate(points, scale: scale)
        
        if let p = controlPoint.first
        {
            moveToPoint(p)
        }
        
        for var i = 3 ; i < controlPoint.count; i += 3
        {
            let q1 = controlPoint[i-2]
            let q2 = controlPoint[i-1]
            let p3 = controlPoint[i]
            
            addCurveToPoint(p3, controlPoint1: q1, controlPoint2: q2)
        }
    }
    
    public enum InterpolationType { case QuadraticBezier }
    public enum InterpolationEnd { case Basic, Open, Closed, Circular }
    
    /// interpolates `points` using the specified type and returns an array of points to use for drawing the interpolated path. 
    /// - parameter points: the points to interpolate
    /// - parameter interpolationType: the type of interpolation
    /// - parameter interpolationEnd: dictates how the ends of `points` are treated
    ///   - `Basic` : The returned points will contain both end points
    ///   - `Open` : The returned points may not contain the original end points
    ///   - `Closed` : As `Open` but the begin and end knot are connected with a spline
    ///   - `Circular` : points are treated as a looped array, where the first point comes after the last
    /// - returns: An array of points, the structure of the array depends on the interpolationType
    ///   - `QuadraticBezier`: return points are structured like this: [k0, q0, k1, q1, k2, q2, ... qn-1, kn]
    
    public static func interpolate(points: [CGPoint], interpolationType: InterpolationType = .QuadraticBezier, interpolationEnd: InterpolationEnd = .Basic) -> [CGPoint]
    {
        guard points.count > 1 else { return [] }

        switch interpolationType
        {
        case .QuadraticBezier:

            var knots = lerp(points, 0.5)
            var ps = points
            
            switch interpolationEnd
            {
            case .Basic:
                // substitute first and last knot with first and last point
                
                knots[0] = points.first!
                knots[knots.count - 1] = points.last!
                
//                for i in 1..<knots.count
//                {
//                    let begin = i == 1 ? points[i-1] : knots[i-1]
//                    let ctrlPoint = points[i]
//                    let end = i == knots.count - 1 ? points[i+1] : knots[i]
//                    
//                    let path = UIBezierPath()
//                    path.moveToPoint(begin)
//                    path.addQuadCurveToPoint(end, controlPoint: ctrlPoint)
//                    
//                    paths.append(path)
//                }

            case .Closed:
                
                // append first knot to knots and make a "fake" controlpoint at lerp(p_first, p_last)
                knots.append(knots.first!)
                ps.append(lerp(points.first!, points.last!, 0.5))
                
//                let path = UIBezierPath()
//                path.moveToPoint(knots.last!)
//                path.addLineToPoint(knots.first!)
//                
//                paths.append(path)
//
//                fallthrough
                
            case .Open:
                // don't go to the end points
                
                break
                
//                for i in 1..<knots.count
//                {
//                    let begin = knots[i-1]
//                    let ctrlPoint = points[i]
//                    let end = knots[i]
//                    
//                    let path = UIBezierPath()
//                    path.moveToPoint(begin)
//                    path.addQuadCurveToPoint(end, controlPoint: ctrlPoint)
//                    
//                    paths.append(path)
//                }
                
            case .Circular:
                // append knot between last and first point, uses last point as ctrl point
                knots.append(lerp(points.last!, points.first!, 0.5))

                // append first knot to knots and first point as ctrl point
                knots.append(knots.first!)
                ps.append(points.first!)
                
//                for i in 1..<knots.count
//                {
//                    let begin = knots[i-1]
//                    let ctrlPoint = points[i]
//                    let end = knots[i]
//                    
//                    let path = UIBezierPath()
//                    path.moveToPoint(begin)
//                    path.addQuadCurveToPoint(end, controlPoint: ctrlPoint)
//                    
//                    paths.append(path)
//                }
//                
//                let path = UIBezierPath()
//                path.moveToPoint(knots.last!)
//                path.addQuadCurveToPoint(knots.first!, controlPoint: points.first!)
                
            
            }
            
            var out = Array<CGPoint>()
            
            out.append(knots[0])
            
            for i in 1..<knots.count
            {
                out.append(ps[i]) // ctrl point
                out.append(knots[i]) // knot
            }

            return out
        }
    }
    
    public convenience init?(quadraticBezierInterpolatedPoints points: [CGPoint], open: Bool = true)
    {
        self.init()
        
        guard points.count > 1 else { return nil }
        
        let knots = lerp(points, 0.5)
        
        if let p = points.first, let k = knots.first
        {
            moveToPoint(p)
            addLineToPoint(k)
        }
        
        for i in 1..<knots.count
        {
            let ctrlPoint = points[i]
            let end = knots[i]
            
            addQuadCurveToPoint(end, controlPoint: ctrlPoint)
        }
        
        if let p = points.last
        {
            addLineToPoint(p)
        }
        
        if !open
        {
            closePath()
        }
    }
}

//MARK: - Superellipse

extension UIBezierPath
{
    public convenience init(superEllipseInRect rect: CGRect, n: CGFloat = CGFloat.𝑒)
    {
        let a = rect.width / 2
        let b = rect.height / 2
        let n_2  = 2 / n
        let c = rect.center
        
        let x = { (t: CGFloat) -> CGFloat in
            let cost = cos(t)
            
            return c.x + sign(cost) * a * pow(abs(cost), n_2)
        }

        let y = { (t: CGFloat) -> CGFloat in
            let sint = sin(t)
            
            return c.y + sign(sint) * b * pow(abs(sint), n_2)
        }
        
        self.init()
        moveToPoint(rect.centerLeft)
        
        let factor = max((a+b)/10, 32)
        
        for t in (-π).stride(to: π, by: π/factor)
        {
            addLineToPoint(CGPoint(x: x(t), y: y(t)))
        }
        closePath()
    }
}