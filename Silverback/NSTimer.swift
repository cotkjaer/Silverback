//
//  NSTimer.swift
//  Silverback
//
//  Created by Christian Otkjær on 26/10/15.
//  Copyright © 2015 Christian Otkjær. All rights reserved.
//

import Foundation

private class NSTimerActor
{
    var block: () -> ()
    
    init(_ block: () -> ()) {
        self.block = block
    }
    
    @objc func fire() {
        block()
    }
}

public extension NSTimer
{
    convenience init(after interval: NSTimeInterval, _ block: () -> ())
    {
        let actor = NSTimerActor(block)
        self.init(timeInterval: interval, target: actor, selector: "fire", userInfo: nil, repeats: false)
    }
    
    convenience init(every interval: NSTimeInterval, _ block: () -> ())
    {
        let actor = NSTimerActor(block)
        self.init(timeInterval: interval, target: actor, selector: "fire", userInfo: nil, repeats: true)
    }
}

public extension NSTimer
{
    class func after(interval: NSTimeInterval, _ block: () -> ()) -> NSTimer
    {
        let timer = NSTimer(after: interval, block)
        NSRunLoop.mainRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)
        return timer
    }
    
    
    class func every(interval: NSTimeInterval, _ block: () -> ()) -> NSTimer
    {
        let timer = NSTimer(every: interval, block)
        NSRunLoop.mainRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)
        return timer
    }
}

public extension Double
{
    var second:  NSTimeInterval { return self }
    var seconds: NSTimeInterval { return self }
    var minute:  NSTimeInterval { return self * 60 }
    var minutes: NSTimeInterval { return self * 60 }
    var hour:    NSTimeInterval { return self * 3600 }
    var hours:   NSTimeInterval { return self * 3600 }
}

