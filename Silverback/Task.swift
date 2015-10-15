//
//  Task.swift
//  Silverback
//
//  Created by Christian Otkjær on 18/09/15.
//  Copyright © 2015 Christian Otkjær. All rights reserved.
//

import Foundation

/// A class that encapsulates a closure and enables scheduling
class Task
{
    // The captured by the block dispatched to GCD needs to match this secret to alow execution of the closure
    private var secret = 0
    
    ///The number of scheduled executions
    private(set) var scheduled = 0
    
    private var closure : (() -> ())
    
    /// Capture and retain a closure
    /// - parameter closure : closure to capture
    init(_ closure:()->())
    {
        self.closure = closure
    }
    
    /// Capture and retain a closure, and schedule it to execute after _delay_ seconds
    /// - parameter delay : time to delay execution of _closure_
    /// - parameter closure : closure to capture
    /// If the delay is negative the task is scheduled to execute in 0.1 seconds
    convenience init(delay:Double, closure:()->())
    {
        self.init(closure)
        schedule(delay)
    }
    
    /// Capture and retain a closure, and schedule it to execute on (or after) _date_
    /// - parameter date : the date to wait for before executing _closure_
    /// - parameter closure : closure to capture
    /// If the date is in the past the closure is scheduled to execute in 0.1 seconds
    convenience init(date:NSDate, closure:()->())
    {
        self.init(closure)
        schedule(date)
    }
    
    /// Unschedule all schedulled executions of captured closure
    func unschedule()
    {
        scheduled = 0
        secret++
    }
    
    /// Schedule task to execute after _delay_ seconds
    ///
    /// - parameter after : time to delay execution of task
    ///
    /// If the delay is negative the task is scheduled to execute in 0.1 seconds
    func schedule(after: Double)
    {
        let capturedSecret = secret
        
        delay(max(0.1, after)) { [weak self] in if self?.secret == capturedSecret { self?.scheduled--; self?.closure() } }

        scheduled++
    }
    
    /// Schedule task to execute after _delay_ seconds if it is not already scheduled
    ///
    /// - parameter after : time to delay execution of task
    ///
    /// If the delay is negative the task is scheduled to execute in 0.1 seconds
    func scheduleIfNeeded(after: Double = 0.1)
    {
        if scheduled < 1
        {
            schedule(after)
        }
    }
    
    /// First unschedules any scheduled executions of task, then scedules a new one after _delay_ seconds
    ///
    /// - parameter after : time to delay execution of task
    ///
    /// If the delay is negative the task is scheduled to execute in 0.1 seconds
    func reschedule(after: Double)
    {
        unschedule()
        
        schedule(after)
    }

    
    /// Schedule task to execute after on or after _date_
    ///
    /// - parameter date : the date to wait for before executing task
    ///
    /// If the date is in the past the task is scheduled to execute in 0.1 seconds
    func schedule(date: NSDate)
    {
        schedule(max(0.1, date.timeIntervalSinceNow))
    }
    
    /// First unschedules any scheduled executions of task, then scedules a new one on (or after) _date_
    ///
    /// - parameter date : the date to wait for before executing task
    ///
    /// If the date is in the past the task is scheduled to execute in 0.1 seconds
    func reschedule(date: NSDate)
    {
        unschedule()
        
        schedule(date)
    }
    
    /// Ececutes the closure now
    func execute()
    {
        closure()
    }
    
    deinit
    {
        unschedule()
    }
}