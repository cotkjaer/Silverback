//
//  NSDateFormatter.swift
//  Silverback
//
//  Created by Christian Otkjær on 02/11/15.
//  Copyright © 2015 Christian Otkjær. All rights reserved.
//

import Foundation

//MARK: - Convenience Init

extension NSDateFormatter
{
    public convenience init(dateFormat: String)
    {
        self.init()
        
        self.dateFormat = dateFormat
    }
    
    public convenience init(timeStyle: NSDateFormatterStyle, dateStyle: NSDateFormatterStyle)
    {
        self.init()
        
        self.dateStyle = dateStyle
        self.timeStyle = timeStyle
    }
}