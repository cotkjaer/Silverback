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
    enum BorderWidth : CGFloat
    {
        case None = 0.0
        case Thin = 1
        case Normal = 2
        case Thick = 5
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
        layer.borderWidth = /*max(1, radius / 20) * UIScreen.mainScreen().scale * */borderWidth.rawValue / UIScreen.mainScreen().scale
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
