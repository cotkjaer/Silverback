//
//  WarpedLabel.swift
//  Silverback
//
//  Created by Christian Otkjær on 29/11/15.
//  Copyright © 2015 Christian Otkjær. All rights reserved.
//

import UIKit

@IBDesignable
public class WarpedLabel: UIImageView
{
    @IBInspectable
    public var text: String? { didSet { if oldValue != text { updateImage() } } }
    
    @IBInspectable
    public var font: UIFont = UIFont.systemFontOfSize(17) { didSet { if oldValue != font { updateImage() } } }
    
    @IBInspectable
    public var textAlignment: NSTextAlignment = .Natural { didSet { if oldValue != textAlignment { updateImage() } } }
    
    @IBInspectable
    public var textColor : UIColor? { didSet { if oldValue != textColor { updateImage() } } }

    public var path: UIBezierPath? { didSet { if oldValue != path { updateImage() } } }

    private func createDefaultPath(attrString: NSAttributedString) -> UIBezierPath
    {
        let size = attrString.size()
        
        let path = UIBezierPath()
        path.moveToPoint(CGPoint(x: 0, y: 0))
        path.addLineToPoint(CGPoint(x: size.width, y: 0))
        
        return path
    }
    
    private func approximateBoundsForFont(font: UIFont) -> CGRect
    {
        guard let bounds = path?.cubicBezierCurves().map({ $0.approximateBoundsForFont(font) }) else { return CGRectZero }
        
        guard let firstBounds = bounds.first else { return CGRectZero }
        
        return bounds.reduce(firstBounds) { return $0.union($1) }
    }
    
    private func updateImage()
    {
        if let text = self.text
        {
            let attributedText = NSAttributedString(string: text, attributes: [NSFontAttributeName : font])
            
            let path = self.path ?? createDefaultPath(attributedText)
            
            let warpedTextPath = path.warp(text, font: font, textAlignment: textAlignment)
            
            let fontBounds = approximateBoundsForFont(font)

            let textBounds = warpedTextPath.bounds
                    
            let frame = textBounds.union(fontBounds).integral
                    
            let delta = CGVector(dx: -frame.minX, dy: -frame.minY)
                    
            warpedTextPath.translate(delta)
                    
            let lineWidth = CGFloat(1)
            
            UIGraphicsBeginImageContextWithOptions(frame.size, false, 0)
            defer { UIGraphicsEndImageContext() }
            
            if let context = UIGraphicsGetCurrentContext()
            {
                // Flip the context coordinates in iOS only.
                CGContextTranslateCTM(context, 0, frame.size.height)
                CGContextScaleCTM(context, 1, -1)
                
                (textColor ?? tintColor).setFill()
                
                warpedTextPath.fill()
            }
            
            image = UIGraphicsGetImageFromCurrentImageContext()

        }
        else
        {
            image = nil
        }
    }
}