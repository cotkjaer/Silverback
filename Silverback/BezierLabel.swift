//
//  BezierLabel.swift
//  Silverback
//
//  Created by Christian Otkjær on 24/11/15.
//  Copyright © 2015 Christian Otkjær. All rights reserved.
//

import UIKit

public class BezierLabel: UILabel
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
        //TODO
    }

    /// The path the text should follow
    var path: UIBezierPath?
    
    /// The possible orthogonal alignments the text can have with respect to the path
    enum OrthogonalAlignment { case Centered, Baseline, Under, Over }
    
    /// The orthogonal alignment of the text on the path
    var orthogonalAlignment = OrthogonalAlignment.Baseline
    
    internal func preferredSize() -> CGSize
    {
        let copy = self
        
        copy.sizeToFit()
        
        return copy.bounds.size
    }
    
    override public func sizeToFit()
    {
        if let path = self.path
        {
            var insets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)

            switch orthogonalAlignment
            {
            case .Baseline:
                insets.top = font.ascender
                insets.bottom = font.descender
                
            case .Under:
                insets.bottom = font.ascender + font.descender
                
            case .Over:
                insets.top = font.ascender + font.descender
                
            case .Centered:
                insets.top = (font.ascender + font.descender) / 2
                insets.bottom = insets.top
            }
            
            self.bounds = UIEdgeInsetsInsetRect(path.bounds, insets)
        }
    }
    
    override public func sizeThatFits(size: CGSize) -> CGSize
    {
        let preferredSize = self.preferredSize()
        
        if preferredSize.height <= size.height && preferredSize.width <= size.width
        {
            return preferredSize
        }
        
        let factor = min(preferredSize.width / size.width, preferredSize.height / size.height)
        
        return preferredSize * factor
    }
    
    func draw(text text: String, attributes: [String: AnyObject], x: CGFloat, y: CGFloat, context: CGContextRef) -> CGSize
    {
        let attributedString = NSAttributedString(string: text, attributes: attributes)
        
        let textSize = text.sizeWithAttributes(attributes)
        
        // y: Add font.descender (its a negative value) to align the text at the baseline
        let textPath    = CGPathCreateWithRect(CGRect(x: x, y: y + font.descender, width: ceil(textSize.width), height: ceil(textSize.height)), nil)
        let frameSetter = CTFramesetterCreateWithAttributedString(attributedString)
        let frame       = CTFramesetterCreateFrame(frameSetter, CFRange(location: 0, length: attributedString.length), textPath, nil)
        
        CTFrameDraw(frame, context)
        
        return textSize
    }
    
    override public func drawRect(rect: CGRect)
    {
        if let path = self.path
        {
            textColor.setStroke()
            path.stroke()
        }
        else if let text = self.text
        {
            
            if let context = UIGraphicsGetCurrentContext()
            {
                UIColor(white: 0.0, alpha: 0.2).setStroke()

                // Flip the context coordinates in iOS only.
                CGContextTranslateCTM(context, 0, self.bounds.size.height);
                CGContextScaleCTM(context, 1.0, -1.0);
                
                // Set the text matrix.
                CGContextSetTextMatrix(context, CGAffineTransformIdentity)
                
                let characters = text.characters
                
                var point = CGPointZero
                
                let attributes : [String: AnyObject] = [
                    NSForegroundColorAttributeName : textColor.CGColor,
                    NSFontAttributeName : font
                ]
                for character in characters
                {
                    let c = "\(character)"
 
                    var size = c.sizeWithFont(font)

                    UIBezierPath(rect: CGRect(origin: point, size: size)).stroke()

                    size = draw(text: c, attributes: attributes, x: point.x, y: point.y, context: context)
                    
                    UIBezierPath(rect: CGRect(origin: point, size: size)).stroke()
                    
                    point.x += size.width
                }
            }
            else
            {
                super.drawRect(rect)
            }
        }
    }

}
