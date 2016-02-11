//
//  CGColor.swift
//  Silverback
//
//  Created by Christian Otkjær on 14/12/15.
//  Copyright © 2015 Christian Otkjær. All rights reserved.
//


import CoreGraphics

import UIKit

//MARK: - UIColor

extension CGColor
{
    public var uiColor : UIColor { return UIColor(CGColor: self) }
}

// MARK: - CustomStringConvertible, CustomDebugStringConvertible

extension CGColor: CustomStringConvertible, CustomDebugStringConvertible
{
    public var description: String { return CFCopyDescription(self) as String }
    public var debugDescription: String { return CFCopyDescription(self) as String }
}

// MARK: - Alpha

public extension CGColor
{
    public var alpha: CGFloat { return CGColorGetAlpha(self) }
    
    public func withAlpha(alpha: CGFloat) -> CGColor
    {
        return CGColorCreateCopyWithAlpha(self, alpha)!
    }
}

extension CGColor
{
    public class func color(colorSpace colorSpace: CGColorSpace, components: [CGFloat]) -> CGColor
    {
        return components.withUnsafeBufferPointer
        {
            (buffer: UnsafeBufferPointer<CGFloat>) -> CGColor! in
            return CGColorCreate(colorSpace, buffer.baseAddress)
        }
    }
    
    public class func color(red red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat = 1.0) -> CGColor
    {
        return UIColor(red: red, green: green, blue: blue, alpha: alpha).CGColor
    }
    
    public class func color(white white: CGFloat, alpha: CGFloat = 1.0) -> CGColor
    {
        return UIColor(white: white, alpha: alpha).CGColor
    }
    
    public class func color(hue hue: CGFloat, saturation: CGFloat, brightness: CGFloat, alpha: CGFloat) -> CGColor
    {
        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha).CGColor
    }
}

extension CGColor
{
    public var colorSpace: CGColorSpaceRef { return CGColorGetColorSpace(self)! }
    
    public class func blackColor() -> CGColor { return UIColor.blackColor().CGColor }
    public class func darkGrayColor() -> CGColor { return UIColor.darkGrayColor().CGColor }
    public class func lightGrayColor() -> CGColor { return UIColor.lightGrayColor().CGColor }
    public class func whiteColor() -> CGColor { return UIColor.whiteColor().CGColor }
    public class func grayColor() -> CGColor { return UIColor.grayColor().CGColor }
    public class func redColor() -> CGColor { return UIColor.redColor().CGColor }
    public class func greenColor() -> CGColor { return UIColor.greenColor().CGColor }
    public class func blueColor() -> CGColor { return UIColor.blueColor().CGColor }
    public class func cyanColor() -> CGColor { return UIColor.cyanColor().CGColor }
    public class func yellowColor() -> CGColor { return UIColor.yellowColor().CGColor }
    public class func orangeColor() -> CGColor { return UIColor.orangeColor().CGColor }
    public class func purpleColor() -> CGColor { return UIColor.purpleColor().CGColor }
    public class func brownColor() -> CGColor { return UIColor.brownColor().CGColor }
    public class func clearColor() -> CGColor { return UIColor.clearColor().CGColor }
}