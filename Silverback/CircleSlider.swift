//
//  CircleSlider.swift
//  Silverback
//
//  Created by Christian Otkjær on 23/10/15.
//  Copyright © 2015 Christian Otkjær. All rights reserved.
//

import UIKit

public protocol CircleSliderDelegate
{
    func circleSlider(slider: CircleSlider, didChangeValueFrom oldValue: Float?, forIndicator indicatorIndex: Int)
    
    func circleSlider(slider: CircleSlider, didBeginSlidingIndicator indicatorIndex: Int)
    
    func circleSlider(slider: CircleSlider, didEndSlidingIndicator indicatorIndex: Int)
}

public enum CircleSliderIndicatorAlignment
{
    case Center, Outer, Outside, Inner, Inside
}

public class CircleSliderIndicator: CircleImageView
{
    public var value : Float = 0
    
    public var alignment = CircleSliderIndicatorAlignment.Center
        {
        didSet { superview?.setNeedsLayout() }
    }
    
    public var alignmentOffset = CGFloatZero
    
    internal func centerOffsetForTrackWidth(trackWidth: CGFloat) -> CGFloat
    {
        var delta = CGFloatZero
        
        switch alignment
        {
        case .Center:
            delta = alignmentOffset
            
        case .Inner:
            delta = -(trackWidth - radius) / 2 - alignmentOffset
            
        case .Inside:
            delta = -(trackWidth / 2 + radius) - alignmentOffset
            
        case .Outer:
            delta = (trackWidth - radius) / 2 + alignmentOffset
            
        case .Outside:
            delta = trackWidth / 2 + radius + alignmentOffset
        }
        
        return delta
    }
}

@IBDesignable
public class CircleSlider: UIView
{
    // MARK: - Indicators
    
    var indicators = Array<(CircleSliderIndicator)>()
    
    public func addIndicator(alignment: CircleSliderIndicatorAlignment = .Center) -> CircleSliderIndicator
    {
        let indicator = CircleSliderIndicator(frame: CGRect(size: CGSize(widthAndHeight: 44)))
        
        indicator.borderColor = UIColor.grayColor()
        indicator.backgroundColor = UIColor(white: 0.95, alpha: 1)
        indicator.alignment = alignment
        indicator.value = minimumValue
        
        indicators.append(indicator)
        
        addSubview(indicator)
        
        addProgressArc()
        
        return indicator
    }
    
    public func indicatorForIndex(index: Int) -> CircleSliderIndicator?
    {
        return indicators.get(index)
    }
    
    public func valueForIndex(index: Int) -> Float?
    {
        return indicators.get(index)?.value
    }
    
    public func setValue(newValue: Float, forIndex index: Int)
    {
        indicators.get(index)?.value = newValue
    }
    
    public var delegate: CircleSliderDelegate?
    
    public var minimumValue: Float = 0
    public var maximumValue: Float = 1
    
    public var minimumAngle: CGFloat =  12 * π / 8 + 0.001 { didSet { setNeedsLayout() } }
    public var maximumAngle: CGFloat =  12 * π / 8 - 0.001 { didSet { setNeedsLayout() } }
    
    public var clockwise = true
    
    ///If *true*, the slider sends update events continuously to the associated target’s action method. If *false*, the slider only sends an action event when the user releases the slider’s thumb control to set the final value.
    /// default: *true*
    public var continuous: Bool = true
    
    
    // MARK: - Frame and Bounds
    
    override public var bounds : CGRect { didSet { updateArcFrames() } }
    override public var frame : CGRect { didSet { updateArcFrames() } }
    
    // MARK: - Init
    
    func setup()
    {
        addIndicator().value = 0.5
        
        addGestureRecognizer(UIPanGestureRecognizer(target: self, action: Selector("handlePan:")))
        
        trackLayer.arcColor = trackColor.CGColor
        layer.insertSublayer(trackLayer, atIndex: 0)
        updateProgressArcs()
    }
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        setup()
    }
    
    
    var angleSpan : CGFloat
        {
            var angleSpan = maximumAngle - minimumAngle
            
            if clockwise && minimumAngle > maximumAngle
            {
                angleSpan += 2 * π
            }
            else if !clockwise && maximumAngle > minimumAngle
            {
                angleSpan += 2 * π
            }
            
            return angleSpan
    }
    
    func angleForValue(value: Float) -> CGFloat
    {
        let valueSpan = maximumValue - minimumValue
        
        let valueInSpan = min(maximumValue, max(minimumValue, value)) - minimumValue
        
        let angle = CGFloat( valueInSpan / valueSpan ) * angleSpan + minimumAngle
        
        return angle
    }
    
    func valueForAngle(angle: CGFloat) -> Float
    {
        let valueSpan = maximumValue - minimumValue
        
        var beginAngle = clockwise ? minimumAngle : maximumAngle
        var endAngle = clockwise ? maximumAngle : minimumAngle
        
        while beginAngle < 0
        {
            beginAngle += 2 * π
        }
        
        while endAngle < beginAngle
        {
            endAngle += 2 * π
        }
        
        var realAngle = angle
        
        while realAngle < beginAngle
        {
            realAngle += 2 * π
        }
        
        let angleSpan = endAngle - beginAngle
        
        let angleInSpan = min(endAngle, max(beginAngle, realAngle)) - beginAngle
        
        let value = Float(angleInSpan / angleSpan) * valueSpan + minimumValue
        
        return value
    }
    
    override public func layoutSubviews()
    {
        super.layoutSubviews()
        
//        updateProgressArcs()
        
        layoutIndicators()
    }
    
    func layoutIndicators()
    {
        for indicator in indicators
        {
            layoutIndicator(indicator)
        }
    }
    
    private func layoutIndicator(index: Int)
    {
        if let indicator = indicators.get(index)
        {
            layoutIndicator(indicator)
        }
    }
    
    private func layoutIndicator(indicator: CircleSliderIndicator)
    {
        let angle = angleForValue(indicator.value)
        
        let R = self.trackRadius + indicator.centerOffsetForTrackWidth(trackWidth)
        
        indicator.center = pointFor(angle, radius: R)
    }
    
    private func pointFor(angle: CGFloat, radius: CGFloat) -> CGPoint
    {
        return bounds.center + CGPoint(x: cos(angle) * radius, y: sin(angle) * radius)
    }
    
    
    // MARK: - Track
    
    private var trackRadius : CGFloat
        {
            var deltaRadius = CGFloatZero
            
            for indicator in indicators
            {
                switch indicator.alignment
                {
                case .Center:
                    deltaRadius = max(deltaRadius, indicator.alignmentOffset + indicator.radius)
                    
                case .Inner:
                    deltaRadius = max(deltaRadius, -indicator.alignmentOffset + trackWidth - 2 * indicator.radius)
                    
                case .Inside:
                    break
                    
                case .Outer:
                    deltaRadius = max(deltaRadius, indicator.alignmentOffset)
                    
                case .Outside:
                    deltaRadius = max(deltaRadius, indicator.alignmentOffset + 2 * indicator.radius)
                }
            }
            
            return radius - deltaRadius
    }
    
    @IBInspectable
    var trackColor: UIColor = UIColor(white: 0, alpha: 0.1)
    
    @IBInspectable
    var trackWidth: CGFloat = 2 { didSet { updateArcWidths() } }
    
    private let trackLayer = ArcLayer()

//    func updateArc(arcLayer: ArcLayer)
//    {
//        arcLayer.arcWidth = widh
//
//        if let index = progressArcs.indexOf(arcLayer),
//        {
//            arcLayer.arcStartAngle =
//        
//        arcView.width = trackWidth
//        arcView.startAngle = beginAngle
//        arcView.endAngle = endAngle
//        arcView.clockwise = true
////        arcView.color = trackColor
//        arcView.frame = CGRect(center: bounds.center, size: CGSize(widthAndHeight: 2 * trackRadius + trackWidth))
//    }
    
    // MARK: - progressArcs
    
    private var progressArcs = Array<ArcLayer>()
    
    func addProgressArc()
    {
        let arcLayer = ArcLayer()
//        updateArc(arcLayer)
        
        if let lastArc = progressArcs.last//, let index = subviews.indexOf(lastArc)
        {
            layer.insertSublayer(arcLayer, above: lastArc)
        }
        else
        {
            layer.insertSublayer(arcLayer, above: trackLayer)
        }

        progressArcs.append(arcLayer)
        
        arcLayer.arcColor = UIColor.random().CGColor
        arcLayer.arcWidth = trackWidth
        arcLayer.frame = bounds
    }

    func updateArcWidths()
    {
        progressArcs.forEach { $0.arcWidth = trackWidth }
        trackLayer.arcWidth = trackWidth
    }

    func updateArcFrames()
    {
        let arcFrame = CGRect(center: bounds.center, size: CGSize(widthAndHeight: trackRadius * 2))
        
        progressArcs.forEach { $0.frame = arcFrame }
        trackLayer.frame = arcFrame
    }
    
    func updateProgressArcs()
    {
        let sortedIndicators = indicators.enumerate().sort({ $0.1.value < $1.1.value })
        
        var begin = CGFloatZero
        
        for (index, indicator) in sortedIndicators
        {
            if let arc = progressArcs.get(index)
            {
                let end = CGFloat(indicator.value)
                arc.arcStartAngle = begin * π2
                arc.arcEndAngle = end * π2
                arc.arcWidth = trackWidth
                begin = end
            }
        }
        
        trackLayer.arcStartAngle = begin * π2
        trackLayer.arcEndAngle = π2
        trackLayer.arcWidth = trackWidth
    }
    
    
    // MARK: - Drawing
    
//    override public func drawRect(rect: CGRect)
//    {
//        // MARK: - draw track
//        
//        let radius = trackRadius
//        
//        let beginAngle = clockwise ? minimumAngle : maximumAngle
//        let endAngle = clockwise ? maximumAngle : minimumAngle
//        
//        let path = UIBezierPath(arcCenter: bounds.center, radius: radius, startAngle: beginAngle, endAngle: endAngle, clockwise: true)
//        
//        path.lineWidth = trackWidth
//        
//        trackColor.colorWithAlphaComponent(0.1).setStroke()
//        
//        path.stroke()
//        
//        for indicator in indicators
//        {
//            if indicator.borderColor == UIColor.clearColor() { continue }
//            
//            var p1 = CGPointZero
//            var p2 = CGPointZero
//            
//            switch indicator.alignment
//            {
//            case .Outside:
//                let angle = angleForValue(indicator.value)
//                
//                let r1 = trackRadius - trackWidth / 2
//                
//                let r2 = trackRadius + trackWidth / 2 + indicator.alignmentOffset
//
//                p1 = pointFor(angle, radius: r1)
//                p2 = pointFor(angle, radius: r2)
//                
//            case .Inside:
//                let angle = angleForValue(indicator.value)
//                
//                let r1 = trackRadius - trackWidth / 2 + indicator.alignmentOffset
//                
//                let r2 = trackRadius + trackWidth / 2
//                
//                p1 = pointFor(angle, radius: r1)
//                p2 = pointFor(angle, radius: r2)
//                
//            default:
//                continue
//            }
//            
//            
//            let path = UIBezierPath()
//            
//            indicator.borderColor?.setStroke()
//            
//            path.lineWidth = max(1, indicator.borderSize)
//            path.moveToPoint(p1)
//            path.addLineToPoint(p2)
//            
//            path.stroke()
//        }
//    }
    
    // MARK: - panning
    
    private var prePanningValue : Float?
    private var panningIndex : Int?
        {
        didSet
        {
            if oldValue != panningIndex
            {
                if let index = panningIndex
                {
                    delegate?.circleSlider(self, didBeginSlidingIndicator: index)
                    
                }
                else if let index = oldValue
                {
                    delegate?.circleSlider(self, didEndSlidingIndicator: index)
                }
            }
        }
    }
    
    func handlePan(panGestureRecognizer: UIPanGestureRecognizer)
    {
        let location = panGestureRecognizer.locationInView(self)
        
        switch panGestureRecognizer.state
        {
        case .Began:
            
            for (index, indicator) in indicators.enumerate()
            {
                if convertRect(indicator.bounds, fromView:indicator).contains(location)
                {
                    prePanningValue = indicator.value
                    panningIndex = index
                    break
                }
            }
            
            fallthrough
            
        case .Changed:
            
            if let index = panningIndex, let indicator = indicators.get(index)
            {
                if continuous
                {
                    prePanningValue = indicator.value
                }
                
                let angle = bounds.center.angleToPoint(location)
                
//                setIndicator(indicator, value: valueForAngle(angle))
                indicator.value = valueForAngle(angle)
                
//                progressArcs.get(index)?.end = CGFloat(indicator.value)//animateProgressLineEnd(indicator.value)
                
                if continuous
                {
                    delegate?.circleSlider(self, didChangeValueFrom: prePanningValue, forIndicator: index)
                }

                updateProgressArcs()

                layoutIndicators()
//                layoutIndicator(index)
            }
            
        case .Ended:
            fallthrough
            
        default:
            if let index = panningIndex
            {
                panningIndex = nil
                
                if !continuous
                {
                    delegate?.circleSlider(self, didChangeValueFrom: prePanningValue, forIndicator: index)
                    
                    updateProgressArcs()
                }
                
                prePanningValue = nil
            }
        }
    }
    
//    // MARK: - Progress
//    
//    let progressLine = CAShapeLayer()
//    
//    func addProgressLayer()
//    {
//        let radius = trackRadius
//        
//        let beginAngle = clockwise ? minimumAngle : maximumAngle
//        let endAngle = clockwise ? maximumAngle : minimumAngle
//        
//        let path = UIBezierPath(arcCenter: bounds.center, radius: radius, startAngle: beginAngle, endAngle: endAngle, clockwise: true)
//        
//        // create an object that represents how the curve
//        // should be presented on the screen
//        progressLine.path = path.CGPath
//        progressLine.strokeColor = UIColor.blueColor().CGColor
//        progressLine.fillColor = UIColor.clearColor().CGColor
//        progressLine.lineWidth = trackWidth
//        progressLine.lineCap = kCALineCapRound
//        
//        // add the curve to the screen
//        layer.addSublayer(progressLine)
//    }
//    
//    func animateProgressLineEnd(value : Float)
//    {
//        // create a basic animation that animates the value 'strokeEnd'
//        let animateStrokeEnd = CABasicAnimation(keyPath: "strokeEnd")
//
//        animateStrokeEnd.duration = 0.1//Double(abs(progressLine.strokeEnd - CGFloat(value))) / 3
//        
//        if let pLayer = progressLine.presentationLayer() as? CAShapeLayer
//        {
//            //        animateStrokeEnd.fromValue = 0.0
//            animateStrokeEnd.fromValue = pLayer.strokeEnd
//        }
//        
//        animateStrokeEnd.fromValue = progressLine.strokeEnd
//        
////        animateStrokeEnd.toValue = value//1.0
////        animateStrokeEnd.removedOnCompletion = false
//
////        progressLine.removeAnimationForKey("animate stroke end animation")
//
//        // add the animation
//        progressLine.strokeEnd = CGFloat(value)
//        progressLine.addAnimation(animateStrokeEnd, forKey: "animate stroke end animation")
//    }
    
//    // MARK: - experiment
//    
//    func setIndicator(indicator: CircleSliderIndicator, value: Float)
//    {
//        let oldAngle = angleForValue(indicator.value)
//        let newAngle = angleForValue(value)
//        
//        let angle = CGFloat.normalizeAngle(newAngle, oldAngle) - oldAngle
//
//        let path = UIBezierPath(arcCenter: bounds.center, radius: trackRadius, startAngle: oldAngle, endAngle: newAngle, clockwise: angle > 0)
//
//        let orbit = CAKeyframeAnimation(keyPath: "position")
//        
//        //        orbit.keyPath = @"position";
//        
//        orbit.path = path.CGPath// UIBezierPath(ovalInRect: boundingRect).CGPath
//        orbit.duration = Double(abs(4 * angle / π2))
//        //        orbit.additive = true
////        orbit.repeatCount Float.infinity
//        orbit.calculationMode = kCAAnimationPaced
//        orbit.rotationMode = nil// kCAAnimationRotateAuto
//        orbit.removedOnCompletion = false
//        
//        indicator.value = value
//        indicator.layer.addAnimation(orbit, forKey: "orbit")
//    }
//    
//    func experiment()
//    {
//        return
////        let satellite = UIView(frame: CGRect(x: 0,y: 0,width: 70,height: 70))// UIImageView(image: UIImage(named: "fog"))
////        satellite.backgroundColor = UIColor.purpleColor()
////        
////        backgroundColor = UIColor(white: 0.0, alpha: 0.1)
////        
////        addSubview(satellite)
////        
//        
//        let satellite = indicatorForIndex(0)!
//        let d = trackRadius * 2 + trackWidth
//        
////        let boundingRect = CGRectMake(0, 0, d, d);
//        let boundingRect = CGRectMake((bounds.width - d) / 2, (bounds.height - d ) / 2, d, d)
//        
//        satellite.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
//        let orbit = CAKeyframeAnimation(keyPath: "position")
//        
//        //        orbit.keyPath = @"position";
//        
//        let path = UIBezierPath(arcCenter: bounds.center, radius: trackRadius, startAngle: 0, endAngle: π2, clockwise: true)
//
//        orbit.path = path.CGPath// UIBezierPath(ovalInRect: boundingRect).CGPath
//        orbit.duration = 15
////        orbit.additive = true
//        orbit.repeatCount = Float.infinity
//        orbit.calculationMode = kCAAnimationPaced
//        orbit.rotationMode = nil// kCAAnimationRotateAuto
//        
//        
//        satellite.layer.addAnimation(orbit, forKey: "orbit")
//    }
}
