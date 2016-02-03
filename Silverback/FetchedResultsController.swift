////
////  FetchedResultsController.swift
////  Silverback
////
////  Created by Christian Otkjær on 02/02/16.
////  Copyright © 2016 Christian Otkjær. All rights reserved.
////
//import CoreData
//
//public class FetchedResultsController: NSObject, NSFetchedResultsControllerDelegate
//{
//    /// Set this if you are updating the data "manually" (e.g. when rearranging a table- or collectionView)
//    public var ignoreChanges: Bool = false
//    
//    public var managedObjectContext : NSManagedObjectContext?
//    
//    public var sectionNameKeyPath: String? { didSet { if oldValue != sectionNameKeyPath { updateFetchedResultsController() } } }
//    
//    public var fetchRequest: NSFetchRequest? { didSet { if oldValue != fetchRequest { updateFetchedResultsController() } } }
//    
//    private var fetchedResultsController: NSFetchedResultsController? { didSet { setNeedsFetch() } }
//    
//    private func updateFetchedResultsController()
//    {
//        if let context = managedObjectContext,
//            let fetchRequest = self.fetchRequest
//        {
//            let frc = NSFetchedResultsController(
//                fetchRequest: fetchRequest,
//                managedObjectContext: context,
//                sectionNameKeyPath: sectionNameKeyPath,
//                cacheName: nil)
//            
//            frc.delegate = self
//            
//            fetchedResultsController = frc
//            
//            setNeedsFetch()
//        }
//        else
//        {
//            fetchedResultsController = nil
//        }
//    }
//    
//    public private(set) var needsFecth = false
//    
//    public func setNeedsFetch()
//    {
//        needsFecth = true
//    }
//    
//    public func fetch()
//    {
//        do
//        {
//            try fetchedResultsController?.performFetch()
//            needsFecth = false
//        }
//        catch let error
//        {
//            print("Error: \(error)")
//        }
//    }
//    
//    // MARK: - Objects
//    
//    public func objectForIndexPath(optionalIndexPath: NSIndexPath?) -> NSManagedObject?
//    {
//        if let indexPath = optionalIndexPath
//        {
//            return fetchedResultsController?.objectAtIndexPath(indexPath) as? NSManagedObject
//        }
//        
//        return nil
//    }
//    
//    public func indexPathForObject(optionalObject: NSManagedObject?) -> NSIndexPath?
//    {
//        if let object = optionalObject
//        {
//            return fetchedResultsController?.indexPathForObject(object)
//        }
//        
//        return nil
//    }
//    
//    public func indexPathForObjectWithID(optionalID: NSManagedObjectID?) -> NSIndexPath?
//    {
//        if let id = optionalID, let object = fetchedResultsController?.fetchedObjects?.find({ $0.objectID == id }) as? NSManagedObject
//        {
//            return indexPathForObject(object)
//        }
//        
//        return nil
//    }
//    
//    public func numberOfObjects(inSection: Int? = nil) -> Int
//    {
//        if let section = inSection
//        {
//            return fetchedResultsController?.numberOfObjectsInSection(section) ?? 0
//        }
//        
//        return fetchedResultsController?.fetchedObjects?.count ?? 0
//    }
//
//    public func numberOfSections() -> Int
//    {
//        return fetchedResultsController?.sections?.count ?? 0
//    }
//
//    // MARK: - closures
//    
//    public var beginUpdates : (() -> ())?
//    public var endUpdates : (() -> ())?
//    
//    // MARK: - NSFetchedResultsControllerDelegate
//
//    public func controllerWillChangeContent(controller: NSFetchedResultsController)
//    {
//        debugPrint("\(self) will change")
//        
//        if !ignoreChanges
//        {
//            beginUpdates?()
//        }
//    }
//    
//    public func controllerDidChangeContent(controller: NSFetchedResultsController)
//    {
//        debugPrint("\(self) did change")
//        if !ignoreChanges
//        {
//            endUpdates?()
//        }
//    }
//    
//    var onChange : ((ObjectChange)->())?
//    
//    public enum ObjectChange
//    {
//        case Insert(AnyObject, NSIndexPath)
//        case Delete(AnyObject, NSIndexPath)
//        case Update(AnyObject, NSIndexPath)
//        case Move(AnyObject, NSIndexPath, NSIndexPath)
//    }
//    
//    public func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?)
//    {
//        if !ignoreChanges
//        {
//            switch type
//            {
//            case .Insert:
//                
//                if let insertIndexPath = newIndexPath, let object = anObject as? NSManagedObject
//                {
//                    debugPrint("\(self) did insert \(object) at \(insertIndexPath)")
//                    
//                    onChange?(ObjectChange.Insert(object, insertIndexPath))
//                }
//                
//            case .Delete:
//                
//                if let deleteIndexPath = indexPath, let object = anObject as? NSManagedObject
//                {
//                    debugPrint("\(self) did delete \(object) at \(deleteIndexPath)")
//                    
//                    onChange?(ObjectChange.Delete(object, deleteIndexPath))
//                }
//                
//            case .Update:
//                
//                if let updatedIndexPath = indexPath,
//                    let object = anObject as? NSManagedObject//objectForIndexPath(updatedIndexPath)
//                {
//                    debugPrint("\(self) did update \(object) as \(updatedIndexPath)")
//                    
//                    onChange?(ObjectChange.Update(object, updatedIndexPath))
//                }
//                
//            case .Move:
//                
//                if let deleteIndexPath = indexPath, let insertIndexPath = newIndexPath
//                {
//                    debugPrint("\(self) did move: \(deleteIndexPath) -> \(insertIndexPath)")
//                    
//                    tableView.deleteRowsAtIndexPaths([deleteIndexPath], withRowAnimation: UITableViewRowAnimation.Fade)
//                    tableView.insertRowsAtIndexPaths([insertIndexPath], withRowAnimation: UITableViewRowAnimation.Fade)
//                }
//            }
//        }
//    }
//    
//    public func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType)
//    {
//        if !ignoreChanges
//        {
//            let sectionIndexSet = NSIndexSet(index: sectionIndex)
//            
//            switch type
//            {
//            case .Insert:
//                tableView.insertSections(sectionIndexSet, withRowAnimation: .Fade)
//                
//            case .Delete:
//                tableView.deleteSections(sectionIndexSet, withRowAnimation: .Fade)
//                
//            default:
//                debugPrint("Odd change-type for section \(sectionIndex): \(type)")
//            }
//        }
//    }
//    
//    public func controller(controller: NSFetchedResultsController, sectionIndexTitleForSectionName sectionName: String) -> String?
//    {
//        return sectionName
//    }
//}
//
//// MARK: - Rearrange
//
//extension FetchedResultsTableViewController
//{
//    func customSnapshotFromView(inputView: UIView) -> UIView
//    {
//        UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, false, 0)
//        defer { UIGraphicsEndImageContext() }
//        
//        if let context = UIGraphicsGetCurrentContext()
//        {
//            inputView.layer.renderInContext(context)
//            
//            let image = UIGraphicsGetImageFromCurrentImageContext()
//            
//            let snapshot = UIImageView(image: image)
//            snapshot.layer.masksToBounds = false
//            snapshot.layer.cornerRadius = 0
//            snapshot.layer.shadowOffset = CGSize(width: 0, height: 5)
//            snapshot.layer.shadowRadius = 5
//            snapshot.layer.shadowOpacity = 0.4
//            
//            return snapshot
//        }
//        
//        return UIView()
//    }
//    
//    func setupGestureRecognizer()
//    {
//        let longPress = UILongPressGestureRecognizer(target: self, action: Selector("longPressGestureRecognized:"))
//        tableView.addGestureRecognizer(longPress)
//    }
//    
//    func longPressGestureRecognized(longPress :UILongPressGestureRecognizer)
//    {
//        let location = longPress.locationInView(tableView)
//        
//        switch longPress.state
//        {
//        case .Began:
//            
//            ignoreChanges = true
//            if let indexPath = tableView.indexPathForLocation(location)
//                , let cell = tableView.cellForRowAtIndexPath(indexPath)
//            {
//                sourceIndexPath = indexPath
//                
//                // Take a snapshot of the selected row using helper method.
//                let snapshot = customSnapshotFromView(cell)
//                
//                // Add the snapshot as subview, centered at cell's center...
//                
//                snapshot.center = cell.center
//                snapshot.alpha = 0
//                
//                draggingOffset =  location - cell.center
//                
//                self.snapshot = snapshot
//                
//                tableView.addSubview(snapshot)
//                
//                UIView.animateWithDuration(0.25,
//                    animations:
//                    {
//                        snapshot.transform = CGAffineTransformMakeScale(1.05, 1.05)
//                        snapshot.center.y = location.y - (self.draggingOffset?.y ?? 0)
//                        snapshot.alpha = 1
//                        
//                        // Fade out.
//                        cell.alpha = 0
//                        
//                    },
//                    completion:
//                    { _ in
//                        
//                        cell.hidden = true
//                })
//            }
//            
//        case .Changed:
//            
//            if let indexPath = tableView.indexPathForLocation(location),
//                let sourceIndexPath = self.sourceIndexPath,
//                let snapshot = self.snapshot,
//                let offset = draggingOffset
//            {
//                UIView.animateWithDuration(0.25) { snapshot.center.y = location.y - offset.y }
//                
//                if indexPath != sourceIndexPath
//                {
//                    // ... update data source.
//                    if let o1 = fetchedResultsController?.objectAtIndexPath(indexPath), let
//                        o2 = fetchedResultsController?.objectAtIndexPath(sourceIndexPath)
//                    {
//                        if let v1 = o1.valueForKey("sortOrder"), let v2 = o2.valueForKey("sortOrder")
//                        {
//                            o2.setValue(v1, forKey: "sortOrder")
//                            o1.setValue(v2, forKey: "sortOrder")
//                        }
//                    }
//                    
//                    // ... move the rows.
//                    tableView.moveRowAtIndexPath(sourceIndexPath, toIndexPath: indexPath)
//                    
//                    // ... and update source so it is in sync with UI changes.
//                    self.sourceIndexPath = indexPath
//                }
//            }
//            
//        default:
//            if let currentIndexPath = sourceIndexPath,
//                let cell = tableView.cellForRowAtIndexPath(currentIndexPath),
//                let snapshot = self.snapshot
//            {
//                cell.hidden = false
//                cell.alpha = 0
//                
//                UIView.animateWithDuration(0.25,
//                    animations:
//                    {
//                        snapshot.center = cell.center
//                        snapshot.transform = CGAffineTransformIdentity;
//                    },
//                    completion:
//                    { (completed) -> Void in
//                        
//                        cell.alpha = 1
//                        
//                        UIView.animateWithDuration(0.25,
//                            animations:
//                            {
//                                //fade out shadow
//                                snapshot.alpha = 0
//                            },
//                            completion:
//                            { (completed) -> Void in
//                                self.sourceIndexPath = nil
//                                snapshot.removeFromSuperview()
//                                self.snapshot = nil
//                                self.ignoreChanges = false
//                        })
//                })
//            }
//        }
//    }
//}
