//
//  UIFont.swift
//  Silverback
//
//  Created by Christian Otkjær on 30/10/15.
//  Copyright © 2015 Christian Otkjær. All rights reserved.
//

import UIKit

//MARK: - UIFont

extension String
{
    public func fontToFitSize(
        sizeToFit: CGSize,
        font: UIFont,
        lineBreakMode: NSLineBreakMode,
        minSize: CGFloat = 1,
        maxSize: CGFloat = 512) -> UIFont
    {
        let fontSize = font.pointSize

        guard minSize < maxSize - 1 else { return font.fontWithSize(minSize) }
        
        let paragraphStyle = NSMutableParagraphStyle()
        
        paragraphStyle.lineBreakMode = lineBreakMode
        
        let attributes = [ NSParagraphStyleAttributeName:paragraphStyle, NSFontAttributeName:font]
        
        let aText = NSAttributedString(string: self, attributes: attributes)
        
        
        let expectedSize = aText.boundingRectWithSize(sizeToFit, options: [ NSStringDrawingOptions.UsesLineFragmentOrigin ], context: nil).size
        
        debugPrint("sizeToFit: \(sizeToFit), expectedSize: \(expectedSize)")
        
        if expectedSize.width > sizeToFit.width || expectedSize.height > sizeToFit.height
        {
            
            
            if fontSize == minSize
            {
                return font
            }
            else if fontSize < minSize
            {
                return font.fontWithSize(minSize)
            }
            
            let newFontSize = floor((fontSize + minSize) / 2)
            
            return fontToFitSize(sizeToFit, font: font.fontWithSize(newFontSize), lineBreakMode: lineBreakMode, minSize: minSize, maxSize: fontSize)
        }
        else if sizeToFit.fits(expectedSize)
        {
            if fontSize >= maxSize
            {
                return font.fontWithSize(maxSize)
            }
            
            let newFontSize = ceil((fontSize + maxSize) / 2)
            
             return fontToFitSize(sizeToFit, font: font.fontWithSize(newFontSize), lineBreakMode: lineBreakMode, minSize: fontSize, maxSize: maxSize)
        }
        else
        {
            return font
        }
    }
}

