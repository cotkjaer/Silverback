//
//  ManagedObjectDetailViewController.swift
//  Silverback
//
//  Created by Christian Otkjær on 27/01/16.
//  Copyright © 2016 Christian Otkjær. All rights reserved.
//

// MARK: - ManagedObjectDetailController

import UIKit
import CoreData

public protocol ManagedObjectDetailController: class
{
    var managedObjectContext : NSManagedObjectContext? { set get }
    
    var managedObjectID : NSManagedObjectID? { set get }
    
    ///NB! it is in a child context
    var managedObject: NSManagedObject? { get }

    var managedObjectDetailControllerDelegate: ManagedObjectDetailControllerDelegate? { set get }
}

public protocol ManagedObjectDetailControllerDelegate
{
    func managedObjectDetailControllerDidFinish(controller: ManagedObjectDetailController, saved: Bool)
}

// MARK: - ManagedObjectDetailController

extension UINavigationController
{
    public var managedObjectDetailController: ManagedObjectDetailController? { return viewControllers.find(ManagedObjectDetailController) }
}

public class ManagedObjectDetailViewController: UIViewController, ManagedObjectDetailController
{
    public var managedObjectDetailControllerDelegate: ManagedObjectDetailControllerDelegate?
    
    public var managedObjectContext: NSManagedObjectContext? { didSet { updateObject() } }
    
    public var managedObjectID: NSManagedObjectID? { didSet { updateObject() } }
    
    public var managedObject: NSManagedObject?
    
    private func updateObject()
    {
        if let id = managedObjectID, let context = managedObjectContext
        {
            managedObject = context.objectWithID(id)
        }
        else if managedObject != nil
        {
            managedObject = nil
        }
    }
}