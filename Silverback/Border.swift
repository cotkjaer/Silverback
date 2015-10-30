//
//  Border.swift
//  Silverback
//
//  Created by Christian Otkjær on 22/10/15.
//  Copyright © 2015 Christian Otkjær. All rights reserved.
//

public enum BorderWidth
{
    case Relative(CGFloat)
    case Absolute(CGFloat)
    case None
    case Thin
    case Normal
    case Thick
    
    func widthForRadius(radius: CGFloat) -> CGFloat
    {
        var borderWidth : CGFloat = 0
        
        let scale = UIScreen.mainScreen().scale
        
        switch self
        {
        case .Absolute(let width):
            borderWidth = max(1/scale, min(radius, width))
            
        case .Relative(let factor):
            borderWidth = max(1/scale, min(radius, radius*factor))
            
        case .None:
            borderWidth = 0
            
        case .Thin:
            borderWidth = 1
            
        case .Normal:
            borderWidth = 2
            
        case .Thick:
            borderWidth = 5
            
        }
        
        return floor(borderWidth) / scale
    }
}

// MARK: - CustomDebugStringConvertible

extension BorderWidth : CustomDebugStringConvertible
{
    public var debugDescription : String {
    
        switch self
        {
        case .Absolute(let width):
            return "Absolute(\(width))"
            
        case .Relative(let factor):
            return "Relative(\(factor))"
            
        case .None:
            return "None = Absolute(0)"
            
        case .Thin:
            return "Thin = Absolute(1)"
            
        case .Normal:
            return "Normal = Absolute(2)"
            
        case .Thick:
            return "Thick = Absolute(5)"
            
        }
    }
}


//MARK: - Equatable

extension BorderWidth : Equatable
{
}

public func == (lhs: BorderWidth, rhs:BorderWidth) -> Bool
{
    switch (lhs, rhs)
    {
    case (.Absolute(let wl), .Absolute(let wr)):
        return wl == wr
        
    case (.Relative(let fl), .Relative(let fr)):
        return fl == fr
        
    case (.None, .None):
        return true
        
    case (.Thin, .Thin):
        return true
        
    case (.Normal, .Normal):
        return true
        
    case (.Thick, .Thick):
        return true
        
    default:
        return false
    }
}
