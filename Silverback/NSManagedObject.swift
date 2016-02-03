//
//  NSManagedObject.swift
//  SilverbackFramework
//
//  Created by Christian Otkjær on 21/04/15.
//  Copyright (c) 2015 Christian Otkjær. All rights reserved.
//

import CoreData
import UIKit

extension NSManagedObject
{
    public class var entityName: String
    {
        return baseName()
        
//        let fullClassName: String = NSStringFromClass(object_getClass(self))
//        let classNameComponents: [String] = fullClassName.componentsSeparatedByString(".")// split(fullClassName) { $0 == "." }
//        return classNameComponents.last!
    }
    
    public class func fetchRequest() -> NSFetchRequest
    {
        return NSFetchRequest(entityName: entityName)
    }
    
    
    public func deleteWithConfirmation(controller: UIViewController? = nil, completion: ((deleted:Bool)->())?)
    {
        if let realController = controller ?? UIApplication.topViewController(),
            let context = managedObjectContext
        {
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
            
            alertController.addAction(UIAlertAction(title: UIKitLocalizedString("Delete"), style: .Destructive, handler: { (action) -> Void in
                
                context.deleteObject(self)
                
                let (saved, error) = context.saveSafely()
            
                error?.presentAsAlert()
                
                completion?(deleted: saved)
                
            }))
            
            alertController.addAction(UIAlertAction(title: UIKitLocalizedString("Cancel"), style: .Cancel, handler:  { (action) -> Void in
                completion?(deleted: false)
            }))
            
            realController.presentViewController(alertController, animated: true) { () -> Void in
                //TODO
            }
        }
        else
        {
            completion?(deleted: false)
        }
    }
}
