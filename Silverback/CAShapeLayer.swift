//
//  CAShapeLayer.swift
//  Silverback
//
//  Created by Christian Otkjær on 09/12/15.
//  Copyright © 2015 Christian Otkjær. All rights reserved.
//

import UIKit

//MARK: - Animation

extension CAShapeLayer
{
    public func animateLineWidthTo(width: CGFloat, duration: Double = 0.1)
    {
        animate(width, duration: duration, keyPath: "lineWidth")
    }
    
    public func animateStrokeEndTo(strokeEnd: CGFloat, duration: Double = 0.1)
    {
        animate(strokeEnd, duration: duration, keyPath: "strokeEnd")
    }
    
    public func animateStrokeStartTo(strokeStart: CGFloat, duration: Double = 0.1)
    {
        animate(strokeStart, duration: duration, keyPath: "strokeStart")
    }
    
    public func animatePathTo(path: CGPath, duration: Double = 0.1)
    {
        animate(path, duration: duration, keyPath: "path")
    }
    
}

//
//public class SimpleArcLayer: CAShapeLayer
//{
////    override public static func needsDisplayForKey(key: String) -> Bool
////    {
////        
////    }
//    
//    /// Angle where the arc begins in radians. Should be in [0; 2π[
//    
//    public var arcStartAngle : CGFloat = 0 { didSet { updateRotation() } }
//    
//    /// Span of arc in. Should be in [0; 2π]
//    public var arcSpan: CGFloat = 0 {
//        didSet
//        {
//            if !sameSign(oldValue, arcSpan)
//            {
//                updateRotation()
//            }
//                        
//            updateSpan()
//        }
//    }
//    
//    /// Width of the arc, alias for `lineWidth`
//    public var arcWidth: CGFloat
//        {
//        get { return lineWidth }
//        set { lineWidth = newValue; updatePath() }
//    }
//    
//    /// Color of the arc, alias for `strokeColor`
//    public var arcColor: CGColor?
//        {
//        get { return strokeColor }
//        set { strokeColor = newValue }
//    }
//    
//    /// Arc extends clockwise or counterclockwise from start-angle
//    public var clockwise : Bool
//        {
//        get { return arcSpan >= 0 }
//        set {
//        
//            if newValue != clockwise
//            {
//                if newValue
//                {
//                    arcSpan = abs(arcSpan)
//                }
//                else
//                {
//                    arcSpan = -abs(arcSpan)
//                }
//            }
//        
//        }
//    }
//    
//    func updateRotation()
//    {
//        if clockwise
//        {
//            setValue(arcStartAngle, forKeyPath: "transform.rotation.z")
//        }
//        else
//        {
//            setValue(arcStartAngle + arcSpan, forKeyPath: "transform.rotation.z")
//        }
//    }
//    
//    func updateSpan()
//    {
//        if arcSpan >= π2
//        {
//            strokeEnd = 1
//        }
//        else if arcSpan < 0
//        {
//            strokeEnd = 0
//        }
//        else
//        {
//            strokeEnd = arcSpan / π2
//        }
//    }
//    
//    override public var frame : CGRect { didSet { updatePath() } }
//    
//    func updatePath()
//    {
//        let arcDiameter = floor(min(bounds.width, bounds.height) - arcWidth)
//        
//        let arcFrame = CGRect(center: bounds.center, size: CGSize(widthAndHeight: arcDiameter))
//        
//        let circle = UIBezierPath(ovalInRect: arcFrame)
//        
//        path = circle.CGPath
//    }
//    
//    // MARK: - Init
//    
//    override public init()
//    {
//        super.init()
//        setup()
//    }
//
//    override public init(layer: AnyObject)
//    {
//        super.init(layer: layer)
//        setup()
//    }
//    
//    required public init?(coder aDecoder: NSCoder)
//    {
//        super.init(coder: aDecoder)
//        setup()
//    }
//    
//    func setup()
//    {
//        fillColor = UIColor.clearColor().CGColor
//    }
//
//}
//
//public enum ArcCap
//{
//    case Butt, Round, Square
//}
//
//
//public class ArcLayer: CAShapeLayer
//{
//    /// Angle where the arc begins in radians. Should be in [0; 2π[
//    public var arcStartAngle : CGFloat = 0 { didSet { if oldValue != arcStartAngle { updateRotation(changedRotationFor(oldValue, arcSpan: arcSpan, clockwise: clockwise)) } } }
//    
//    /// Cap at start of arc
//    public var startCap: ArcCap = .Butt
//    
//    /// Cap at end of arc
//    public var endCap: ArcCap = .Butt
//    
//    
//    /// Span of arc in. Should be in [0; 2π]
//    public var arcSpan: CGFloat = 0
//        {
//        
//        didSet
//        {
//            if arcSpan > π2 { arcSpan = π2 }
//            if arcSpan < 0 { arcSpan = 0 }
//            
//            if oldValue != arcSpan { updatePath() }
//        }
//    }
//    
//    /// Width of the arc
//    public var arcWidth: CGFloat = 1
//        {
//        didSet
//        {
//            if oldValue != arcWidth { updatePath() }
//        }
//    }
//    
//    /// Color of the arc, alias for `fillColor`
//    public var arcColor: CGColor?
//        {
//        get { return fillColor }
//        set { fillColor = newValue }
//    }
//    
//    /// Arc extends clockwise or counterclockwise from start-angle
//    public var clockwise : Bool = true
//        {
//        didSet { if oldValue != clockwise { updateRotation(changedRotationFor(arcStartAngle, arcSpan: arcSpan, clockwise: oldValue)) } }
//    }
//    
//    func changedRotationFor(arcStartAngle: CGFloat, arcSpan: CGFloat, clockwise: Bool) -> CGFloat?
//    {
//        if arcSpan != self.arcSpan || self.clockwise != clockwise || self.arcStartAngle != arcStartAngle
//        {
//            return clockwise ? arcStartAngle : arcStartAngle - arcSpan.asNormalizedAngle
//        }
//        
//        return nil
//    }
//
//    
//    func updateRotation(oldValue: CGFloat? = nil)
//    {
//        let angle = clockwise ? arcStartAngle : arcStartAngle - arcSpan.asNormalizedAngle
//        
//        if let currentValue = oldValue//valueForKeyPath(CALayerRotationKeyPath) as? CGFloat
//        {
//            rotateBy(angle - currentValue)
//        }
//        else if clockwise
//        {
//            setValue(arcStartAngle, forKeyPath: CALayerRotationKeyPath)
//        }
//        else
//        {
//            setValue(arcStartAngle - arcSpan.asNormalizedAngle, forKeyPath: CALayerRotationKeyPath)
//        }
//    }
//    
//    override public var frame : CGRect { didSet { if !CGRectEqualToRect(frame, oldValue) { updatePath() } } }
//    
//    func updatePath()
//    {
//        let outerRadius = floor((min(bounds.width, bounds.height) - lineWidth) / 2)
//        let innerRadius = floor(outerRadius - arcWidth)
//        let endAngle = arcSpan >= π2 ? π2 : arcSpan <= 0 ? 0 : arcSpan.normalizedRadians
//        
//        let arcPath = UIBezierPath(arcCenter: bounds.center, radius: innerRadius, startAngle: 0, endAngle: endAngle, clockwise: true)
//        
//        arcPath.addArcWithCenter(bounds.center, radius: outerRadius, startAngle: endAngle, endAngle: 0, clockwise: false)
//        arcPath.closePath()
//        
//        path = arcPath.CGPath
//    }
//    
//    // MARK: - Init
//    
//    override public init()
//    {
//        super.init()
//        setup()
//    }
//    
//    override public init(layer: AnyObject)
//    {
//        super.init(layer: layer)
//        setup()
//    }
//    
//    required public init?(coder aDecoder: NSCoder)
//    {
//        super.init(coder: aDecoder)
//        setup()
//    }
//    
//    func setup()
//    {
//        lineWidth = 0
//        strokeColor = UIColor.clearColor().CGColor
//        updatePath()
//    }
//    
//}