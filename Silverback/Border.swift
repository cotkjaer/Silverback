//
//  Border.swift
//  Silverback
//
//  Created by Christian Otkjær on 22/10/15.
//  Copyright © 2015 Christian Otkjær. All rights reserved.
//
import UIKit

public enum BorderType
{
    case Circle, Ellipse, SuperEllipse, Square, Rectangle, RoundedSquare(CGFloat)
    
    func pathForBounds(bounds: CGRect) -> UIBezierPath
    {
        switch self
        {
        case .Circle:
            
            let diameter = min(bounds.width, bounds.height) 
            
            return UIBezierPath(ovalInRect: CGRect(center: bounds.center, size: CGSize(widthAndHeight: diameter)))
            
        case .Ellipse:
            
            return UIBezierPath(ovalInRect: bounds)
            
        case .SuperEllipse:
            
            return UIBezierPath(superEllipseInRect: bounds)
            
        case .Rectangle:
            
            return UIBezierPath(rect: bounds)
            
        case .Square:
            
            let diameter = min(bounds.width, bounds.height)
            
            return UIBezierPath(rect: CGRect(center: bounds.center, size: CGSize(widthAndHeight: diameter)))
            
        case .RoundedSquare(let cornerRadius):
            
            let maxRadius = min(bounds.width, bounds.height) / 2
            
            return UIBezierPath(roundedRect: bounds, cornerRadius: min(cornerRadius, maxRadius))
        }
    }
    
    public func imageForSize(size: CGSize, color : UIColor = UIColor.blackColor()) -> UIImage
    {
        let bounds = CGRect(origin: CGPointZero, size: size)
        
        let path = pathForBounds(bounds)
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        
        defer { UIGraphicsEndImageContext() }
        
        color.setFill()
        
        path.fill()
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}

public class BorderMaskLayer : CAShapeLayer
{
    public var type: BorderType = .Circle
    
    override public var frame : CGRect { didSet { updatePath() } }

    func updatePath()
    {
        fillColor = CGColor.blackColor()
        path = type.pathForBounds(frame).CGPath
    }
    
    override public init()
    {
        super.init()
    }
    
    public init(type: BorderType)
    {
        super.init()
        self.type = type
    }
    
    override public init(layer: AnyObject)
    {
        super.init(layer: layer)
        
        if let borderLayer = layer as? BorderMaskLayer
        {
            type = borderLayer.type
        }
    }
    
    required public init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        updatePath()
    }
}

public enum BorderWidth
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

// MARK: - CustomDebugStringConvertible

extension BorderWidth : CustomDebugStringConvertible
{
    public var debugDescription : String {
    
        switch self
        {
        case .Absolute(let width):
            return "Absolute(\(width))"
            
        case .Relative(let factor):
            return "Relative(\(factor))"
            
        case .None:
            return "None = Absolute(0)"
            
        case .Thin:
            return "Thin = Absolute(1)"
            
        case .Normal:
            return "Normal = Absolute(2)"
            
        case .Thick:
            return "Thick = Absolute(5)"
            
        }
    }
}

//MARK: - Equatable

extension BorderWidth : Equatable
{
}

public func == (lhs: BorderWidth, rhs:BorderWidth) -> Bool
{
    switch (lhs, rhs)
    {
    case (.Absolute(let wl), .Absolute(let wr)):
        return wl == wr
        
    case (.Relative(let fl), .Relative(let fr)):
        return fl == fr
        
    case (.None, .None):
        return true
        
    case (.Thin, .Thin):
        return true
        
    case (.Normal, .Normal):
        return true
        
    case (.Thick, .Thick):
        return true
        
    default:
        return false
    }
}
