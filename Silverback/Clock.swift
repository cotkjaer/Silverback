//
//  Clock.swift
//  Silverback
//
//  Created by Christian Otkjær on 10/11/15.
//  Copyright © 2015 Christian Otkjær. All rights reserved.
//

import Foundation

private let debugFormatter = NSDateFormatter(timeStyle: .FullStyle, dateStyle: .NoStyle)

public class Clock
{
    private let calendar = NSCalendar.autoupdatingCurrentCalendar()
    
    let unit: NSCalendarUnit
    let closure : (()->())

    private var timer: NSTimer?
    
    public init(unit: NSCalendarUnit, closure: ()->())
    {
        self.unit = unit
        self.closure = closure
    }
    
    deinit
    {
        timer?.invalidate()
    }
    
    public var running : Bool { return timer?.valid == true }
    
    public func start()
    {
        scheduleTimer()
    }
    
    public func stop()
    {
        unscheduleTimer()
    }
    
    func unscheduleTimer()
    {
        timer?.invalidate()
        timer = nil
    }
    
    func scheduleTimer()
    {
        unscheduleTimer()
        
        if let date = calendar.nextWhole(unit)
        {
            debugPrint("nextdate for \(debugFormatter.stringFromDate(NSDate())) -> \(debugFormatter.stringFromDate(date))")

            let timer = NSTimer(fireDate: date, interval: 0, target: self, selector: Selector("handleTimer"), userInfo: nil, repeats: false)
            
            NSRunLoop.mainRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)
            
            self.timer = timer
        }
        else
        {
            debugPrint("Could not create next date")
        }
    }
    
    @objc private func handleTimer()
    {
        scheduleTimer()
        closure()
    }
}