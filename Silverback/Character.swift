//
//  Character.swift
//  Silverback
//
//  Created by Christian Otkjær on 01/02/16.
//  Copyright © 2016 Christian Otkjær. All rights reserved.
//

import Foundation

extension Character
{
    public var utf16 : unichar
        {
            return String(self).utf16.first!
    }
}
