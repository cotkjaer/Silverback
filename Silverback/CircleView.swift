//
//  CircleView.swift
//  Spellcast
//
//  Created by Christian Otkjær on 29/09/15.
//  Copyright © 2015 Christian Otkjær. All rights reserved.
//

import UIKit

@IBDesignable
public class CircleView: UIView
{
    public var borderWidth = BorderWidth.Normal { didSet { updateBorder() } }
    
    override public var bounds: CGRect { didSet { updateLayerCornerRadius() } }
    
    private func setup()
    {
        updateLayerBorderColor()
        updateLayerCornerRadius()
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
    
    override public func tintColorDidChange()
    {
        super.tintColorDidChange()
        borderColor = tintColor
    }
    
    private func updateLayerCornerRadius()
    {
        roundCorners()
        let radius = min(bounds.size.width, bounds.size.height) / 2
        
        layer.cornerRadius = radius
        layer.borderWidth = borderWidth.widthForRadius(radius)
    }
    
    private func updateLayerBorderColor()
    {
        layer.borderColor = (borderColor ?? tintColor).CGColor
    }
    
    func updateBorder()
    {
        updateLayerBorderColor()
        updateLayerCornerRadius()
    }
}

public class SuperEllipseView : UIView
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
        let mask = BorderMaskLayer(type: .SuperEllipse)
        mask.frame = bounds
        
        layer.mask = mask
    }
    
    override public var bounds: CGRect { didSet { updateMask() } }
    
    func updateMask()
    {
        layer.mask?.frame = bounds
    }
}
