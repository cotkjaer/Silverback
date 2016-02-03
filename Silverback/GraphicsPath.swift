//
//  GraphicsPath.swift
//  Silverback
//
//  Created by Christian Otkjær on 25/11/15.
//  Copyright © 2015 Christian Otkjær. All rights reserved.
//

import UIKit

public class GraphicsPath
{
    var elements = Array<PathElement>()// { didSet { updateCurves() } }
    
//    var curves = Array<BezierCurve>()
    
    init(elements: [PathElement])
    {
        self.elements = elements
//        updateCurves()
    }
    
    convenience init(cgPath: CGPathRef)
    {
        self.init(uiBezierPath: UIBezierPath(CGPath: cgPath))
    }
    
    convenience init(uiBezierPath: UIBezierPath)
    {
        self.init(elements: uiBezierPath.elements)
        
      //  self.uiBezierPath = uiBezierPath
    }
    
    convenience init(attributedString:NSAttributedString)
    {
        self.init(cgPath: CGPathCreateSingleLineStringWithAttributedString(attributedString))
    }

    convenience init(string: String, withFont font: UIFont)
    {
        self.init(attributedString: NSAttributedString(string: string, attributes: [NSFontAttributeName : font]))
    }

    // MARK: - UIBezierPath
    
    lazy var uiBezierPath : UIBezierPath =
    {
        return UIBezierPath(elements: self.elements)
        
    }()
    
    // MARK: - frame
    
    lazy var frame : CGRect = { return CGPathGetBoundingBox(self.uiBezierPath.CGPath) }()
    
//    var cachedFrame : CGRect?
//    
//    func frame() -> CGRect
//    {
//        if let frame = cachedFrame { return frame }
//        
//        cachedFrame = CGPathGetBoundingBox(CGPath())
//
//        return frame()
//    }

    // MARK: - CGPath

//    lazy var CGPath : CGPathRef = {
//    
//        let uiPath = UIBezierPath()
//        
//        for element in self.elements
//        {
//            switch element
//            {
//            case .MoveToPoint(let point):
//                uiPath.moveToPoint(point)
//                
//            case .AddLineToPoint(let endPoint):
//                uiPath.addLineToPoint(endPoint)
//                
//            case .add(let ctrlPoint, let endPoint):
//                uiPath.addQuadCurveToPoint(endPoint, controlPoint: ctrlPoint)
//                
//            case .AddCubicBezierToPoint(let p1, let p2, let p3):
//                uiPath.addCurveToPoint(p3, controlPoint1: p1, controlPoint2: p2)
//                
//            case .CloseSubpath:
//                uiPath.closePath()
//            }
//        }
//        
//        return uiPath.CGPath
//
//    }()
    
    
//    var cachedCGPath : CGPathRef?
//    
//    func CGPath() -> CGPathRef
//    {
//        if let cgPath = cachedCGPath { return cgPath }
//        
//        let uiPath = UIBezierPath()
//        
//        for e in elements
//        {
//            switch e
//            {
//            case .MoveToPoint(let point):
//                uiPath.moveToPoint(point)
//                
//            case .AddLineToPoint(let endPoint):
//                uiPath.addLineToPoint(endPoint)
//                
//            case .AddQuadraticBezierToPoint(let ctrlPoint, let endPoint):
//                uiPath.addQuadCurveToPoint(endPoint, controlPoint: ctrlPoint)
//                
//            case .AddCubicBezierToPoint(let p1, let p2, let p3):
//                uiPath.addCurveToPoint(p3, controlPoint1: p1, controlPoint2: p2)
//                
//            case .CloseSubpath:
//                uiPath.closePath()
//            }
//        }
//        
//        return uiPath.CGPath
//    }
    
    // MARK: - Cubic Bezier Curves
    
    func cubicBezierCurves() -> [CubicBezierCurve]
    {
        var curves = Array<CubicBezierCurve>()

        var subPathBeginPoint = CGPointZero
        var beginPoint = CGPointZero
        
        elements.forEach { (element) -> () in
            
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
    
    // MARK: - Update Curves
    
//    func updateCurves()
//    {
//        var subPathBeginPoints = Array<CGPoint>()
//        
//        var curves = Array<BezierCurve>()
//        
//        elements.forEach { (element) -> () in
//            
//            switch element
//            {
//            case .MoveToPoint(let point):
//                subPathBeginPoints.append(point)
//                curves.append(BezierCurve(points: [point]))
//                
//            case .AddLineToPoint(let endPoint):
//                if let beginPoint = curves.last?.endPoint
//                {
//                    curves.append(BezierCurve(points: [beginPoint, endPoint]))
//                }
//                else
//                {
//                    debugPrint("Could not create curve for \(element) - due to missing beginPoint")
//                }
//                
//            case .AddQuadraticBezierToPoint(let ctrlPoint, let endPoint):
//                
//                if let beginPoint = curves.last?.endPoint
//                {
//                    curves.append(BezierCurve(points: [beginPoint, ctrlPoint, endPoint]))
//                }
//                else
//                {
//                    debugPrint("Could not create curve for \(element) - due to missing beginPoint")
//                }
//                
//            case .AddCubicBezierToPoint(let p1, let p2, let p3):
//                
//                if let p0 = curves.last?.endPoint
//                {
//                    curves.append(BezierCurve(points: [p0, p1, p2, p3]))
//                }
//                else
//                {
//                    debugPrint("Could not create curve for \(element) - due to missing beginPoint")
//                }
//                
//            case .CloseSubpath:
//                
//                if let beginPoint = curves.last?.endPoint, let endPoint = subPathBeginPoints.last
//                {
//                    curves.append(BezierCurve(points: [beginPoint, endPoint]))
//                    subPathBeginPoints.removeLast()
//                }
//            }
//            
//            self.curves = curves
//        }
//    }
}

// MARK: - CustomDebugStringConvertible

extension GraphicsPath : CustomDebugStringConvertible
{
    public var debugDescription : String {
    
        let elementsDescriptions = elements.enumerate().map({ "\($0) : \($1.debugDescription)" })
        
        return "\npath\n" + elementsDescriptions.joinWithSeparator("\n")
    }
}

//MARK: - Draw

extension GraphicsPath
{
    func stroke(withColor color: UIColor = UIColor.blackColor(), lineWidth: CGFloat = 1, inContext: CGContextRef? = nil)
    {
        guard let context = inContext ?? UIGraphicsGetCurrentContext() else { return }

        CGContextSaveGState(context)

        // Flip the context coordinates in iOS only.
        CGContextTranslateCTM(context, 0, frame.size.height)
        CGContextScaleCTM(context, 1, -1)

        CGContextTranslateCTM(context, -lineWidth, -lineWidth)

        CGContextAddPath(context, uiBezierPath.CGPath)
        
        CGContextSetStrokeColorWithColor(context, color.CGColor)
        CGContextSetLineWidth(context, lineWidth)

        CGContextStrokePath(context)
        
        CGContextRestoreGState(context)
    }
    
    func fill(withColor color: UIColor = UIColor.blackColor(), inContext: CGContextRef? = nil)
    {
        guard let context = inContext ?? UIGraphicsGetCurrentContext() else { return }
        
        CGContextSaveGState(context)
        
        // Flip the context coordinates in iOS only.
        CGContextTranslateCTM(context, 0, frame.size.height)
        CGContextScaleCTM(context, 1, -1)
        
        CGContextAddPath(context, uiBezierPath.CGPath)
        
        CGContextSetFillColorWithColor(context, color.CGColor)
        
        CGContextFillPath(context)
        
        CGContextRestoreGState(context)
    }
}
