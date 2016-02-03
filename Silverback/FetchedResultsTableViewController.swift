//
//  FetchedResultsTableViewController.swift
//  Silverback
//
//  Created by Christian Otkjær on 14/01/16.
//  Copyright © 2016 Christian Otkjær. All rights reserved.
//

import UIKit
import CoreData

public class FetchedResultsTableViewController: UITableViewController, ManagedObjectDetailControllerDelegate
{
    /// Set this if you are updating the tabledata "manually" (e.g. when rearranging)
    public var ignoreControllerChanges: Bool = false
    
    public var managedObjectContext : NSManagedObjectContext?
    
    public var sectionNameKeyPath: String? { didSet { if oldValue != sectionNameKeyPath { updateFetchedResultsController() } } }
    
    public var fetchRequest: NSFetchRequest? { didSet { if oldValue != fetchRequest { updateFetchedResultsController() } } }
    
    
    private var fetchedResultsController: NSFetchedResultsController? { didSet { setNeedsFetch() } }
    
    private func updateFetchedResultsController()
    {
        if let context = managedObjectContext,
            let fetchRequest = self.fetchRequest
        {
            let frc = NSFetchedResultsController(
                fetchRequest: fetchRequest,
                managedObjectContext: context,
                sectionNameKeyPath: sectionNameKeyPath,
                cacheName: nil)
            
            frc.delegate = self
            
            fetchedResultsController = frc
            
            setNeedsFetch()
        }
        else
        {
            fetchedResultsController = nil
        }
    }
    
    public private(set) var needsFecth = false
    
    public func setNeedsFetch()
    {
        needsFecth = true
    }
    
    public func fetch()
    {
        do
        {
            try fetchedResultsController?.performFetch()
            needsFecth = false
        }
        catch let error
        {
            print("Error: \(error)")
        }
    }
    
    // MARK: - Objects
    
    public func objectForIndexPath(optionalIndexPath: NSIndexPath?) -> NSManagedObject?
    {
        if let indexPath = optionalIndexPath
        {
            return fetchedResultsController?.objectAtIndexPath(indexPath) as? NSManagedObject
        }
        
        return nil
    }
    
    public func indexPathForObject(optionalObject: NSManagedObject?) -> NSIndexPath?
    {
        if let object = optionalObject
        {
            return fetchedResultsController?.indexPathForObject(object)
        }
        
        return nil
    }
    
    public func indexPathForObjectWithID(optionalID: NSManagedObjectID?) -> NSIndexPath?
    {
        if let id = optionalID, let object = fetchedResultsController?.fetchedObjects?.find({ $0.objectID == id }) as? NSManagedObject
        {
            return indexPathForObject(object)
        }
        
        return nil
    }
    
    public func numberOfObjects(inSection: Int? = nil) -> Int
    {
        if let section = inSection
        {
            return fetchedResultsController?.numberOfObjectsInSection(section) ?? 0
        }
        
        return fetchedResultsController?.fetchedObjects?.count ?? 0
    }

    // MARK: - Lifecycle
    
    override public func viewDidLoad()
    {
        super.viewDidLoad()
        
        setupGestureRecognizer()
        
        fetch()
    }
    
    // MARK: - UITableViewDataSource
    
    override public func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return fetchedResultsController?.sections?.count ?? 0
    }
    
    override public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return fetchedResultsController?.sections?.get(section)?.numberOfObjects ?? 0
    }
    
    public func cellReuseIdentifierForIndexPath(indexPath: NSIndexPath) -> String
    {
        return "Cell"
    }
    
    public func configureCell(cell: UITableViewCell, forObject object: NSManagedObject?, atIndexPath indexPath: NSIndexPath)
    {
        debugPrint("override configureCell")
    }
    
    override public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifierForIndexPath(indexPath), forIndexPath: indexPath)
        
        configureCell(cell, forObject: objectForIndexPath(indexPath), atIndexPath: indexPath)
        
        return cell
    }
    
    override public func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        return fetchedResultsController?.sections?.get(section)?.name
    }
    
    // MARK: - Rearranging
    
    var sourceIndexPath : NSIndexPath?
    var snapshot : UIView?
    var draggingOffset : CGPoint?
    
    // MARK: - ManagedObjectDetailControllerDelegate
    
    
    public func managedObjectDetailControllerDidFinish(controller: ManagedObjectDetailController, saved: Bool)
    {
        dismissViewControllerAnimated(true, completion: nil)
    }
}

// MARK: - Navigation

extension FetchedResultsTableViewController
{
    override public func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if let navController = segue.destinationViewController as? UINavigationController,
            let detailController = navController.managedObjectDetailController
        {
            detailController.managedObjectDetailControllerDelegate = self
            detailController.managedObjectContext = managedObjectContext?.childContext()
            
            if let managedObject = sender as? NSManagedObject
            {
                detailController.managedObjectID = managedObject.objectID
            }
        }
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension FetchedResultsTableViewController : NSFetchedResultsControllerDelegate
{
    public func controllerWillChangeContent(controller: NSFetchedResultsController)
    {
        debugPrint("\(self) will change")
        if !ignoreControllerChanges
        {
            tableView.beginUpdates()
        }
    }
    
    public func controllerDidChangeContent(controller: NSFetchedResultsController)
    {
        debugPrint("\(self) did change")
        if !ignoreControllerChanges
        {
            tableView.endUpdates()
        }
    }
    
    public func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?)
    {

        if !ignoreControllerChanges
        {
            switch type
            {
            case .Insert:
                
                if let insertIndexPath = newIndexPath
                {
                    debugPrint("\(self) did insert: \(insertIndexPath)")
                    tableView.insertRowsAtIndexPaths([insertIndexPath], withRowAnimation: UITableViewRowAnimation.Fade)
                }
                
            case .Delete:
                
                if let deleteIndexPath = indexPath
                {
                    debugPrint("\(self) did delete: \(deleteIndexPath)")
                    tableView.deleteRowsAtIndexPaths([deleteIndexPath], withRowAnimation: UITableViewRowAnimation.Fade)
                }
                
            case .Update:
                
                if let updatedIndexPath = indexPath,
                    let cell = self.tableView.cellForRowAtIndexPath(updatedIndexPath),
                    let object = objectForIndexPath(updatedIndexPath)
                {
                    debugPrint("\(self) did update: \(updatedIndexPath)")
                    configureCell(cell, forObject: object, atIndexPath: updatedIndexPath)
                }
                
            case .Move:
                
                if let deleteIndexPath = indexPath, let insertIndexPath = newIndexPath
                {
                    debugPrint("\(self) did move: \(deleteIndexPath) -> \(insertIndexPath)")
                    
                    tableView.deleteRowsAtIndexPaths([deleteIndexPath], withRowAnimation: UITableViewRowAnimation.Fade)
                    tableView.insertRowsAtIndexPaths([insertIndexPath], withRowAnimation: UITableViewRowAnimation.Fade)
                }
            }
        }
    }
    
    public func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType)
    {
        if !ignoreControllerChanges
        {
            let sectionIndexSet = NSIndexSet(index: sectionIndex)
            
            switch type
            {
            case .Insert:
                tableView.insertSections(sectionIndexSet, withRowAnimation: .Fade)
                
            case .Delete:
                tableView.deleteSections(sectionIndexSet, withRowAnimation: .Fade)
                
            default:
                debugPrint("Odd change-type for section \(sectionIndex): \(type)")
            }
        }
    }
    
    public func controller(controller: NSFetchedResultsController, sectionIndexTitleForSectionName sectionName: String) -> String?
    {
        return sectionName
    }
}

// MARK: - Rearrange

extension FetchedResultsTableViewController
{
    func customSnapshotFromView(inputView: UIView) -> UIView
    {
        UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, false, 0)
        defer { UIGraphicsEndImageContext() }
        
        if let context = UIGraphicsGetCurrentContext()
        {
            inputView.layer.renderInContext(context)
            
            let image = UIGraphicsGetImageFromCurrentImageContext()
            
            let snapshot = UIImageView(image: image)
            snapshot.layer.masksToBounds = false
            snapshot.layer.cornerRadius = 0
            snapshot.layer.shadowOffset = CGSize(width: 0, height: 5)
            snapshot.layer.shadowRadius = 5
            snapshot.layer.shadowOpacity = 0.4
            
            return snapshot
        }
        
        return UIView()
    }
    
    func setupGestureRecognizer()
    {
        let longPress = UILongPressGestureRecognizer(target: self, action: Selector("longPressGestureRecognized:"))
        tableView.addGestureRecognizer(longPress)
    }
    
    func longPressGestureRecognized(longPress :UILongPressGestureRecognizer)
    {
        let location = longPress.locationInView(tableView)
        
        switch longPress.state
        {
        case .Began:
            
            ignoreControllerChanges = true
            if let indexPath = tableView.indexPathForLocation(location)
                , let cell = tableView.cellForRowAtIndexPath(indexPath)
            {
                sourceIndexPath = indexPath
                
                // Take a snapshot of the selected row using helper method.
                let snapshot = customSnapshotFromView(cell)
                
                // Add the snapshot as subview, centered at cell's center...
                
                snapshot.center = cell.center
                snapshot.alpha = 0
                
                draggingOffset =  location - cell.center
                
                self.snapshot = snapshot
                
                tableView.addSubview(snapshot)
                
                UIView.animateWithDuration(0.25,
                    animations:
                    {
                        snapshot.transform = CGAffineTransformMakeScale(1.05, 1.05)
                        snapshot.center.y = location.y - (self.draggingOffset?.y ?? 0)
                        snapshot.alpha = 1
                        
                        // Fade out.
                        cell.alpha = 0
                        
                    },
                    completion:
                    { _ in
                        
                        cell.hidden = true
                })
            }
            
        case .Changed:
            
            if let indexPath = tableView.indexPathForLocation(location),
                let sourceIndexPath = self.sourceIndexPath,
                let snapshot = self.snapshot,
                let offset = draggingOffset
            {
                UIView.animateWithDuration(0.25) { snapshot.center.y = location.y - offset.y }
                
                if indexPath != sourceIndexPath
                {
                    // ... update data source.
                    if let o1 = fetchedResultsController?.objectAtIndexPath(indexPath), let
                        o2 = fetchedResultsController?.objectAtIndexPath(sourceIndexPath)
                    {
                        if let v1 = o1.valueForKey("sortOrder"), let v2 = o2.valueForKey("sortOrder")
                        {
                            o2.setValue(v1, forKey: "sortOrder")
                            o1.setValue(v2, forKey: "sortOrder")
                        }
                    }
                    
                    // ... move the rows.
                    tableView.moveRowAtIndexPath(sourceIndexPath, toIndexPath: indexPath)
                    
                    // ... and update source so it is in sync with UI changes.
                    self.sourceIndexPath = indexPath
                }
            }
            
        default:
            if let currentIndexPath = sourceIndexPath,
                let cell = tableView.cellForRowAtIndexPath(currentIndexPath),
                let snapshot = self.snapshot
            {
                cell.hidden = false
                cell.alpha = 0
                
                UIView.animateWithDuration(0.25,
                    animations:
                    {
                        snapshot.center = cell.center
                        snapshot.transform = CGAffineTransformIdentity;
                    },
                    completion:
                    { (completed) -> Void in
                        
                        cell.alpha = 1
                        
                        UIView.animateWithDuration(0.25,
                            animations:
                            {
                                //fade out shadow
                                snapshot.alpha = 0
                            },
                            completion:
                            { (completed) -> Void in
                                self.sourceIndexPath = nil
                                snapshot.removeFromSuperview()
                                self.snapshot = nil
                                self.ignoreControllerChanges = false
                        })
                })
            }
        }
    }
}
