//
//  UIViewController.swift
//  Silverback
//
//  Created by Christian Otkjær on 15/10/15.
//  Copyright © 2015 Christian Otkjær. All rights reserved.
//

import UIKit

extension UINavigationController
{
    public func popViewControllerWithHandler(completion: ()->())
    {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        popViewControllerAnimated(true)
        CATransaction.commit()
    }
    
    public func pushViewController(viewController: UIViewController, completion: ()->())
    {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        pushViewController(viewController, animated: true)
        CATransaction.commit()
    }
}

//MARK: - Cover View

extension UIViewController
{
    private class CoverView : UIView
    {
        // MARK: - Init
        
        override init(frame: CGRect)
        {
            super.init(frame: frame)
            setup()
        }
        
        required init?(coder aDecoder: NSCoder)
        {
            super.init(coder: aDecoder)
            setup()
        }
        
        let activityView = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
        
        func setup()
        {
            backgroundColor = UIColor(white: 0, alpha: 0.25)
            alpha = 0
            autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
            
            activityView.startAnimating()
            addSubview(activityView)
        }
        
        
        private override func layoutSubviews()
        {
            super.layoutSubviews()
            
            activityView.center = bounds.center
        }
    }
    
    public func cover(duration: Double = 0.25, hideActivityView: Bool = false, completion: (() -> ())? = nil)
    {
        guard view.subviewsOfType(CoverView).isEmpty else { return }
        
        let coverView = CoverView(frame: view.bounds)

        coverView.activityView.hidden = hideActivityView
        
        view.addSubview(coverView)
        
        UIView.animateWithDuration(duration,
            animations: {
                coverView.alpha = 1
            }) { _ in completion?() }

    }
    
    public func uncover(duration: Double = 0.25, completion: (() -> ())? = nil)
    {
        let coverViews = view.subviewsOfType(CoverView)
        
        UIView.animateWithDuration(duration,
            animations: {
            coverViews.forEach { $0.alpha = 0 }
            }) { (completed) -> Void in
                coverViews.forEach { $0.removeFromSuperview() }
                
                completion?()
        }
    }
}

// MARK: - On screen

extension UIViewController
{
    public func isViewLoadedAndShowing() -> Bool { return isViewLoaded() && view.window != nil }
}

// MARK: - Hierarchy

extension UIViewController
{
    /**
    Ascends the parent-controller hierarchy until a controller of the specified type is encountered
    
    - parameter type: the (super)type of view-controller to look for
    - returns: the first controller in the parent-hierarchy encountered that is of the specified type
    */
    public func closestParentViewControllerOfType<T/* where T: UIViewController*/>(type: T.Type) -> T?
    {
        return (parentViewController as? T) ?? parentViewController?.closestParentViewControllerOfType(type)
    }
    
    /**
    does a breadth-first search of the child-viewControllers hierarchy
    
    - parameter type: the (super)type of controller to look for
    - returns: an array of view-controllers of the specified type
    */
    public func closestChildViewControllersOfType<T>(type: T.Type) -> [T]
    {
        var children = childViewControllers
        
        while !children.isEmpty
        {
            let ts = children.cast(T)//mapFilter({ $0 as? T})
            
            if !ts.isEmpty
            {
                return ts
            }
            
            children = children.reduce([]) { $0 + $1.childViewControllers }
        }
        
        return []
    }
    
    /**
    does a breadth-first search of the child-viewControllers hierarchy
    
    - parameter type: the (super)type of controller to look for
    - returns: an array of view-controllers of the specified type
    */
    public func anyChildViewControllersOfType<T>(type: T.Type) -> T?
    {
        var children = childViewControllers
        
        while !children.isEmpty
        {
            let ts = children.cast(T)
            
            if !ts.isEmpty
            {
                return ts.first
            }
            
            children = children.reduce([]) { $0 + $1.childViewControllers }
        }
        
        return nil
    }
}

//MARK: - Brightness

extension UIViewController
{
    var brightnessManager : BrightnessManager { return BrightnessManager.sharedBrightnessManager }
}

public class BrightnessManager
{
    public static func adjustBrightness(animated animated: Bool = true)
    {
        sharedBrightnessManager.adjustBrightness(animated: animated)
    }

    public static var brightness : CGFloat { return sharedBrightnessManager.brightness }
    
    
    private static let sharedBrightnessManager = BrightnessManager()

    private var brightness : CGFloat { return UIScreen.mainScreen().brightness }
    
    private func adjustBrightness(animated animated: Bool = true)
    {
        let preferences = UIApplication.sharedApplication().visibleViewControllers.cast(BrightnessAffecter).map{ $0.brightnessPreferences() }
        
        if !preferences.isEmpty
        {
            let minBrightness = preferences.flatMap { $0.min }.maxElement() ?? 0
            let maxBrightness = preferences.flatMap { $0.max }.minElement() ?? 1

            let preferredBrightnesses = preferences.map { $0.preferred }.filter { $0 >= minBrightness && $0 <= maxBrightness }
            
            var newBrightness = brightness
            
            if let preferredBrightness = preferredBrightnesses.frequencies().first?.0
            {
                newBrightness = preferredBrightness
            }
            else
            {
                newBrightness = min(maxBrightness, max(minBrightness, brightness))
            }
            
            if brightness != newBrightness
            {
                if animated
                {
                    setBrightness(newBrightness, duration: 0.5)
                }
                else
                {
                    UIScreen.mainScreen().brightness = newBrightness
                }
            }
        }
    }
}


public protocol BrightnessAffecter
{
    func brightnessPreferences() -> (min: CGFloat?, preferred: CGFloat, max: CGFloat?)
    
//    var preferredBrightness : CGFloat? { get }
//    var requiredMinimumBrightness : CGFloat? { get }
//    var requiredMaximumBrightness : CGFloat? { get }
}

enum Constraint
{
    case LessThan
    case LessThanOrEqual
    case Equal
    case GreaterThan
    case GreaterThanOrEqual
}
