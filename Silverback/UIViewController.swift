//
//  UIViewController.swift
//  Silverback
//
//  Created by Christian Otkjær on 15/10/15.
//  Copyright © 2015 Christian Otkjær. All rights reserved.
//

import UIKit

//MARK: - On screen

extension UIViewController
{
    func isViewLoadedAndShowing() -> Bool { return isViewLoaded() && view.window != nil }
}

// MARK: - Hierarchy

extension UIViewController
{
    /**
    Ascends the parent-controller hierarchy until a controller of the specified type is encountered
    
    - parameter type: the (super)type of view-controller to look for
    - returns: the first controller in the parent-hierarchy encountered that is of the specified type
    */
    public func closestParentViewControllerOfType<T where T: UIViewController>(type: T.Type) -> T?
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


// MARK: - Hierarchy

extension UIView
{
    /**
     Ascends the superview hierarchy until a controller of the specified type is encountered
     
     - parameter type: the (super)type of view to look for
     - returns: the first superview in the hierarchy encountered that is of the specified type
     */
    public func closestSuperviewOfType<T>(type: T.Type) -> T?
    {
        for var view = superview; view != nil; view = view?.superview
        {
            if let t = view as? T
            {
                return t
            }
        }
        
        return nil
        
//        return (superview as? T) ?? superview?.closestSuperviewOfType(type)
    }
    
    public func subviewsOfType<T>(type: T.Type) -> [T]
    {
        return subviews.reduce(subviews.cast(T), combine: { $0 + $1.subviewsOfType(T) } )
    }
    
    /**
     does a breadth-first search of the subview hierarchy
     
     - parameter type: the (super)type of view to look for
     - returns: an array of views of the specified type
     */
    public func closestSubviewsOfType<T>(type: T.Type) -> [T]
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
    public func firstSubviewOfType<T>(type: T.Type) -> T?
    {
        return closestSubviewsOfType(type).first
    }
}