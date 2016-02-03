//
//  UIEdgeInsets.swift
//  Silverback
//
//  Created by Christian Otkjær on 10/01/16.
//  Copyright © 2016 Christian Otkjær. All rights reserved.
//

import UIKit

//MARK: - insets

extension UIEdgeInsets
{
    public func inset(rect: CGRect) -> CGRect
    {
        return UIEdgeInsetsInsetRect(rect, self)
    }
}

