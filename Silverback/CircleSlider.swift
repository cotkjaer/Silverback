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
    func circleSlider(slider: CircleSlider, didChangeValueFrom oldValue: Float?)

    func circleSliderDidBeginSliding(slider: CircleSlider)

    func circleSliderDidEndSliding(slider: CircleSlider)
}

@IBDesignable
public class CircleSlider: UIView
{
    @IBOutlet public var indicatorView: UIView? { didSet { oldValue?.removeFromSuperview() } }
    
    public var delegate: CircleSliderDelegate?
    
    public var minimumValue: Float = 0
    public var maximumValue: Float = 1
    public var value: Float = 0.25 { didSet { setNeedsLayout() } }

    public var minimumAngle: CGFloat =  12 * π / 8 + 0.001
    public var maximumAngle: CGFloat =  12 * π / 8 - 0.001

    public var clockwise = true
    
    ///If *true*, the slider sends update events continuously to the associated target’s action method. If *false*, the slider only sends an action event when the user releases the slider’s thumb control to set the final value.
    /// default: *true*
    public var continuous: Bool = true
    
    func setup()
    {
        let indicatorView = CircleView(frame: CGRect(size: CGSize(width: 50,height: 50)))
        
        indicatorView.backgroundColor = UIColor.lightGrayColor()
        indicatorView.borderColor = UIColor.darkGrayColor()
        
        self.addSubview(indicatorView)
        
        self.indicatorView = indicatorView
        
        addGestureRecognizer(UIPanGestureRecognizer(target: self, action: Selector("handlePan:")))
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
        
        let radius = trackRadius

        let angle = angleForValue(value)
        
        indicatorView?.center = bounds.center + CGPoint(x: cos(angle) * radius, y: sin(angle) * radius)
    }
    
    
    // MARK: - Track
    
    private var trackRadius : CGFloat
        {
        
        var radius = min(bounds.width, bounds.height) / 2
            
            if let indicatorView = self.indicatorView
            {
                radius -= max(indicatorView.bounds.width, indicatorView.bounds.height)
            }
            else
            {
                radius -= trackWidth / 2
            }
            
            return radius
        
    }
    
    @IBInspectable
    var trackColor: UIColor = UIColor.darkGrayColor()
    
    @IBInspectable
    var trackWidth: CGFloat = 2
    
    
    // MARK: - drawing
    
    override public func drawRect(rect: CGRect)
    {
        // MARK: - draw track
        
        let radius = trackRadius
        
        let beginAngle = clockwise ? minimumAngle : maximumAngle
        let endAngle = clockwise ? maximumAngle : minimumAngle
        
        let path = UIBezierPath(arcCenter: bounds.center, radius: radius, startAngle: beginAngle, endAngle: endAngle, clockwise: true)
        
        path.lineWidth = trackWidth
        
        trackColor.setStroke()

        path.stroke()
    }
    
    // MARK: - panning
    
    private var prePanningValue : Float?

    private var panning = false {
        didSet
        {
                if oldValue != panning
                {
                    if panning
                    {
                        delegate?.circleSliderDidBeginSliding(self)

                    }
                    else
                    {
                        delegate?.circleSliderDidEndSliding(self)

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
            
            if hitTest(location, withEvent: nil) == indicatorView
            {
                prePanningValue = value
                panning = true
            }
            fallthrough
            
        case .Changed:
            if panning
            {
                if continuous
                {
                    prePanningValue = value
                }

                let angle = bounds.center.angleToPoint(location)
                

                value = valueForAngle(angle)
                
                if continuous
                {
                    delegate?.circleSlider(self, didChangeValueFrom: prePanningValue)
                }
            }
            
        case .Ended:
            fallthrough
            
        default:
            if panning
            {
                panning = false
                
                if !continuous
                {
                    delegate?.circleSlider(self, didChangeValueFrom: prePanningValue)
                }

                prePanningValue = nil
            }
        }
    }
}
