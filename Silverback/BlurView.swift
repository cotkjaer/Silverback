//
//  BlurView.swift
//  Silverback
//
//  Created by Christian Otkjær on 06/11/15.
//  Copyright © 2015 Christian Otkjær. All rights reserved.
//

import UIKit


//MARK: - Blur

extension CIImage
{
    public func blurredImage(radius: Double = 10) -> CIImage?
    {
//        let CiBlurContext = CIContext(options: nil)
        let CiBlurFilter = CIFilter(name: "CIGaussianBlur")!

        CiBlurFilter.setValue(radius, forKey: kCIInputRadiusKey)
        CiBlurFilter.setValue(self, forKey: kCIInputImageKey)
        
        return CiBlurFilter.outputImage
    }
}

//extension UIImage
//{
//    public func blurredImage(radius: Double = 10) -> UIImage?
//    {
//        if let ciImage = CIImage(image: self)
//        {
//            
//        }
//
//        if let blurredCiImage = CIImage(image: self).blurredImage(radius: radius, filter: filter)
//        {
//            return UIImage(CGImage: ciContext.createCGImage(blurredCiImage, fromRect: ciImage.extent))
//        }
//        
//        CiBlurFilter.setValue(radius, forKey: kCIInputRadiusKey)
//        CiBlurFilter.setValue(self, forKey: kCIInputImageKey)
//        
//        return CiBlurFilter.outputImage
//    }
//}

public class Blur
{
    var ciContext : CIContext
    var ciFilter : CIFilter
    
    public init()
    {
        ciContext = CIContext(options: nil)
        ciFilter = CIFilter(name: "CIGaussianBlur")!
    }
    
    public func blurImage(image: UIImage, blurRadius: Double = 10) -> UIImage?
    {
        if let ciImage = CIImage(image: image)
        {
            ciFilter.setValue(blurRadius, forKey: kCIInputRadiusKey)//"inputRadius")
            
            ciFilter.setValue(ciImage, forKey: kCIInputImageKey)
            
            if let ciOutputImage = ciFilter.outputImage
            {
                return UIImage(CGImage: ciContext.createCGImage(ciOutputImage, fromRect: ciImage.extent))
            }
        }
        
        return nil
    }
}

//MARK: - Layer

class BlurLayer: CALayer
{
    var layerToBlur : CALayer?
    
    let ciContext = CIContext(options: nil)
    let ciFilter = CIFilter(name: "CIGaussianBlur")!
    
    private func blurLayer(layer: CALayer, blurRadius: Double = 10) -> CGImageRef?
    {
        ciFilter.setValue(blurRadius, forKey: kCIInputRadiusKey)//"inputRadius")
        
        let cgImage : CGImageRef = layer.contents as! CGImageRef
        
        let ciImage = CIImage(CGImage: cgImage, options: nil)
        
        ciFilter.setValue(ciImage, forKey: kCIInputImageKey)
        
        if let ciOutputImage = ciFilter.outputImage
        {
            return ciContext.createCGImage(ciOutputImage, fromRect: ciImage.extent)
        }
        
        return nil
    }
    
    func blur()
    {
        if let layer = layerToBlur
        {
            contents = blurLayer(layer)
        }
    }
}


public class LiveBlurView: UIView
{
    var FPS : Double = 30
    
    let blur = Blur()
    
    let tintLayer = CALayer()
    
    let imageLayer = CALayer()
    var displayLink : CADisplayLink?
    
    // MARK: - Init
    
    func setup()
    {
        clipsToBounds = true
        
        tintLayer.frame = bounds
        tintLayer.opacity = 0.1
        tintLayer.backgroundColor = tintColor.CGColor

        imageLayer.frame = bounds
        
        layer.addSublayer(tintLayer)
        layer.insertSublayer(imageLayer, below: tintLayer)
    }
    
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

    // MARK: - Timt
    
    override public var tintColor: UIColor! { didSet { tintLayer.backgroundColor = tintColor.CGColor } }

    // MARK: - Add to superview
    
    override public func willMoveToSuperview(newSuperview: UIView?)
    {
        super.willMoveToSuperview(newSuperview)

        displayLink?.invalidate()
        
        if newSuperview != nil
        {
            displayLink = CADisplayLink(target: self, selector: Selector("render"))
            displayLink?.frameInterval = Int(ceil(60.0 / min(60.0, max(0.0, FPS))))
            displayLink?.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSRunLoopCommonModes)
        }
        else
        {
            displayLink = nil
        }
    }
    
    override public var bounds : CGRect { didSet { tintLayer.frame = layer.bounds } }
    
    // MARK: - Rendering

    func render()
    {
        if let superview = self.superview
        {
            let visibleRect = CGRectIntersection(frame, superview.bounds)
            
            guard !CGRectIsEmpty(visibleRect) else { return }

            debugPrint("render \(visibleRect)")
            
            let alpha = self.alpha
            self.alpha = 0
            
            UIGraphicsBeginImageContextWithOptions(visibleRect.size, false, 1.0)
            if let context = UIGraphicsGetCurrentContext()
            {
                CGContextTranslateCTM(context, -visibleRect.origin.x, -visibleRect.origin.y)
                
//                superview.drawViewHierarchyInRect(visibleRect, afterScreenUpdates: true)
                
                superview.layer.renderInContext(context)
                layer.contents = blur.blurImage(UIGraphicsGetImageFromCurrentImageContext(), blurRadius: 2)?.CGImage
                UIGraphicsEndImageContext()
            }
            
            self.alpha = alpha
        }
    }
}
