//
//  SpeechBubbleView.swift
//  Silverback
//
//  Created by Christian Otkjær on 21/01/16.
//  Copyright © 2016 Christian Otkjær. All rights reserved.
//

import UIKit

@IBDesignable
public class SpeechBubbleView: UIView
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
    
    public override func awakeFromNib()
    {
        super.awakeFromNib()
        setup()
    }
    
    func setup()
    {
        super.backgroundColor = UIColor.clearColor()
    }
    
    private var bubbleBackground : UIColor? = UIColor.whiteColor()
    
    override public var backgroundColor: UIColor? {
    
        set { bubbleBackground = newValue }
        get { return bubbleBackground }
    
    }
    
    @IBInspectable
    /// Should be in [0:4]
    public var lineCount: Int = 0

    @IBInspectable
    public var upper: Bool = false

    @IBInspectable
    public var left: Bool = false
    
    @IBInspectable
    public var maxLineThickness: CGFloat = 100 { didSet { setNeedsDisplay() } }

    @IBInspectable
    public var minLineThickness: CGFloat = 1 { didSet { setNeedsDisplay() } }
    
    @IBInspectable
    public var color: UIColor? = nil { didSet { setNeedsDisplay() } }
    
    override public var bounds : CGRect { didSet { setNeedsDisplay() } }
    
    public override func tintColorDidChange()
    {
        if color == nil { setNeedsDisplay() }
    }
    
    override public func drawRect(rect: CGRect)
    {
        (color ?? tintColor).setStroke()
        backgroundColor?.setFill()
        
        let center = bounds.center
        
        var radius = floor(min(center.x, center.y))
        
        let linewidth = max(minLineThickness, min(maxLineThickness, radius / 9))
        
        radius -= linewidth / 2
        
        let corner = CGPoint(x: left ? -radius : radius, y: upper ? -radius : radius)
        
        var startAngle = π_4 + π_16
        var endAngle = π_4 - π_16
        
        if left && upper
        {
            startAngle += π
            endAngle += π
        }
        else if left && !upper
        {
            startAngle += π_2
            endAngle += π_2
        }
        else if upper
        {
            startAngle -= π_2
            endAngle -= π_2
        }
        
        let bubblePath = UIBezierPath(arcCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        
        bubblePath.addLineToPoint(center + corner)
        bubblePath.closePath()
        
        bubblePath.lineWidth = linewidth
        bubblePath.lineJoinStyle = .Round
        
        bubblePath.fill()
        bubblePath.stroke()
    }
    
    func createPath() -> UIBezierPath
    {
        let center = bounds.center
        
        var radius = floor(min(center.x, center.y))
        
        let linewidth = radius / 9
        
        radius -= linewidth / 2

        let outer = bounds.insetBy(dx: linewidth/2, dy: linewidth/2)
        let inner = outer.insetBy(dx: radius, dy: radius)
        
        let path = UIBezierPath()
        
        path.moveToPoint(CGPoint(x: outer.right, y: inner.bottom))
        
        
        path.addArcWithCenter(inner.bottomRight, radius: radius, startAngle: 0, endAngle: π_2, clockwise: true)
        
        path.addLineToPoint(CGPoint(x: inner.left, y: outer.bottom))

        path.addArcWithCenter(inner.bottomLeft, radius: radius, startAngle: π_2, endAngle: π, clockwise: true)

        path.addLineToPoint(CGPoint(x: outer.left, y: inner.top))

        path.addArcWithCenter(inner.topLeft, radius: radius, startAngle: π, endAngle: π + π_2, clockwise: true)
        
        path.addLineToPoint(CGPoint(x: inner.right, y: outer.top))

        path.addArcWithCenter(inner.topRight, radius: radius, startAngle: π + π_2, endAngle: π + π2, clockwise: true)
        
        path.closePath()
        
        path.lineWidth = linewidth
        path.lineJoinStyle = .Round

        return path
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
