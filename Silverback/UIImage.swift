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
        
        drawInRect(CGRect(origin: CGPointZero, size: scaledSize))
        
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
}