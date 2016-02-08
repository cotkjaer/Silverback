//
//  Color.swift
//  Silverback
//
//  Created by Christian Otkjær on 14/12/15.
//  Copyright © 2015 Christian Otkjær. All rights reserved.
//

import CoreGraphics

public struct RGBA
{
    public var r: CGFloat = 0
    public var g: CGFloat = 0
    public var b: CGFloat = 0
    public var a: CGFloat = 0
    
    public init(r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 1)
    {
        (self.r, self.g, self.b, self.a) = (r,g,b,a)
    }
    
    public init(tuple: (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat))
    {
        self.init(r:tuple.r, g:tuple.g, b: tuple.b, a: tuple.a)
    }
    
    public init(tuple: (r: CGFloat, g: CGFloat, b: CGFloat))
    {
        self.init(r:tuple.r, g:tuple.g, b: tuple.b, a: 1)
    }
}

extension RGBA: CustomStringConvertible, CustomDebugStringConvertible
{
    public var description: String { return "RGBA(\(r), \(g), \(b), \(a))" }
    public var debugDescription: String { return description }
}

// MARK: - Equatable

extension RGBA: Equatable {}

public func ==(lhs: RGBA, rhs: RGBA) -> Bool
{
    return lhs.r == rhs.r && lhs.g == rhs.g && lhs.b == rhs.b && lhs.a == rhs.a
}

public extension RGBA
{
    public var cgColor: CGColor
        {
            return CGColor.color(red: r, green: g, blue: b, alpha: a)
    }
}

// MARK: HSVA

public struct HSVA
{
    public let h: CGFloat
    public let s: CGFloat
    public let v: CGFloat
    public let a: CGFloat
    
    public init(h: CGFloat = 0, s: CGFloat = 0, v: CGFloat = 0, a: CGFloat = 1)
    {
        (self.h, self.s, self.v, self.a) = (h,s,v,a)
    }
    
    public init(tuple: (h: CGFloat, s: CGFloat, v: CGFloat, a: CGFloat))
    {
        self.init(h: tuple.h, s: tuple.s, v: tuple.v, a: tuple.a)
    }
    
    public init(tuple: (h: CGFloat, s: CGFloat, v: CGFloat))
    {
        self.init(h: tuple.h, s: tuple.s, v: tuple.v, a: 1)
    }
}

extension HSVA: CustomStringConvertible, CustomDebugStringConvertible
{
    public var description: String { return "HSVA(\(h), \(s), \(v), \(a))" }
    public var debugDescription: String { return description }
}

extension HSVA: Equatable {
}

public func ==(lhs: HSVA, rhs: HSVA) -> Bool
{
    return lhs.h == rhs.h && lhs.s == rhs.s && lhs.v == rhs.v && lhs.a == rhs.a
}

public extension HSVA
{
    public var cgColor: CGColor
        {
            let rgb = convert(self)
            return rgb.cgColor
    }
}

// MARK: Lerping HSVA

extension HSVA: Lerpable {
    public typealias FactorType = CGFloat
}

public func + (lhs: HSVA, rhs: HSVA) -> HSVA
{
    return HSVA(h: lhs.h + rhs.h, s: lhs.s + rhs.s, v: lhs.v + rhs.v, a: (rhs.a + lhs.a) / 2)
}

public func * (lhs: HSVA, rhs: CGFloat) -> HSVA
{
    return HSVA(h: lhs.h * rhs, s: lhs.s * rhs, v: lhs.v * rhs, a: lhs.a * rhs)
}

public func convert(hsv: HSVA) -> RGBA
{
    var (h, s, v, a) = (hsv.h, hsv.s, hsv.v, hsv.a)
    
    if (s == 0)
    {
        return RGBA(tuple: (v,v,v,a))
    }
    else
    {
        h *= 360
        
        if (h == 360)
        {
            h = 0
        }
        else
        {
            h /= 60
        }
        
        let i = floor(h)
        let f = h - i
        let p = v * (1 - s)
        let q = v * (1 - (s * f))
        let t = v * (1 - (s * (1 - f)))
        
        switch Int(i)
        {
        case 0:
            return RGBA(tuple: (v,t,p,a))
        case 1:
            return RGBA(tuple: (q,v,p,a))
        case 2:
            return RGBA(tuple: (p,v,t,a))
        case 3:
            return RGBA(tuple: (p,q,v,a))
        case 4:
            return RGBA(tuple: (t,p,v,a))
        case 5:
            return RGBA(tuple: (v,p,q,a))
        default:
            fatalError("Cannot convert HSVA to RGBA")
        }
    }
}

public func convert(rgba: RGBA) -> HSVA
{
    let maxRGB = max(rgba.r, rgba.g, rgba.b)
    let minRGB = min(rgba.r, rgba.g, rgba.b)
    let delta = maxRGB - minRGB
    
    var h: CGFloat = 0
    
    let s = maxRGB != 0 ? delta / maxRGB : 0
    let v = maxRGB
    
    if s == 0
    {
        h = 0
    }
    else
    {
        if rgba.r == maxRGB
        {
            h = (rgba.g - rgba.b) / delta
        }
        else if rgba.g == maxRGB
        {
            h = 2 + (rgba.b - rgba.r) / delta
        }
        else if rgba.b == maxRGB
        {
            h = 4 + (rgba.r - rgba.g) / delta
        }
        
        h *= 60
        
        while h < 0
        {
            h += 360
        }
    }
    
    h /= 360
    
    return HSVA(h: h, s: s, v: v, a: rgba.a)
}
