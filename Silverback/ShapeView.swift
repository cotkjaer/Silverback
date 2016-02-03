//
//  ShapeView.swift
//  Silverback
//
//  Created by Christian Otkjær on 15/01/16.
//  Copyright © 2016 Christian Otkjær. All rights reserved.
//

import UIKit


@IBDesignable
public class ShapeView: UIView
{
    public enum Shape
    {
        case Circle, Ellipse, SuperEllipse, Pill, Square, RoundedSquare(CGFloat), Rectangle, RoundedRectangle(CGFloat)
        
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
                
            case .Pill:
                let minRadius = min(bounds.width, bounds.height) / 2
                
                return UIBezierPath(roundedRect: bounds, cornerRadius: minRadius)
                
            case .RoundedSquare(let specifiedCornerRadius):
                
                let diameter = min(bounds.width, bounds.height)
                
                let cornerRadius = min(specifiedCornerRadius, diameter / 2)
                
                return UIBezierPath(roundedRect: CGRect(center: bounds.center, size: CGSize(widthAndHeight: diameter)), cornerRadius: cornerRadius)

            case .RoundedRectangle(let specifiedCornerRadius):
                
                let cornerRadius = min(specifiedCornerRadius, min(bounds.width, bounds.height) / 2)
                
                return UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
            }
            
        }
        
        //For Interface builder
        func intrinsicContentSize() -> CGSize
        {
            var height : CGFloat = 60
            
            switch self
            {
            case .Circle:
                return CGSize(widthAndHeight: height)
                
            case .Ellipse:
                return CGSize(width: height * 2, height: height)
                
            case .SuperEllipse:
                return CGSize(width: height * 1.5, height: height)
                
            case .Rectangle:
                return CGSize(width: height * 1.5, height: height)
                
            case .Square:
                return CGSize(widthAndHeight: height)
                
            case .Pill:
                return CGSize(width: height * 2, height: height)
                
            case .RoundedSquare(let cornerRadius):
                
                return CGSize(widthAndHeight: max(height, cornerRadius * 2))
                
            case .RoundedRectangle(let cornerRadius):
                height = max(cornerRadius * 2, height)
                
                return CGSize(width: height * 1.5, height: height)
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

    @IBInspectable
    public var color: UIColor = UIColor.clearColor() { didSet { shapeLayer.fillColor = color.CGColor } }
    
    public var shape: Shape = .Rectangle { didSet { setNeedsLayout() } }
    
    override public var bounds : CGRect { didSet { setNeedsLayout() } }
    
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
    
    let shapeLayer = CAShapeLayer()
    
    func setup()
    {
        shapeLayer.fillColor = color.CGColor
        shapeLayer.path = shape.pathForBounds(bounds).CGPath
        
        layer.addSublayer(shapeLayer)
    }

    override public var backgroundColor: UIColor?
        {
        set { color = newValue ?? UIColor.clearColor() }
        get { return UIColor.clearColor() }
    }

    public override func layoutSubviews()
    {
        super.layoutSubviews()
        
        shapeLayer.path = shape.pathForBounds(bounds).CGPath
    }
    
    public override func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool
    {
        return super.pointInside(point, withEvent: event) && (shapeLayer.path?.contains(point) == true)
    }
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
}

// MARK: - Interface Builder

extension ShapeView
{
    override public func intrinsicContentSize() -> CGSize
    {
        return shape.intrinsicContentSize()
//        return CGSize(width: UIViewNoIntrinsicMetric, height: UIViewNoIntrinsicMetric)
    }
    
    override public func prepareForInterfaceBuilder()
    {
        setup()
    }
}

// MARK: - CustomDebugStringConvertible

extension ShapeView : CustomDebugStringConvertible
{
    override public var debugDescription : String { return super.debugDescription + ", shape: \(shape), color: \(color)"  }

    override public var description : String { return super.description + ", shape: \(shape), color: \(color)"  }
}

/// Normally setting the backgroundColor is enough, but not when rearranging UITableViewCells
@IBDesignable
public class ColoredView : UIView
{
    @IBInspectable
    public var color: UIColor = UIColor.blackColor() { didSet { setNeedsDisplay() } }
    
    override public var bounds : CGRect { didSet { setNeedsDisplay() } }
    
    public override func drawRect(rect: CGRect)
    {
        color.set()
        
        
        if layer.cornerRadius > 0
        {
            let path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
            
            path.fill()
        }
        else
        {
            CGContextSetShouldAntialias(UIGraphicsGetCurrentContext(), true)
            CGContextFillRect(UIGraphicsGetCurrentContext(), bounds)
        }
        
        //        super.drawRect(rect)
    }
}



