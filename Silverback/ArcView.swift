//
//  ArcView.swift
//  Silverback
//
//  Created by Christian Otkjær on 09/12/15.
//  Copyright © 2015 Christian Otkjær. All rights reserved.
//

import UIKit


@IBDesignable
public class ArcView: UIView
{
    @IBInspectable
    public var width : CGFloat
        {
        set { arcLayer.arcWidth = newValue }
        get { return arcLayer.arcWidth }
    }
    
    @IBInspectable
    public var startDegrees: CGFloat
        {
        set { startAngle = degrees2radians(newValue) }
        get { return radians2degrees(startAngle) }
    }
    
    public var startAngle: CGFloat
        {
        set { if clockwise { arcLayer.arcStartAngle = newValue } else { arcLayer.arcEndAngle = newValue } }
        get { return clockwise ? arcLayer.arcStartAngle : arcLayer.arcEndAngle }
    }
    
    @IBInspectable
    public var endDegrees: CGFloat
        {
        set { endAngle = degrees2radians(newValue) }
        get { return radians2degrees(endAngle) }
    }

    public var endAngle: CGFloat
    {
        set { if !clockwise { arcLayer.arcStartAngle = newValue } else { arcLayer.arcEndAngle = newValue } }
        get { return !clockwise ? arcLayer.arcStartAngle : arcLayer.arcEndAngle }
    }

    @IBInspectable
    public var clockwise: Bool = true
        {
        didSet
        {
            if clockwise != oldValue
            {
                swap(&arcLayer.arcStartAngle, &arcLayer.arcEndAngle)
            }
        }
    }
    
    @IBInspectable
    public var color: UIColor = UIColor.blackColor()
        {
        didSet { arcLayer.arcColor = color.CGColor }
    }
    
    // MARK: - Layout
    
    public override func layoutSubviews()
    {
        super.layoutSubviews()
        
        updateArc()
    }
    
    public override func layoutSublayersOfLayer(layer: CALayer)
    {
        super.layoutSublayersOfLayer(layer)
        
        if layer == self.layer
        {
            updateArc()
        }
    }
    
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
        layer.addSublayer(arcLayer)
        arcLayer.arcColor = color.CGColor
        updateArc()
    }
    
    override public var bounds : CGRect { didSet { updateArc() } }
    override public var frame : CGRect { didSet { updateArc() } }
    
    // MARK: - Arc
    
    private let arcLayer = ArcLayer()

    func updateArc()
    {
        arcLayer.frame = bounds
    }
}

// MARK: - CustomDebugStringConvertible

extension ArcView : CustomDebugStringConvertible
{
    override public var debugDescription : String { return super.debugDescription + "<startDegrees = \(startDegrees), endDegrees = \(endDegrees), clockwise = \(clockwise), width = \(width)>" }
}
