//
//  UITextView.swift
//  Silverback
//
//  Created by Christian Otkjær on 10/01/16.
//  Copyright © 2016 Christian Otkjær. All rights reserved.
//

import UIKit

//MARK: - Auto update

extension UITextView
{
    public var preferredHeightForCurrentWidth : CGFloat { return heightThatFits(width: bounds.width) }
    
    public func heightThatFits(width fixedWidth: CGFloat) -> CGFloat
    {
        let boundingSize = CGSize(width: fixedWidth, height: CGFloat.max)
        
        let bestFit = sizeThatFits(boundingSize)
        
        return bestFit.height
        
        //        let fixedWidth = textView.frame.size.width
        //        textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.max))
        //        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.max))
        //        var newFrame = textView.frame
        //        newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
        //        textView.frame = newFrame;
    }
}
