//
//  NSCalendar.swift
//  Silverback
//
//  Created by Christian Otkjær on 10/11/15.
//  Copyright © 2015 Christian Otkjær. All rights reserved.
//

import Foundation


// MARK: - Hashable

extension NSCalendarUnit : Hashable
{
    public var hashValue : Int { return Int(bitPattern: rawValue) }
}

// MARK: - Next whole

extension NSCalendar
{
    public func round(optionalDate: NSDate? = NSDate(), toWhole unit: NSCalendarUnit) -> NSDate?
    {
        guard let date = optionalDate else { return nil }
        
        let c = self.components([.Era, .Year, .Month, .Day, .Hour, .Minute, .Second], fromDate: date)
        
        switch unit
        {
        case NSCalendarUnit.Era:
            
            c.year = rangeOfUnit(.Year, inUnit: .Era, forDate: date).location
            return round(dateFromComponents(c), toWhole: .Year)
            
        case NSCalendarUnit.Year:
            
            c.month = rangeOfUnit(.Month, inUnit: .Year, forDate: date).location
            return round(dateFromComponents(c), toWhole: .Month)
            
        case NSCalendarUnit.Month:
            
            c.day = rangeOfUnit(.Day, inUnit: .Month, forDate: date).location
            return round(dateFromComponents(c), toWhole: .Day)
            
        case NSCalendarUnit.Day:
            
            c.hour = rangeOfUnit(.Hour, inUnit: .Day, forDate: date).location
            return round(dateFromComponents(c), toWhole: .Hour)

        case NSCalendarUnit.Hour:

            c.minute = rangeOfUnit(.Minute, inUnit: .Hour, forDate: date).location
            return round(dateFromComponents(c), toWhole: .Minute)

        case NSCalendarUnit.Minute:
            
            c.second = rangeOfUnit(.Second, inUnit: .Minute, forDate: date).location
            return round(dateFromComponents(c), toWhole: .Second)
        
        case NSCalendarUnit.Second:
            
            c.nanosecond = 0
            return dateFromComponents(c)
            
        default:
            debugPrint("Cannot round \(unit)")
        }
        
        return nil
    }
    
    
    public func nextWhole(unit: NSCalendarUnit, afterDate date: NSDate = NSDate()) -> NSDate?
    {
        if let roundedDate = round(date, toWhole: unit)
        {
            return dateByAddingUnit(unit, value: 1, toDate: roundedDate, options: .MatchStrictly)
        }
        
        return nil
    }
}