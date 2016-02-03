//
//  IconView.swift
//  Silverback
//
//  Created by Christian Otkjær on 01/02/16.
//  Copyright © 2016 Christian Otkjær. All rights reserved.
//

import UIKit

@IBDesignable
public class ArcAndSpikeView: IconView
{
    var startArc : CGFloat = -π_8 { didSet { setNeedsDisplay() } }
    var endArc : CGFloat = π + π_2 + π_8 { didSet { setNeedsDisplay() } }
    
    var spike : CGFloat? = π_4 { didSet { setNeedsDisplay() } }
    var spikeWidth: CGFloat = π_8 { didSet { setNeedsDisplay() } }
    
    public override func pathsForRect(rect: CGRect) -> [UIBezierPath]
    {
        let center = CGPoint(x: CGRectGetMidX(rect), y: CGRectGetMidY(rect))
        
        let radius = ceil(floor(min(rect.width, rect.height))/2)
        
        let path = UIBezierPath()

        let lineWidth = radius / 9

        if let spike = self.spike
        {
            path.addArcWithCenter(center, radius: radius, startAngle: startArc, endAngle: spike - spikeWidth/2, clockwise: true)
            
            let spikeSize = sqrt(2 * pow(radius, 2))
            
            path.addLineToPoint(center + spikeSize * CGPoint(x:cos(spike), y:sin(spike)))
            
            path.addArcWithCenter(center, radius: radius, startAngle: spike + spikeWidth/2, endAngle: endArc, clockwise: true)
        }
        else
        {
            path.addArcWithCenter(center, radius: radius, startAngle: startArc, endAngle: endArc, clockwise: true)
        }
        
        
        path.lineCapStyle = .Round
        path.lineJoinStyle = .Round
        path.lineWidth = lineWidth
        
        let holeAngle = endArc + π_8
        
        let holeCenter = CGPoint(x:center.x + radius * cos(holeAngle), y: center.y + radius * sin(holeAngle))
        
        path.moveToPoint(CGPoint(x: holeCenter.x, y: holeCenter.y - 2 * lineWidth))
        path.addLineToPoint(CGPoint(x: holeCenter.x, y: holeCenter.y + 2 * lineWidth))
        
        path.moveToPoint(CGPoint(x: holeCenter.x - 2 * lineWidth, y: holeCenter.y))
        path.addLineToPoint(CGPoint(x: holeCenter.x + 2 * lineWidth, y: holeCenter.y))
        
        return [path]
    }
}

@IBDesignable
public class IconView: UIView
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
    }
    
    override public func tintColorDidChange()
    {
        super.tintColorDidChange()
        
        if color == nil
        {
            setNeedsDisplay()
        }
    }
    
    override public var bounds : CGRect { didSet { setNeedsDisplay() } }
    
    @IBInspectable
    public var sizeFactor: CGFloat = 1
    
    @IBInspectable
    public var lineWidth: CGFloat = 1 { didSet { setNeedsDisplay() } }
    
    @IBInspectable
    public var color: UIColor? = nil { didSet { setNeedsDisplay() } }
    
    public func pathsForRect(rect: CGRect) -> [UIBezierPath]
    {
        return []
    }
    
    override public func drawRect(rect: CGRect)
    {
        (color ?? tintColor).setStroke()
        
        let center = bounds.center
        
        var diameter = floor(min(bounds.width, bounds.height))
        
        let linewidth = ceil(max(1, lineWidth, diameter / 18))
        
        diameter -= linewidth
        
        for path in pathsForRect(CGRect(center: center, size: CGSize(widthAndHeight: diameter)))
        {
            path.lineWidth = linewidth
            path.stroke()
        }
    }
    
    // MARK: - IB
    
    public override func prepareForInterfaceBuilder()
    {
        setup()
    }
    
    public override func intrinsicContentSize() -> CGSize
    {
        return CGSize(widthAndHeight: 30)
    }
}
