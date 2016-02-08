//
//  UIImage.swift
//  SilverbackFramework
//
//  Created by Christian Otkjær on 20/04/15.
//  Copyright (c) 2015 Christian Otkjær. All rights reserved.
//

import UIKit

// MARK: - Save

extension UIImage
{
    public func savePNGToFile(fullFilePath: String)
    {
        UIImagePNGRepresentation(self)?.writeToFile(fullFilePath, atomically:false)
    }
    
    private func save(optionalData: NSData?, basefilename: String, ext: String) -> Bool
    {
        if let URL = NSFileManager.documentURLFor(basefilename, fileExtension: ext)
        {
            return optionalData?.writeToURL(URL, atomically: true) ?? false
        }
        
        return false
    }
    
    public func saveAsPNG(basefilename: String) -> Bool
    {
        return save(UIImagePNGRepresentation(self), basefilename: basefilename, ext: "png")
    }
    
    public func saveAsJPG(basefilename: String, compressionQuality: CGFloat = 0.8) -> Bool
    {
        return save(UIImageJPEGRepresentation(self, compressionQuality), basefilename: basefilename, ext: "jpg")
    }
}


//MARK: - Tint

extension UIImage
{
    public func tintedGradientImageWithColor(tintColor: UIColor) -> UIImage
    {
        return tintedImageWithColor(tintColor, blendingMode: .Overlay)
    }
    
    public func tintedImageWithColor(tintColor: UIColor) -> UIImage
    {
        return tintedImageWithColor(tintColor, blendingMode: .DestinationIn)
    }
    
    private func tintedImageWithColor(tintColor: UIColor, blendingMode blendMode: CGBlendMode) -> UIImage
    {
        let bounds = CGRect(origin: CGPointZero, size: size)
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0)

        defer { UIGraphicsEndImageContext() }
        
        tintColor.setFill()
        
        UIRectFill(bounds)
        
        drawInRect(bounds, blendMode: blendMode, alpha: 1)
        
        if blendMode != .DestinationIn
        {
            drawInRect(bounds, blendMode: .DestinationIn, alpha: 1)
        }
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}

// MARK: - Scale

extension UIImage
{
    public func imageScaledToSize(scaledSize: CGSize) -> UIImage
    {
        // In next line, pass 0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
        // Pass 1 to force exact pixel size.
        UIGraphicsBeginImageContextWithOptions(scaledSize, false, 0)
        defer { UIGraphicsEndImageContext() }
        
        let frame = CGRect(origin: CGPointZero, size: scaledSize)
        
        drawInRect(frame)
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    private func compositeImage(path:UIBezierPath, usingBlendMode blend: CGBlendMode) -> UIImage
    {
        let pathBounds = path.bounds
        
        path.applyTransform(CGAffineTransformMakeTranslation(-pathBounds.origin.x, -pathBounds.origin.y))
        
        // Create Image context the size of the paths bounds
        UIGraphicsBeginImageContextWithOptions(pathBounds.size, false, scale)
        defer { UIGraphicsEndImageContext() }

        // First draw an opaque path...
        UIColor.blackColor().setFill()
        path.fill()
        
        // ...then composite with the image.
        
        drawAtPoint(-pathBounds.origin, blendMode: blend, alpha: 1)
        
        // With drawing complete, store the composited image for later use.
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    public func imageByMaskingToAreaInsidePath(maskPath: UIBezierPath) -> UIImage
    {
        return compositeImage(maskPath, usingBlendMode: CGBlendMode.SourceIn)
    }
    
    public func imageByMaskingToAreaOutsidePath(maskPath: UIBezierPath) -> UIImage
    {
        return compositeImage(maskPath, usingBlendMode: CGBlendMode.SourceOut)
    }
    
//    func colorizeImageWithColor(color : UIColor) -> UIImage
//    {
//        UIGraphicsBeginImageContextWithOptions(size, false, scale)
//        
//        let area = CGRectMake(0, 0, size.width, size.height)
//        
//        color.setFill()
//        
//        UIBezierPath(rect: area).fill()
//        
//        drawAtPoint(CGPointZero, blendMode: CGBlendMode.Multiply, alpha: 1)
//        
//        //        CGContextScaleCTM(context, 1, -1);
//        //    CGContextTranslateCTM(context, 0, -area.size.height);
//        //
//        //    CGContextSaveGState(context);
//        //    CGContextClipToMask(context, area, image.CGImage);
//        //
//        //    [color set];
//        //    CGContextFillRect(context, area);
//        //
//        //    CGContextRestoreGState(context);
//        
//        //    CGContextSetBlendMode(context, kCGBlendModeMultiply);
//        //
//        //    CGContextDrawImage(context, area, image.CGImage);
//        
//        let colorizedImage = UIGraphicsGetImageFromCurrentImageContext()
//        
//        UIGraphicsEndImageContext()
//        
//        return colorizedImage
//    }
//    
//    func imageGreyScale() -> UIImage?
//    {
//        let imageRect = CGRectMake(0, 0, size.width, size.height)
//        
//        let greyContext = CGBitmapContextCreate(
//            nil, Int(size.width * scale), Int(size.height * scale),
//            8, 0,
//            CGColorSpaceCreateDeviceGray(),
//            CGBitmapInfo(rawValue: CGImageAlphaInfo.None.rawValue).rawValue
//        )
//        
//        let alphaContext = CGBitmapContextCreate(
//            nil, Int(size.width*scale), Int(size.height*scale),
//            8, 0,
//            nil,
//            CGBitmapInfo(rawValue: CGImageAlphaInfo.Only.rawValue).rawValue
//        )
//        
//        CGContextScaleCTM(greyContext, scale, scale)
//        CGContextScaleCTM(alphaContext, scale, scale)
//        
//        CGContextDrawImage(greyContext, imageRect, CGImage)
//        CGContextDrawImage(alphaContext, imageRect, CGImage)
//        
//        let greyImage = CGBitmapContextCreateImage(greyContext)
//        let maskImage = CGBitmapContextCreateImage(alphaContext)
//        
//        if let combinedImage = CGImageCreateWithMask(greyImage, maskImage)
//        { return UIImage(CGImage: combinedImage) }
//        
//        return nil
//    }
//    
//    func imageWithOverlayTint(tintColor: UIColor) -> UIImage?
//    {
//        if let greyImage = imageGreyScale()
//        {
//            UIGraphicsBeginImageContextWithOptions(size, false, 0)
//            let bounds = CGRectMake(0, 0, size.width, size.height)
//            greyImage.drawInRect(bounds)
//            tintColor.setFill()
//            UIRectFillUsingBlendMode(bounds, .Overlay)
//            greyImage.drawInRect(bounds, blendMode: .DestinationIn, alpha: 1.0)
//            let tintedImage = UIGraphicsGetImageFromCurrentImageContext()
//            UIGraphicsEndImageContext()
//            return tintedImage
//        }
//        
//        return nil
//    }
//    
//    public func tintedImageWithColor(tintColor: UIColor) -> UIImage
//    {
//        // It's important to pass in 0 to this function to draw the image to the scale of the screen
//        UIGraphicsBeginImageContextWithOptions(size, false, 0)
//        
//        defer { UIGraphicsEndImageContext() }
//        
//        tintColor.setFill()
//        let bounds = CGRectMake(0, 0, size.width, size.height)
//        UIRectFill(bounds)
//        drawInRect(bounds, blendMode:.DestinationIn, alpha: 1)
//        
//        return UIGraphicsGetImageFromCurrentImageContext()
//    }
    
}