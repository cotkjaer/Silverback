//
//  CALayer.swift
//  Silverback
//
//  Created by Christian Otkjær on 09/12/15.
//  Copyright © 2015 Christian Otkjær. All rights reserved.
//

import UIKit

//MARK: - Line cap

public enum LineCap
{
    case Butt, Round, Square
    
    var CALineCap : String {
        switch self
        {
        case .Butt: return kCALineCapButt
        case .Round: return kCALineCapRound
        case .Square: return kCALineCapSquare
        }
    }
}


//MARK: - Animation

extension CALayer
{
    internal func animate(value: AnyObject, duration: Double, keyPath: String)
    {
        let animation = CABasicAnimation(keyPath: keyPath)
        
        animation.duration = duration
        animation.fromValue = valueForKeyPath(keyPath)
        
        setValue(value, forKeyPath: keyPath)
        
        addAnimation(animation, forKey: keyPath + " animation")
    }
}


//MARK: - Rotation

public let CALayerRotationKeyPath = "transform.rotation.z"

extension CALayer
{
    var rotation : CGFloat
        {
        get { return valueForKeyPath(CALayerRotationKeyPath) as? CGFloat ?? 0 }
        set { setValue(newValue, forKeyPath: CALayerRotationKeyPath) }
    }
    
    func animateRotationTo(angle: CGFloat, clockwise: Bool = true, duration: Double)
    {
        var delta = angle - rotation
        
        while clockwise && delta < 0 { delta += π2 }
        
        while !clockwise && delta > 0 { delta -= π2 }
        
        animateRotateBy(delta, duration: duration)
    }
    
    public func animateRotateBy(deltaAngle: CGFloat, duration: Double = 0.1, timingFunctionName: String = kCAMediaTimingFunctionLinear)
    {
        if let currentRotation = valueForKeyPath(CALayerRotationKeyPath) as? CGFloat
        {
            let animation = CAKeyframeAnimation(keyPath: CALayerRotationKeyPath)
            
            animation.duration = duration
            
            animation.fillMode = kCAFillModeForwards
            
            animation.calculationMode = kCAAnimationPaced
            
            animation.values =
                [
                currentRotation,
                currentRotation + deltaAngle * 0.3333333333,
                currentRotation + deltaAngle * 0.6666666667,
                currentRotation + deltaAngle
            ]
            
            var timingFunctions = Array<String>(count: 3, repeatedValue: kCAMediaTimingFunctionLinear)
            
            switch timingFunctionName
            {
            case kCAMediaTimingFunctionEaseIn:
                timingFunctions[0] = kCAMediaTimingFunctionEaseIn
                
            case kCAMediaTimingFunctionEaseInEaseOut:
                timingFunctions[0] = kCAMediaTimingFunctionEaseIn
                timingFunctions[2] = kCAMediaTimingFunctionEaseOut
                
            case kCAMediaTimingFunctionEaseOut:
                timingFunctions[2] = kCAMediaTimingFunctionEaseOut
                
            default:
                break
            }
            
            animation.timingFunctions = timingFunctions.map { CAMediaTimingFunction(name: $0) }
            
            setValue(currentRotation + deltaAngle, forKeyPath: CALayerRotationKeyPath)
            addAnimation(animation, forKey:CALayerRotationKeyPath)
        }
    }
}
