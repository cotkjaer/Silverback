//
//  ArcLayer.swift
//  Silverback
//
//  Created by Christian Otkjær on 12/12/15.
//  Copyright © 2015 Christian Otkjær. All rights reserved.
//

import UIKit


class ArcLayer: CAShapeLayer
{
    var arcStartAngle : CGFloat = 0
        {
        didSet { updateStartAndEndStroke() }
    }
    
    var arcEndAngle : CGFloat = π
        {
        didSet { updateStartAndEndStroke() }
    }
    
    var arcWidth : CGFloat
        {
        set
        {
            if lineWidth != newValue
            {
                lineWidth = newValue
                updatePath()
            }

        }
        get { return lineWidth }
    }
    
    override var lineWidth : CGFloat { didSet { updatePath() } }
    
    var arcClockwise : Bool = true
        {
        didSet { updateStartAndEndStroke() }
    }
    
    var arcColor : CGColor
        {
        set { strokeColor = newValue }
        get { return strokeColor ?? UIColor.clearColor().CGColor }
    }

    // MARK: - Bounds
    
    override var bounds : CGRect { didSet { updatePath() } }
    
    // MARK: - Init
    
    override init()
    {
        super.init()
        setup()
    }
    
    override init(layer: AnyObject)
    {
        super.init(layer: layer)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup()
    {
        fillColor = UIColor.clearColor().CGColor
        updatePath()
    }
    
    // MARK: - Update
    
    // MARK: start- and end-stroke
    
    func updateStartAndEndStroke()
    {
        var realStartAngle = arcStartAngle.asNormalizedAngle
        var realEndAngle = arcEndAngle.asNormalizedAngle
     
        if !arcClockwise
        {
            swap(&realStartAngle, &realEndAngle)
        }
        
        if realEndAngle <= realStartAngle && arcStartAngle != arcEndAngle { realEndAngle += π2 }
        
        animate(realStartAngle / π4, duration: 0.1, keyPath: "strokeStart")
        animate(realEndAngle / π4, duration: 0.1, keyPath: "strokeEnd")
    }
    
    // MARK: Path
    
    func updatePath()
    {
        let radius = floor((min(bounds.width, bounds.height) - arcWidth) / 2)
        
        let twoLoops = UIBezierPath(arcCenter: bounds.center, radius: radius, startAngle: 0, endAngle: π2, clockwise: true)

        twoLoops.addArcWithCenter(bounds.center, radius: radius, startAngle: π2, endAngle: π4, clockwise: true)
        
        path = twoLoops.CGPath
    }
}



// MARK: - Layer

class AArcLayer: CAShapeLayer
{
    var arcStartAngle : CGFloat
        {
        set { rotation = newValue }//setValue(newValue, forKeyPath: "transform.rotation.z") }
        get { return rotation }//valueForKeyPath("transform.rotation.z") as! CGFloat }
    }
    
    var arcEndAngle : CGFloat
        {
        set { strokeEnd = (newValue - arcStartAngle) / π2 }
        get { return arcStartAngle + π2 * strokeEnd }
    }
    
    var arcWidth : CGFloat
        {
        set { lineWidth = newValue; updatePath() }
        get { return lineWidth }
    }
    
    var arcClockwise : Bool = true
    
    var arcColor : CGColor
        {
        set { strokeColor = newValue }
        get { return strokeColor ?? UIColor.clearColor().CGColor }
    }
    
    override var bounds : CGRect { didSet { updatePath() } }
    override var frame : CGRect { didSet { updatePath() } }
    
    // MARK: - Init
    
    override init()
    {
        super.init()
        setup()
    }
    
    override init(layer: AnyObject)
    {
        super.init(layer: layer)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup()
    {
        fillColor = UIColor.clearColor().CGColor
        updatePath()
    }
    
    
    func updatePath()
    {
        let diameter = floor(min(frame.width, frame.height) - arcWidth)
        
        let circle = UIBezierPath(ovalInRect: CGRect(center: bounds.center, size: CGSize(widthAndHeight: diameter)))
        
        path = circle.CGPath
    }
    
}

//    static let ValueKey = "value"
let ArcWidthKey = "arcWidth"
let ArcStartAngleKey = "arcStartAngle"
let ArcEndAngleKey = "arcEndAngle"
let ArcClockwiseKey = "arcClockwise"
let ArcColorKey = "arcColor"

internal class DrawnArcLayer: CALayer
{
    //NB No good for animations if the view is large, but may be extended with start and end cap
    
    
    @NSManaged
    var arcStartAngle : CGFloat
    
    @NSManaged
    var arcEndAngle : CGFloat
    
    @NSManaged
    var arcWidth : CGFloat
    
    @NSManaged
    var arcClockwise : Bool
    
    @NSManaged
    var arcColor : CGColor
    
    override class func needsDisplayForKey(key: String) -> Bool
    {
        switch key
        {
        case ArcWidthKey, ArcStartAngleKey, ArcEndAngleKey, ArcClockwiseKey, ArcColorKey:
            return true
            
        default:
            return super.needsDisplayForKey(key)
        }
    }
    
    override func actionForKey(key: String) -> CAAction?
    {
        switch key
        {
        case ArcWidthKey, ArcStartAngleKey, ArcEndAngleKey, ArcClockwiseKey, ArcColorKey:
            let animation = CABasicAnimation(keyPath: key)
            animation.fromValue = presentationLayer()?.valueForKey(key)
            animation.duration = 1
            return animation
            
        default:
            return super.actionForKey(key)
        }
        
    }
    
    override func drawInContext(ctx: CGContext)
    {
        //            super.drawInContext(ctx)
        
        UIGraphicsPushContext(ctx)
        
        let outerRadius = min(bounds.width, bounds.height) / 2
        let innerRadius = outerRadius - arcWidth
        
        //            let startAngle : CGFloat = 0
        //            let endAngle = π2 * CGFloat(value)
        
        let path = UIBezierPath(arcCenter: bounds.center, radius: innerRadius, startAngle: arcStartAngle, endAngle: arcEndAngle, clockwise: arcClockwise)
        path.addArcWithCenter(bounds.center, radius: outerRadius, startAngle: arcEndAngle, endAngle: arcStartAngle, clockwise: !arcClockwise)
        
        path.closePath()
        
        UIColor(CGColor: arcColor).setFill()
        
        path.fill()
        
        UIGraphicsPopContext()
    }
}

