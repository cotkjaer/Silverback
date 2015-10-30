//
//  UILabel.swift
//  Silverback
//
//  Created by Christian Otkjær on 30/10/15.
//  Copyright © 2015 Christian Otkjær. All rights reserved.
//

import Foundation

//MARK: - Set Text Animated

extension UILabel
{
    /// crossfades the existing text with the `text` parameters in `duration`seconds
    public func setText(text: String, duration: Double)
    {
        UIView.transitionWithView(self, duration: duration, options: [.TransitionCrossDissolve], animations: { self.text = text }, completion: nil)
    }
}