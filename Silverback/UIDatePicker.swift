//
//  UIDatePicker.swift
//  Silverback
//
//  Created by Christian Otkjær on 10/11/15.
//  Copyright © 2015 Christian Otkjær. All rights reserved.
//

import UIKit

//MARK: - Text Color

extension UIDatePicker
{
    public var titlesColor: UIColor?
        {
        set { setValue(tintColor, forKey: "textColor") }
        get { return valueForKey("textColor") as? UIColor }
    }
}
