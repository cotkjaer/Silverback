//
//  NSTextAlignment.swift
//  Silverback
//
//  Created by Christian Otkjær on 27/11/15.
//  Copyright © 2015 Christian Otkjær. All rights reserved.
//

import Foundation
import UIKit

// MARK: - CustomDebugStringConvertible

extension NSTextAlignment : CustomDebugStringConvertible, CustomStringConvertible
{
    public var debugDescription : String {
    
        switch self
        {
        case .Right: return "RightTextAlignment"
        case .Left: return "LeftTextAlignment"
        case .Center: return "CenterTextAlignment"
        case .Natural: return "NaturalTextAlignment"
        case .Justified: return "JustifiedTextAlignment"
        }
    }

    public var description : String {
        
        switch self
        {
        case .Right: return "Right"
        case .Left: return "Left"
        case .Center: return "Center"
        case .Natural: return "Natural"
        case .Justified: return "Justified"
        }
    }
}
