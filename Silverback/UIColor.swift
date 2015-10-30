//
//  UIColor.swift
//  Silverback
//
//  Created by Christian Otkjær on 06/10/15.
//  Copyright © 2015 Christian Otkjær. All rights reserved.
//

import UIKit

// MARK: - opaque

extension UIColor
{
    var alpha : CGFloat { return rgba.alpha }
    var opaque : Bool { return alpha > 0.9999 }
}

// MARK: - RGB

private let FF = CGFloat(0xFF)

public extension UIColor
{
    convenience init(rgb:UInt)
    {
        let red:CGFloat = CGFloat((rgb & 0xFF0000) >> 16)/FF;
        let green:CGFloat = CGFloat((rgb & 0xFF00) >> 8)/FF;
        let blue:CGFloat = CGFloat(rgb & 0xFF)/FF;
        
        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
    
    convenience init(r:Int, g:Int, b: Int)
    {
        self.init(
            red: CGFloat(r)/FF,
            green: CGFloat(g)/FF,
            blue: CGFloat(b)/FF,
            alpha: 1)
    }
    
    var red : CGFloat { return rgba.red }
    var green : CGFloat { return rgba.green }
    var blue : CGFloat { return rgba.blue }

    var rgb : (red:CGFloat, green:CGFloat, blue:CGFloat) { let tmp = rgba; return (red: tmp.red, green: tmp.green, blue: tmp.blue) }

    var rgba : (red:CGFloat, green:CGFloat, blue:CGFloat, alpha:CGFloat) {
        var red : CGFloat = 0
        var green : CGFloat = 0
        var blue: CGFloat = 0
        var alpha : CGFloat = 0
        
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        return (red, green, blue, alpha)
    }

    var white : CGFloat
        {
            let rgb = self.rgb
        return (rgb.red + rgb.green + rgb.blue) / CGFloat(3)
    }
}

public extension UIColor
{
    var hsba : (CGFloat, CGFloat, CGFloat, CGFloat)? {
        var hue : CGFloat = 0
        var saturation : CGFloat = 0
        var brightness : CGFloat = 0
        var alpha : CGFloat = 0
        
        if getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        {
            return (hue, saturation, brightness, alpha)
        }
        
        return nil
    }
    
    // MARK: - Lighter
    
    var lighterColor : UIColor?
        {
            if let hsba = self.hsba
            {
                return UIColor(hue: hsba.0, saturation: hsba.1, brightness: max(0, min(1,  (1 + hsba.2) / 2)), alpha: hsba.3)
            }
            
            return nil
    }
    
    // MARK: - Darker
    
    var darkerColor : UIColor?
        {
            if let hsba = self.hsba
            {
                return UIColor(hue: hsba.0, saturation: hsba.1, brightness: max(0, min(1, hsba.2 / 2)), alpha: hsba.3)
            }
            
            return nil
    }
    
    func colorWithBrightness(brightness: CGFloat) -> UIColor?
    {
        if let hsba = self.hsba
        {
            return UIColor(hue: hsba.0, saturation: hsba.1, brightness: brightness, alpha: hsba.3)
        }
        
        return nil
    }
}

//MARK: - Image

public extension UIColor
{
    public var image: UIImage
        {
            let rect = CGRectMake(0, 0, 1, 1)
            
            UIGraphicsBeginImageContextWithOptions(rect.size, opaque, 0)
            
            let context = UIGraphicsGetCurrentContext()
            
            CGContextSetFillColorWithColor(context, self.CGColor)
            CGContextFillRect(context, rect)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            return image
    }
}

//MARK: - Random

public extension UIColor
{
    static func random() -> UIColor
    {
        return UIColor(r: Int.random(lower: 0,upper: 256), g: Int.random(lower: 0,upper: 256), b: Int.random(lower: 0,upper: 256))
    }
}