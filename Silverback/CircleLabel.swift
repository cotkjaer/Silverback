//
//  CircleLabel.swift
//  Silverback
//
//  Created by Christian Otkjær on 05/10/15.
//  Copyright © 2015 Christian Otkjær. All rights reserved.
//

import UIKit
import CoreText

@IBDesignable
public class CircleLabel : UILabel
{
    @IBInspectable
    public var anchorAngle : CGFloat = /*π*/ 0 { didSet { setNeedsDisplay() } }
    
    /// if true the bottom of the text points towards the center
    @IBInspectable public var towardsCenter : Bool = false { didSet { setNeedsDisplay() } }
    
    var margin = CGFloatZero
    
    public var maxPointSize = CGFloat(17)
    public var minPointSize = CGFloat(4)
    
    required public init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        maxPointSize = font.pointSize
        minPointSize = ceil(maxPointSize * minimumScaleFactor)
    }
    
    override public init(frame: CGRect)
    {
        super.init(frame: frame)
        self.textAlignment = NSTextAlignment.Center
        
        let s = min(frame.width, frame.height)
        maxPointSize = ceil(s / 6)
        minPointSize = ceil(s / 9)
    }
    
    var textAlignmentMultiplier : CGFloat
        {
            switch self.textAlignment
            {
            case .Center:
                return 0.5
            case .Justified:
                return 0.5
            case .Left:
                return 0.0
            case .Natural:
                return 0.5
            case .Right:
                return 1.0
            }
    }
    
    func findFontPointSize(proposedPointSize: CGFloat) -> CGFloat
    {
        if proposedPointSize <= minPointSize { return minPointSize }
        
        if let font = UIFont(name: self.font.fontName, size: proposedPointSize)
        {
            let diameter = min(bounds.width, bounds.height) - proposedPointSize
            let circumference = diameter * π
            
            let text = self.text ?? self.attributedText?.string ?? ""
            
            if NSAttributedString(string: text, attributes: [NSFontAttributeName: font]).size().width < 0.75 * circumference
            {
                return proposedPointSize
            }
            else
            {
                return findFontPointSize(proposedPointSize - 1)
            }
        }
        
        return min(24, max(4, abs((maxPointSize - minPointSize) / 2)))
    }
    
    override public func drawRect(rect: CGRect)
    {
        let fontPointSize = findFontPointSize(maxPointSize)
        
        if let font = UIFont(name: self.font.fontName, size: fontPointSize)
        {
            let text = self.text ?? self.attributedText?.string ?? ""
            
            let textAttributes = [NSFontAttributeName: font,
                NSForegroundColorAttributeName: self.textColor ?? UIColor.darkTextColor()]
            
            attributedText = NSAttributedString(
                string: text,
                attributes: textAttributes)
            
            let margin : CGFloat = 1// max(self.margin, fontPointSize)
            
            if let context = UIGraphicsGetCurrentContext()
            {
                CGContextSetTextMatrix(context, CGAffineTransformIdentity)
                CGContextTranslateCTM(context, 0, CGRectGetHeight(bounds))
                CGContextScaleCTM(context, 1, -1)
                
                let center = bounds.center
                let textSize = attributedText!.size()
                var position = center
                
                if self.towardsCenter
                {
                    position.y = bounds.height - font.ascender
                }
                else
                {
                    position.y = margin - font.descender
                }
                
                var radius = position.y + (textSize.height / 3) - center.y
                
                CGContextRotateAroundPoint(context, point: center, angle: textSize.width * textAlignmentMultiplier / radius)
                
                CGContextRotateAroundPoint(context, point: center, angle: anchorAngle)// + (towardsCenter ? 0 : π))
                
                for charater in text.characters
                {
                    let glyph = NSAttributedString(string: String(charater), attributes: textAttributes)
                    let glyphSize = glyph.size()
                    
                    radius = position.y + (glyphSize.height / 3) - center.y
                    
                    let line = CTLineCreateWithAttributedString(glyph)
                    CGContextRotateAroundPoint(context, point: center, angle: -glyphSize.width / (2 * radius))
                    
                    let textPoint = CGPoint(x: position.x - (glyphSize.width / 2), y: position.y - (textSize.height - glyphSize.height))
                    
                    CGContextSetTextPosition(context, textPoint.x, textPoint.y)
                    CTLineDraw(line, context)
                    
                    CGContextRotateAroundPoint(context, point: center, angle: -glyphSize.width / (2 * radius))
                }
            }
        }
    }
}
