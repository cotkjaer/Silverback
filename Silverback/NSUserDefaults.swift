//
//  NSUserDefaults.swift
//  Silverback
//
//  Created by Christian Otkjær on 05/11/15.
//  Copyright © 2015 Christian Otkjær. All rights reserved.
//

import Foundation

//MARK: - Text

extension NSUserDefaults
{
    public func setText(text: String, forKey key: String)
    {
        setObject(text, forKey: key)
    }
    
    public func textForKey(key: String) -> String
    {
        return (objectForKey(key) as? String) ?? ""
    }
}