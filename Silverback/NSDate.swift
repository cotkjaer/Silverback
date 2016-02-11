//
//  NSDate.swift
//  Silverback
//
//  Created by Christian Otkjær on 23/10/15.
//  Copyright © 2015 Christian Otkjær. All rights reserved.
//

import Foundation
import UIKit

extension NSDate: Comparable, OptionalComparable, OptionalEquatable
{
    public func lessThan(thing: Any?) -> Bool
    {
        return (self < thing as? NSDate) ?? false
    }
    
    public func equals(thing: Any?) -> Bool
    {
        return ( self == thing as? NSDate) ?? false
    }
}

public func == (lhs: NSDate, rhs: NSDate) -> Bool
{
    return lhs === rhs || lhs.compare(rhs) == .OrderedSame
}

public func < (lhs: NSDate, rhs: NSDate) -> Bool
{
    return lhs.compare(rhs) == .OrderedAscending
}

//MARK: - relative

public extension NSDate
{
//    func fullHoursSinceDate(date: NSDate) -> Int
//    {
//        let interval = timeIntervalSinceDate(date)
//        
//        let sign = interval < 0 ? -1 : 1
//        
//        let fullSeconds = Int(interval.abs.floor)
//        
//        let hours = fullSeconds / 3600
//        
//        return sign * hours
//    }

    func hoursMinutesSecondsSinceDate(date: NSDate) -> (before: Bool, hours: Int, minutes: Int, seconds: Int)
    {
        let interval = timeIntervalSinceDate(date)
        
        let before = interval < 0
        
        var fullSeconds = Int(interval.abs.floor)
        
        let seconds = fullSeconds % 60
        
        fullSeconds -= seconds
        fullSeconds /= 60
        
        let minutes = fullSeconds % 60
        fullSeconds -= minutes
        fullSeconds /= 60
        
        let hours = fullSeconds
        
        return (before, hours, minutes, seconds)
    }
}

//MARK: - components

extension NSDate
{
    @warn_unused_result
    public func component(unit: NSCalendarUnit, inCalendar calendar: NSCalendar = NSCalendar.currentCalendar()) -> Int
    {
        return calendar.component(unit, fromDate: self)
    }
}

//MARK: - weekday

extension NSDate
{
    @warn_unused_result
    public func weekday(calendar: NSCalendar = NSCalendar.currentCalendar()) -> Int
    {
        return component(.Weekday, inCalendar:  calendar)
    }
}

//MARK: - Seconds

extension NSDate
{
    public var secondsSinceReferenceDate : Int
    {
        return Int(floor(timeIntervalSinceReferenceDate))
    }
}

//MARK: - Image

extension NSData
{
    public var asImage : UIImage? { return UIImage(data: self) }
}


