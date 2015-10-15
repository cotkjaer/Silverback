//
//  Async.swift
//  Silverback
//
//  Created by Christian Otkjær on 16/09/15.
//  Copyright © 2015 Christian Otkjær. All rights reserved.
//

import Foundation

public enum BackgroundExecutionPriority
{
    case High
    case Default
    case Low
    case Lowest
    
    private var dispatch_priority : dispatch_queue_priority_t
        {
            switch self
            {
            case .High: return DISPATCH_QUEUE_PRIORITY_HIGH
            case .Default: return DISPATCH_QUEUE_PRIORITY_DEFAULT
            case .Low: return DISPATCH_QUEUE_PRIORITY_LOW
            case .Lowest: return DISPATCH_QUEUE_PRIORITY_BACKGROUND
            }
    }
    
    func queue() -> dispatch_queue_t
    {
        return dispatch_get_global_queue(dispatch_priority, 0)
    }
}

// MARK: - Delay

extension dispatch_time_t
{
    func delay(delay: Double) -> dispatch_time_t
    {
        if delay < 0
        {
            return self
        }
        else
        {
            return dispatch_time(self, Int64(delay * Double(NSEC_PER_SEC)))
        }
    }
}

public func delay(delay:Double, closure:()->())
{
    dispatch_after(
        DISPATCH_TIME_NOW.delay(delay),
        //            dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC))),
        dispatch_get_main_queue(),
        closure)
}

public func background(priority: BackgroundExecutionPriority = .Default, _ closure:()->())
{
    dispatch_async(priority.queue(), closure)
}

public func foreground(closure:()->())
{
    dispatch_async(dispatch_get_main_queue(), closure)
}


public func async(closure:()->())
{
    dispatch_async(dispatch_get_main_queue(), closure)
}