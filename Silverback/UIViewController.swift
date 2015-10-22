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
    func closestParentViewControllerOfType<T where T: UIViewController>(type: T.Type) -> T?
    {
        return (parentViewController as? T) ?? parentViewController?.closestParentViewControllerOfType(type)
    }
    
    /**
    does a breadth-first search of the child-viewControllers hierarchy
    
    - parameter type: the (super)type of controller to look for
    - returns: an array of view-controllers of the specified type
    */
    func closestChildViewControllersOfType<T>(type: T.Type) -> [T]
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
    func anyChildViewControllersOfType<T>(type: T.Type) -> T?
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