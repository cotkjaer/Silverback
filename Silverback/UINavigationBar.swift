//
//  UINavigationBar.swift
//  Silverback
//
//  Created by Christian Otkjær on 27/01/16.
//  Copyright © 2016 Christian Otkjær. All rights reserved.
//

import UIKit

// MARK: - Title Color

extension UINavigationBar
{
    private func updateTitleTextAttributesFor(key: String, value: AnyObject?)
    {
        var newTitleTextAttributes = titleTextAttributes ?? [:]
        
        newTitleTextAttributes[key] = value
        
        titleTextAttributes = newTitleTextAttributes.isEmpty ? nil : newTitleTextAttributes
    }
    
    public var titleColor: UIColor?
        {
        get
        {
            return titleTextAttributes?[NSForegroundColorAttributeName] as? UIColor
        }
        
        set
        {
            updateTitleTextAttributesFor(NSForegroundColorAttributeName, value: newValue)
        }
    }
    
    public var titleFont: UIFont?
        {
        get
        {
            return titleTextAttributes?[NSFontAttributeName] as? UIFont
        }
        
        set
        {
            updateTitleTextAttributesFor(NSFontAttributeName, value: newValue)
        }
    }
}