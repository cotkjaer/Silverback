//
//  NSString.swift
//  Silverback
//
//  Created by Christian Otkjær on 14/12/15.
//  Copyright © 2015 Christian Otkjær. All rights reserved.
//

import Foundation

extension NSString
{
    public convenience init?(optionalString : String?)
    {
        if let string = optionalString
        {
            self.init(string: string)
        }
        else
        {
            self.init()
            return nil
        }
    }
}
