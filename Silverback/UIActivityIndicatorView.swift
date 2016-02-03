//
//  UIActivityIndicatorView.swift
//  Silverback
//
//  Created by Christian Otkjær on 01/02/16.
//  Copyright © 2016 Christian Otkjær. All rights reserved.
//

import UIKit

// MARK: - Convenience

extension UIActivityIndicatorView
{
    public convenience init(color: UIColor, animating: Bool = false, hidesWhenStopped: Bool = true)
    {
        self.init(activityIndicatorStyle: .WhiteLarge)
        
        self.color = color

        if animating
        {
            startAnimating()
        }
        
        self.hidesWhenStopped = hidesWhenStopped
    }
}

