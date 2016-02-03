//
//  NSCharacterSet.swift
//  Silverback
//
//  Created by Christian Otkjær on 01/02/16.
//  Copyright © 2016 Christian Otkjær. All rights reserved.
//

import Foundation

extension NSCharacterSet
{
    public func containsCharacter(character: Character?) -> Bool
    {
        if let unichar = character?.utf16
        {
            return characterIsMember(unichar)
        }
        
        return false
    }
}
