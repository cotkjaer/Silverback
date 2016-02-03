//
//  SmileyView.swift
//  Silverback
//
//  Created by Christian Otkjær on 21/01/16.
//  Copyright © 2016 Christian Otkjær. All rights reserved.
//

import UIKit

@IBDesignable
public class SmileyView: UIView
{
    // MARK: - Init
    
    override public init(frame: CGRect)
    {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup()
    {
        roundCorners()
    }
    
    @IBInspectable
    /// Should be in [0:1]
    public var eyeHeight: CGFloat = 0.2
    
    @IBInspectable
    /// Should be in [0:1]
    public var eyeWidth: CGFloat = 0.15
    
    
    @IBInspectable
    /// Should be in [0:1]
    public var smileHeight: CGFloat = -0.1
    
    @IBInspectable
    /// Should be in [0:1]
    public var smileWidth: CGFloat = 0.6
    
    
    @IBInspectable
    /// Should be in [0:1]
    public var smile: CGFloat = 0.4
    
    @IBInspectable
    public var maxLineThickness: CGFloat = 100 { didSet { setNeedsDisplay() } }
    
    @IBInspectable
    public var minLineThickness: CGFloat = 1 { didSet { setNeedsDisplay() } }
    
    @IBInspectable
    public var lineColor: UIColor? = nil { didSet { setNeedsDisplay() } }

    @IBInspectable
    public var faceColor: UIColor = UIColor.whiteColor() { didSet { setNeedsDisplay() } }
    
    @IBInspectable
    public var faceBorder : Bool = true { didSet { setNeedsDisplay() } }
    
    override public var bounds : CGRect { didSet { roundCorners(); setNeedsDisplay() } }
    
    override public func drawRect(rect: CGRect)
    {
        (lineColor ?? tintColor)?.setStroke()
        faceColor.setFill()
        
        let center = bounds.center
        
        var radius = min(center.x, center.y)
        
        let linewidth = min(maxLineThickness, max(minLineThickness, radius / 9))
        
        radius -= linewidth / 2
        
        if faceBorder
        {
            let facePath = UIBezierPath(ovalInRect: CGRect(center: center, size: CGSize(widthAndHeight: radius * 2)))
            
            facePath.lineWidth = linewidth
            
            facePath.fill()
            facePath.stroke()
        }
        
        let smileCenter = CGPoint(
            x: center.x,
            y: center.y - ( radius * smileHeight + linewidth * (2 - smile)))
        
        let smilePath = UIBezierPath(arcCenter: smileCenter,
            radius: radius * smileWidth,
            startAngle: π_4 * (1 - smile),
            endAngle: π_4 * (3 + smile),
            clockwise: true)
        
        smilePath.lineWidth = linewidth
        smilePath.lineCapStyle = .Round
        
        smilePath.stroke()
        
        (lineColor ?? tintColor)?.setFill()

        let eyeCenter = CGPoint(x: center.x, y: center.y - radius * eyeHeight)
        let eyeCenterDelta = CGPoint(x: linewidth + radius * eyeWidth, y: 0)
        
        let rightEyePath = UIBezierPath(ovalInRect: CGRect(center: eyeCenter + eyeCenterDelta, size: CGSize(widthAndHeight: linewidth * 2)))

        rightEyePath.fill()
        
        let leftEyePath = UIBezierPath(ovalInRect: CGRect(center: eyeCenter - eyeCenterDelta, size: CGSize(widthAndHeight: linewidth * 2)))
        
        leftEyePath.fill()
    }
    
    // MARK: - IB
    
    public override func prepareForInterfaceBuilder()
    {
        setup()
    }
    
    public override func intrinsicContentSize() -> CGSize
    {
        return CGSize(widthAndHeight: 100)
    }
}
