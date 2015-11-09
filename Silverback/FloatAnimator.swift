//
//  FloatAnimator.swift
//  Silverback
//
//  Created by Christian Otkjær on 04/11/15.
//  Copyright © 2015 Christian Otkjær. All rights reserved.
//

public class FloatAnimator
{
    private let StepSize : Float = 0.02
    
    private var tasks = Array<Task>()
    
    var setter : ((Float) -> ())!
    var getter : (() -> Float)!

    public init(setter: Float -> () = { _ in }, getter: () -> Float = { return 0 })
    {
        self.getter = getter
        self.setter = setter
    }
    
    public func animateFloat(to: Float, duration: Double)
    {
        tasks.forEach { $0.unschedule() }
        tasks.removeAll(keepCapacity: true)
        
        let T = Float(max(0.1, duration))
        let from = getter()
        
        //liniear easing function
        let f = { (t: Float) -> Float in return (from * (T - t) + to * t) / T }
        
        T.stride(to: 0, by: -StepSize).forEach { let v = f($0); self.tasks.append(Task(delay: Double($0), closure: { self.setter(v) })) }
    }
}
