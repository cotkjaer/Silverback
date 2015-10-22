//
//  UIImage.swift
//  SilverbackFramework
//
//  Created by Christian Otkjær on 20/04/15.
//  Copyright (c) 2015 Christian Otkjær. All rights reserved.
//

import UIKit

public extension UIImage
{
    class func imageFromColor(color: UIColor) -> UIImage
    {
        return color.image
    }
    
    func imageScaledToSize(scaledSize: CGSize) -> UIImage
    {
        // In next line, pass 0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
        // Pass 1 to force exact pixel size.
        UIGraphicsBeginImageContextWithOptions(scaledSize, false, 0)
        
        let frame = CGRect(origin: CGPointZero, size: scaledSize)
        
        drawInRect(frame)
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return scaledImage
    }
    
    private func compositeImage(path:UIBezierPath, usingBlendMode blend: CGBlendMode) -> UIImage
    {
        let pathBounds = path.bounds
        
        path.applyTransform(CGAffineTransformMakeTranslation(-pathBounds.origin.x, -pathBounds.origin.y))
        
        // Create Image context the size of the paths bounds
        UIGraphicsBeginImageContextWithOptions(pathBounds.size, false, scale)
        
        // First draw an opaque path...
        UIColor.blackColor().setFill()
        path.fill()
        
        // ...then composite with the image.
        
        self.drawAtPoint(-pathBounds.origin, blendMode: blend, alpha: 1)
        
        // With drawing complete, store the composited image for later use.
        
        let maskedImage = UIGraphicsGetImageFromCurrentImageContext()
        
        // Graphics contexts must be ended manually.
        UIGraphicsEndImageContext();
        
        return maskedImage
    }
    
    func imageByMaskingToAreaInsidePath(maskPath: UIBezierPath) -> UIImage
    {
        return self.compositeImage(maskPath, usingBlendMode: CGBlendMode.SourceIn)
    }
    
    func imageByMaskingToAreaOutsidePath(maskPath: UIBezierPath) -> UIImage
    {
        return self.compositeImage(maskPath, usingBlendMode: CGBlendMode.SourceOut)
    }
    
    func colorizeImageWithColor(color : UIColor) -> UIImage
    {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        
        let area = CGRectMake(0, 0, size.width, size.height)
        
        color.setFill()
        
        UIBezierPath(rect: area).fill()
        
        self.drawAtPoint(CGPointZero, blendMode: CGBlendMode.Multiply, alpha: 1)
        
        //        CGContextScaleCTM(context, 1, -1);
        //    CGContextTranslateCTM(context, 0, -area.size.height);
        //
        //    CGContextSaveGState(context);
        //    CGContextClipToMask(context, area, image.CGImage);
        //
        //    [color set];
        //    CGContextFillRect(context, area);
        //
        //    CGContextRestoreGState(context);
        
        //    CGContextSetBlendMode(context, kCGBlendModeMultiply);
        //
        //    CGContextDrawImage(context, area, image.CGImage);
        
        let colorizedImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return colorizedImage
    }
}
