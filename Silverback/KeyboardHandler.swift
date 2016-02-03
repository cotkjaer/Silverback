//
//  KeyboardChangeHandler.swift
//  Silverback
//
//  Created by Christian Otkjær on 10/01/16.
//  Copyright © 2016 Christian Otkjær. All rights reserved.
//

import UIKit

public class KeyboardHandler
{
    private var observerTokens : Array<AnyObject>
    
    public required init()
    {
        observerTokens = []
    }
    
    deinit
    {
        observerTokens.forEach { NSNotificationCenter.defaultCenter().removeObserver($0) }
    }
    
    private func addObserverForName(name: String, block: (notification: NSNotification) -> ())
    {
        observerTokens.append(NSNotificationCenter.defaultCenter().addObserverForName(name, object: nil, queue: nil, usingBlock: block))
    }
    
    /// Called on `UIKeyboardWillChangeFrameNotification` with the keyboard begin- and end-frame in screen coordinates
    /// - parameter amimations : animations block, as in `UIView.animateWithDuration`. Animations are done with the same duration and curve as the keyboard-frame change.
    /// - parameter completion : optional completion block to be executed when the animation sequence ends.
    public func animateAlongsideFrameChange(animations: (beginFrame:CGRect, endFrame: CGRect) -> (), completion: (() -> ())? = nil)
    {
        addObserverForName(UIKeyboardWillChangeFrameNotification) { (notification) -> () in
            
            if let userInfo = notification.userInfo
            {
                // Begin- and end-frames are guarateed, but just for safty we default to CGRectZero, rather than using !
                let endFrame = userInfo[UIKeyboardFrameEndUserInfoKey]?.CGRectValue ?? CGRectZero
                
                let beginFrame = userInfo[UIKeyboardFrameBeginUserInfoKey]?.CGRectValue ?? CGRectZero
                
                let animationCurveRaw = userInfo[UIKeyboardAnimationCurveUserInfoKey]?.unsignedLongValue ?? UIViewAnimationOptions.CurveEaseInOut.rawValue
                
                let animationDuration = userInfo[UIKeyboardAnimationDurationUserInfoKey]?.doubleValue ?? 0
                
                let animationCompletion : ((Bool) -> ())? = completion == nil ? nil : { _ in completion?() }
                
                UIView.animateWithDuration(animationDuration,
                    delay: 0,
                    options: UIViewAnimationOptions(rawValue: animationCurveRaw),
                    animations: { animations(beginFrame: beginFrame, endFrame: endFrame) },
                    completion: animationCompletion )
            }
        }
    }
    
    public func onKeyboardDidHide(closure: () -> ())
    {
        addObserverForName(UIKeyboardDidHideNotification) { (notification) -> () in
            closure()
        }
    }
}