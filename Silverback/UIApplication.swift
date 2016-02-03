//
//  UIApplication.swift
//  Silverback
//
//  Created by Christian Otkjær on 16/11/15.
//  Copyright © 2015 Christian Otkjær. All rights reserved.
//

import UIKit

public extension UIApplication
{
    public class func topViewController(base: UIViewController? = UIApplication.sharedApplication().keyWindow?.rootViewController) -> UIViewController?
    {
        if let nav = base as? UINavigationController
        {
            return topViewController(nav.visibleViewController)
        }
        
        if let tab = base as? UITabBarController
        {
            if let selected = tab.selectedViewController
            {
                return topViewController(selected)
            }
        }
        
        if let presented = base?.presentedViewController
        {
            return topViewController(presented)
        }
        
        return base
    }
}

//MARK: - visibleViewControllers

extension UIViewController
{
    public func viewControllersWithVisibleViews() -> [UIViewController]
    {
        if let presented = presentedViewController
        {
            // Assume that a modally presented viewControllers view covers this ones completely
            return presented.viewControllersWithVisibleViews()
        }
        
        if isViewLoadedAndAddedToWindow()
        {
            let childViewControllersWithVisibleViews = childViewControllers.filter({ (childViewController) -> Bool in
                
                if childViewController.isViewLoadedAndAddedToWindow()
                {
                    return view.bounds.intersects(view.convertRect(childViewController.view.bounds, fromView: childViewController.view))
                }
                
                return false
            })
            
            // Assume that all the childViewControllers views combined do not cover this ones completely
            return [self] + childViewControllersWithVisibleViews.flatMap{ $0.viewControllersWithVisibleViews() }
        }
        
        return []
    }

    public func isViewLoadedAndAddedToWindow() -> Bool
    {
        if isViewLoaded()
        {
            if view.window != nil
            {
                return true
            }
        }
        
        return false
    }
    
    public var visibleViewControllers : [UIViewController] { return presentedViewController?.visibleViewControllers ?? [self] + childViewControllers.flatMap({ $0.visibleViewControllers }) }
}

//MARK: - UINavigationController

extension UINavigationController
{
    override public var visibleViewControllers : [UIViewController] { return visibleViewController?.visibleViewControllers ?? super.visibleViewControllers }
}

//MARK: - UITabBarController

extension UITabBarController
{
    override public var visibleViewControllers : [UIViewController] { return selectedViewController?.visibleViewControllers ?? super.visibleViewControllers }
}

//MARK: - UISplitViewController

extension UISplitViewController
{
    override public var visibleViewControllers : [UIViewController]
        {
            if collapsed
            {
                return viewControllers.first?.visibleViewControllers ?? super.visibleViewControllers
            }
            
            switch displayMode
            {
            case .AllVisible, .PrimaryOverlay, .Automatic:
                return viewControllers.flatMap { $0.visibleViewControllers }
            case .PrimaryHidden:
                return viewControllers.last?.visibleViewControllers ?? super.visibleViewControllers
                
            }
    }
}

extension UIApplication
{
    /// returns: the viewcontrollers currently displyed for this application
    
    public var visibleViewControllers : [UIViewController] { return keyWindow?.rootViewController?.visibleViewControllers ?? [] }
    
    
    
//    public class func visibleViewControllers(base: UIViewController? = UIApplication.sharedApplication().keyWindow?.rootViewController) -> [UIViewController]
//    {
//        if let navigationController = base as? UINavigationController
//        {
//            return visibleViewControllers(navigationController.visibleViewController)
//        }
//        
//        if let tabBarController = base as? UITabBarController
//        {
//            if let selected = tabBarController.selectedViewController
//            {
//                return visibleViewControllers(selected)
//            }
//        }
//        if let presented = base?.presentedViewController {
//            return topViewController(base: presented)
//        }
//        return base
//    }
}