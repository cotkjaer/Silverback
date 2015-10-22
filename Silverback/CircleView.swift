//
//  CircleView.swift
//  Spellcast
//
//  Created by Christian Otkjær on 29/09/15.
//  Copyright © 2015 Christian Otkjær. All rights reserved.
//

import UIKit

class CircleView: UIView
{
    enum BorderWidth
    {
        case Relative(CGFloat)
        case Absolute(CGFloat)
        case None
        case Thin
        case Normal
        case Thick
        
        func widthForRadius(radius: CGFloat) -> CGFloat
        {
            var borderWidth : CGFloat = 0
            
            let scale = UIScreen.mainScreen().scale

            switch self
            {
            case .Absolute(let width):
                borderWidth = max(1/scale, min(radius, width))
                
            case .Relative(let factor):
                borderWidth = max(1/scale, min(radius, radius*factor))
                
            case .None:
                borderWidth = 0
                
            case .Thin:
                borderWidth = 1
                
            case .Normal:
                borderWidth = 2
                
            case .Thick:
                borderWidth = 5
                
            }
            
            return floor(borderWidth) / scale
        }
    }
    
    var borderWidth = BorderWidth.Normal { didSet { updateBorder() } }
    
    var borderColor :  UIColor? { didSet { updateLayerBorderColor() } }
    
    override var bounds: CGRect { didSet { updateLayerCornerRadius() } }
    
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
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        setup()
    }
    
    override func tintColorDidChange()
    {
        super.tintColorDidChange()
        borderColor = tintColor
    }
    
    private func updateLayerCornerRadius()
    {
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
