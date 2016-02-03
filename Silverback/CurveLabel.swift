//
//  CurveLabel.swift
//  Silverback
//
//  Created by Christian Otkjær on 27/11/15.
//  Copyright © 2015 Christian Otkjær. All rights reserved.
//

import UIKit

public class CurveLabel: UILabel
{
    public var curve : CubicBezierCurve? { didSet { updateWarpedText() } }
    
    // MARK: - Warped Text
    
    func updateWarpedText()
    {
        if let c = curve, let t = text
        {
            warpedText = c.warp(t, font: font, textAlignment: textAlignment)
        }
        else
        {
            warpedText = nil
        }
    }
    
    private var warpedText : UIBezierPath? { didSet { updateImage() } }
    
    private let imageView = UIImageView(frame: CGRectZero)
    
    private func updateImage()
    {
        if let wt = warpedText, let fontBounds = curve?.approximateBoundsForFont(font)
        {
            let textBounds = wt.bounds
            
            let frame = textBounds.union(fontBounds).integral
            
            let delta = CGVector(dx: -frame.minX, dy: -frame.minY)
            
            wt.translate(delta)
            
            let lineWidth = CGFloat(1)
//            let frame = wt.bounds.union(c.bounds).insetBy(dx: -lineWidth, dy: -lineWidth).integral
            
//            wt.applyTransform(CGAffineTransformMakeTranslation(1 - frame.minX, -frame.size.height - frame.minY))
//            wt.applyTransform(CGAffineTransformMakeScale(1, -1))

            UIGraphicsBeginImageContextWithOptions(frame.size, false, 0); defer { UIGraphicsEndImageContext() }
            
            
            if let context = UIGraphicsGetCurrentContext()
            {
                // Flip the context coordinates in iOS only.
                CGContextTranslateCTM(context, 0, frame.size.height)
                CGContextScaleCTM(context, 1, -1)
                
                if let bgColor = backgroundColor
                {
                    let bgPath = UIBezierPath(rect: CGRect(origin: CGPointZero, size: frame.size))
                    
                    bgColor.setFill()
                    
                    bgPath.fill()
                }
                
                textColor.setFill()
                //            strokeColor.setStroke()
                
                wt.fill()
                //            path.stroke()
            }
            
            imageView.image = UIGraphicsGetImageFromCurrentImageContext()
        }
        else
        {
            imageView.image = nil
        }
    }
    
    // MARK: - Size
    
    public override func sizeThatFits(size: CGSize) -> CGSize
    {
        if let wt = warpedText, let fontBounds = curve?.approximateBoundsForFont(font)
        {
            return wt.bounds.union(fontBounds).size
        }
        
        return super.sizeThatFits(size)
    }
    
    // MARK: - Text

    public override var text : String? { didSet { updateWarpedText() } }

    // MARK: - Bounds
    
    public override var bounds : CGRect { didSet { updateImage() } }
    
    
    // MARK: - Init
    
    public override init(frame: CGRect)
    {
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup()
    {
        addSubview(imageView)
        imageView.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
    }

    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
