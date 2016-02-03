//
//  Scaling.swift
//  Silverback
//
//  Created by Christian Otkjær on 14/12/15.
//  Copyright © 2015 Christian Otkjær. All rights reserved.
//

import CoreGraphics

public enum Scaling
{
    case none
    case proportionally
    case toFit
}

public enum Alignment
{
    case center
    case top
    case topLeft
    case topRight
    case left
    case bottom
    case bottomLeft
    case bottomRight
    case right
}

//MARK: - scaling

extension CGRect
{
    public mutating func scaleAndAlignToRect(rect: CGRect, scaling: Scaling, alignment: Alignment)
    {
        self = scaledAndAlignedToRect(rect, scaling: scaling, alignment: alignment)
    }
    
    public func scaledAndAlignedToRect(rect: CGRect, scaling: Scaling, alignment: Alignment) -> CGRect
    {
        var result = CGRect()
        var scaledSize = size
        
        switch scaling
        {
        case .toFit:
            return rect
            
        case .proportionally:
            var theScaleFactor: CGFloat = 1
            
            if rect.size.width / size.width < rect.size.height / size.height
            {
                theScaleFactor = rect.size.width / size.width
            }
            else
            {
                theScaleFactor = rect.size.height / size.height
            }

            scaledSize *= theScaleFactor
            
            result.size = scaledSize
        case .none:
            result.size.width = scaledSize.width
            result.size.height = scaledSize.height
        }
        
        switch alignment
        {
        case .center:
            result.origin.x = rect.origin.x + (rect.size.width - scaledSize.width) / 2
            result.origin.y = rect.origin.y + (rect.size.height - scaledSize.height) / 2
            
        case .top:
            result.origin.x = rect.origin.x + (rect.size.width - scaledSize.width) / 2
            result.origin.y = rect.origin.y + rect.size.height - scaledSize.height
            
        case .topLeft:
            result.origin.x = rect.origin.x
            result.origin.y = rect.origin.y + rect.size.height - scaledSize.height
            
        case .topRight:
            result.origin.x = rect.origin.x + rect.size.width - scaledSize.width
            result.origin.y = rect.origin.y + rect.size.height - scaledSize.height
            
        case .left:
            result.origin.x = rect.origin.x
            result.origin.y = rect.origin.y + (rect.size.height - scaledSize.height) / 2
            
        case .bottom:
            result.origin.x = rect.origin.x + (rect.size.width - scaledSize.width) / 2
            result.origin.y = rect.origin.y
            
        case .bottomLeft:
            result.origin.x = rect.origin.x
            result.origin.y = rect.origin.y
            
        case .bottomRight:
            result.origin.x = rect.origin.x + rect.size.width - scaledSize.width
            result.origin.y = rect.origin.y
            
        case .right:
            result.origin.x = rect.origin.x + rect.size.width - scaledSize.width
            result.origin.y = rect.origin.y + (rect.size.height - scaledSize.height) / 2
        }
        
        return result
    }
}