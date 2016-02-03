//
//  NotificationHandlerManager.swift
//  Silverback
//
//  Created by Christian Otkjær on 02/10/15.
//  Copyright © 2015 Christian Otkjær. All rights reserved.
//

import Foundation

/// A handler class to ease the bookkeeping associated with adding closure-based notification handling.
public class NotificationHandlerManager
{
    /// The tokens managed by this manager
    private var observerTokens = Array<AnyObject>()
    
    private let notificationCenter : NSNotificationCenter
    
    public required init(notificationCenter: NSNotificationCenter = NSNotificationCenter.defaultCenter())
    {
        self.notificationCenter = notificationCenter
    }
    
    deinit
    {
        deregisterAll()
    }
    
    public func deregisterAll()
    {
        while !observerTokens.isEmpty
        {
            notificationCenter.removeObserver(observerTokens.removeLast())
        }
    }
    
    public func registerHandlerForNotification(name: String? = nil,
        object: AnyObject? = nil,
        queue: NSOperationQueue? = nil,
        handler: ((notification: NSNotification) -> ()))
    {
        observerTokens.append(notificationCenter.addObserverForName(name, object: object, queue: queue, usingBlock: { handler(notification: $0) }))
    }
    
    public func onAny(from object: AnyObject, perform: (() -> ()))
    {
        registerHandlerForNotification(nil, object: object, queue: nil) { _ in perform() }
    }

    public func on(notificationName: String, from object: AnyObject? = nil, perform: (() -> ()))
    {
        registerHandlerForNotification(notificationName, object: object, queue: nil) { _ in perform() }
    }

    
    
    public func when(notificationName: String, with object: AnyObject? = nil, perform: (() -> ()))
    {
        registerHandlerForNotification(notificationName, object: object, queue: nil) { _ in perform() }
    }

    public func when<T:AnyObject>(notificationName: String, perform: ((T) -> ()))
    {
        registerHandlerForNotification(notificationName) { (notification) -> () in
            if let t = notification.object as? T
            {
                perform(t)
            }
        }
    }
}

import UIKit

//MARK: - Keyboard

extension NotificationHandlerManager
{
    public func animateAlongsideKeyboardFrameChange(animations: (keyboardBeginFrame:CGRect?, keyboardEndFrame: CGRect?) -> (), completion: ((completed: Bool) -> ())?)
    {
        registerHandlerForNotification(UIKeyboardWillChangeFrameNotification) { (notification) -> () in
            if let userInfo = notification.userInfo
            {
                let endFrame = userInfo[UIKeyboardFrameEndUserInfoKey]?.CGRectValue
                let beginFrame = userInfo[UIKeyboardFrameBeginUserInfoKey]?.CGRectValue
                let animationCurveRaw = userInfo[UIKeyboardAnimationCurveUserInfoKey]?.unsignedLongValue ?? UIViewAnimationOptions.CurveEaseInOut.rawValue
                let animationDuration = userInfo[UIKeyboardAnimationDurationUserInfoKey]?.doubleValue ?? 0
                
                let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)

                UIView.animateWithDuration(animationDuration,
                    delay: 0,
                    options: animationCurve,
                    animations: { animations(keyboardBeginFrame: beginFrame, keyboardEndFrame: endFrame) },
                    completion: completion)
            }
        }

    }

}
