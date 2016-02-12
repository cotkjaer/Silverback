//
//  UIView.swift
//  Silverback
//
//  Created by Christian Otkjær on 08/12/15.
//  Copyright © 2015 Christian Otkjær. All rights reserved.
//

import UIKit

//MARK: - Shadow

public struct Shadow
{
    var color : UIColor = UIColor.blackColor()
    var offset : CGSize = CGSizeZero
    var opacity : CGFloat = 0.3
    var radius : CGFloat = 1
    
    static let Light = Shadow()
    static let Dark = Shadow(color: UIColor.blackColor(), offset: CGSize(widthAndHeight: 2), opacity: 0.8, radius: 3)
}

extension UIView
{
    @IBInspectable
    public var shadowColor : UIColor?
        {
        set { layer.shadowColor = newValue?.CGColor }
        get { return layer.shadowColor?.uiColor }
    }

    @IBInspectable
    public var shadowOffset : CGSize
        {
        set { layer.shadowOffset = newValue }
        get { return layer.shadowOffset }
    }
    
    @IBInspectable
    public var shadowOpacity : CGFloat
        {
        set { layer.shadowOpacity = Float(newValue) }
        get { return CGFloat(layer.shadowOpacity) }
    }
    
    @IBInspectable
    public var shadowRadius : CGFloat
        {
        set { layer.shadowRadius = newValue }
        get { return layer.shadowRadius }
    }
    
    public var shadow : Shadow
        {
        set
        {
            shadowColor = shadow.color
            shadowOffset = shadow.offset
            shadowOpacity = shadow.opacity
            shadowRadius = shadow.radius
        }
        
        get
        {
            return Shadow(
                color: shadowColor ?? UIColor.clearColor(),
                offset: shadowOffset,
                opacity: shadowOpacity,
                radius: shadowRadius)
        }
    }
}

//MARK: - Corner Radius

extension UIView
{
    @IBInspectable
    public var cornerRadius : CGFloat
    {
    
        get { return layer.cornerRadius }
        set { layer.cornerRadius = abs(CGFloat(Int(newValue * 100)) / 100) }
        
    }
}

//MARK: - Border

public extension UIView
{
    func roundCorners(optionalRadius: CGFloat? = nil) -> CGFloat
    {
        var radius = min(bounds.midX, bounds.midY)
        
        if let requestedRadius = optionalRadius
        {
            radius = min(requestedRadius, radius)
        }
        
        layer.cornerRadius = round(radius * 100) / 100
        
        return layer.cornerRadius
    }
    
    @IBInspectable
    var borderSize : CGFloat
        {
        set { layer.borderWidth = newValue }
        get { return layer.borderWidth }
    }
    
    @IBInspectable
    var borderColor :  UIColor?
        {
        set
        {
            if let color = newValue
            {
                layer.borderColor = color.CGColor
            }
            else
            {
                layer.borderColor = nil
            }
        }
        
        get
        {
            if let cgColor = layer.borderColor
            {
                return UIColor(CGColor: cgColor)
            }
            else
            {
                return nil
            }
        }
    }
}

//MARK: - Radius

public extension UIView
{
    var radius : CGFloat { return min(bounds.width, bounds.height) / 2 }
}

//MARK: - Scrolling

public extension UIView
{
    func anySubViewScrolling() -> Bool
    {
        for scrollView in subviews.cast(UIScrollView)
        {
            if scrollView.dragging || scrollView.decelerating
            {
                return true
            }
        }
        
        for subview in subviews
        {
            if subview.anySubViewScrolling()
            {
                return true
            }
        }
        
        return false
    }
}

// MARK: - Hierarchy

public extension UIView
{
    func addToSuperView(optionalSuperView: UIView?)
    {
        if superview != optionalSuperView
        {
            removeFromSuperview()
            
            optionalSuperView?.addSubview(self)
        }
    }
    
    var superviews : [UIView]
        {
            var superviews = Array<UIView>()
            
            for var view = superview; view != nil; view = view?.superview
            {
                superviews.append(view!)
            }
            
            return superviews.reverse()
    }
    
    
    /**
     Ascends the superview hierarchy until a view of the specified type is encountered
     
     - parameter type: the (super)type of view to look for
     - returns: the first superview in the hierarchy encountered that is of the specified type
     */
    func closestSuperviewOfType<T>(type: T.Type) -> T?
    {
        for var view = superview; view != nil; view = view?.superview
        {
            if let t = view as? T
            {
                return t
            }
        }
        
        return nil
    }
    
    func subviewsOfType<T>(type: T.Type) -> [T]
    {
        return subviews.reduce(subviews.cast(T), combine: { $0 + $1.subviewsOfType(T) } )
    }
    
    /**
     does a breadth-first search of the subview hierarchy
     
     - parameter type: the (super)type of view to look for
     - returns: an array of views of the specified type
     */
    func closestSubviewsOfType<T>(type: T.Type) -> [T]
    {
        var views = subviews
        
        while !views.isEmpty
        {
            let Ts = views.cast(T)
            
            if !Ts.isEmpty
            {
                return Ts
            }
            
            views = views.flatMap { $0.subviews }
            //            views = views.reduce([]) { $0 + $1.subviews }
        }
        
        return []
    }
    
    /**
     does a breadth-first search of the subview hierarchy
     
     - parameter type: the type of view to look for
     - returns: first view of the specified type found
     */
    func firstSubviewOfType<T>(type: T.Type) -> T?
    {
        return closestSubviewsOfType(type).first
    }
}

//MARK: - First Responder

public extension UIView
{
    func findFirstResponder() -> UIView?
    {
        if isFirstResponder()
        {
            return self
        }
        
        for subview in subviews
        {
            if let fr = subview.findFirstResponder()
            {
                return fr
            }
        }
        
        return nil
    }
}


// MARK: - Frames

public extension UIView
{
    func frameInView(view: UIView) -> CGRect
    {
        return bounds.convert(fromView: self, toView: view)
    }
}

// MARK: - Image

public extension UIView
{
    func snapshot() -> UIImage
    {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0)
        
        defer { UIGraphicsEndImageContext() }
        
        if let context = UIGraphicsGetCurrentContext()
        {
            layer.renderInContext(context)
        }
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}


