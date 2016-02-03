//
//  NSError.swift
//  Silverback
//
//  Created by Christian Otkjær on 16/11/15.
//  Copyright © 2015 Christian Otkjær. All rights reserved.
//

import Foundation
import UIKit

extension NSError
{
    public class var defaultAsyncErrorHandler : ((NSError) -> Void) { return { (error: NSError) -> Void in error.presentAsAlert() } }
    
    public convenience init(
        domain: String,
        code: Int,
        description: String? = nil,
        reason: String? = nil,
        underlyingError: NSError? = nil)
    {
        var errorUserInfo: [String : AnyObject] = [:]
        
        if description != nil
        {
            errorUserInfo[NSLocalizedDescriptionKey] = description ?? ""
        }
        if reason != nil
        {
            errorUserInfo[NSLocalizedFailureReasonErrorKey] = reason ?? ""
        }
        
        if underlyingError != nil
        {
            errorUserInfo[NSUnderlyingErrorKey] = underlyingError
        }
        
        self.init(domain: domain, code: code, userInfo: errorUserInfo)
    }
    
    public func presentAsAlert(handler:(() -> Void)? = nil)
    {
        presentInViewController(nil, withHandler: handler)
    }
    
    //    public func presentInViewController(controller: UIViewController?)
    //    {
    //        let alertController = UIAlertController(title: self.localizedDescription, message: self.localizedFailureReason, preferredStyle: .Alert)
    //
    //        //TODO: localizedRecoveryOptions and localizedRecoverySuggestion
    //
    //        //        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
    //        //            // ...
    //        //        }
    //        //        alertController.addAction(cancelAction)
    //
    //        let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
    //
    //            println("Ignored Error: \(self)")
    //        }
    //        alertController.addAction(OKAction)
    //
    //        controller?.presentViewController(alertController, animated: true) { NSLog("Showing error: \(self)") }
    //    }
    
    public func presentInViewController(controller: UIViewController?, withHandler handler:(() -> Void)? = nil)
    {
        let alertController = UIAlertController(title: self.localizedDescription, message: self.localizedFailureReason, preferredStyle: .Alert)
        
        let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
            
            if let realHandler = handler
            {
                realHandler()
            }
            else
            {
                debugPrint("Ignored Error: \(self)")
            }
        }
        
        alertController.addAction(OKAction)
        
        if let realController = controller ?? UIApplication.topViewController()
        {
            realController.presentViewController(alertController, animated: true) { debugPrint("Showing error: \(self)") }
        }
        else
        {
            debugPrint("ERROR could not be presented: \(self)")
        }
    }
}