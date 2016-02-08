//
//  FetchedResultsCollectionViewController.swift
//  Silverback
//
//  Created by Christian Otkjær on 02/02/16.
//  Copyright © 2016 Christian Otkjær. All rights reserved.
//

import UIKit
import CoreData

public class FetchedResultsCollectionViewController: UICollectionViewController, NSFetchedResultsControllerDelegate, ManagedObjectDetailControllerDelegate
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
        
        //        setupGestureRecognizer()
        
        fetch()
        
        if #available(iOS 9.0, *)
        {
            setupRearranging()
        }
    }

    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: UICollectionViewDataSource
    
    override public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return fetchedResultsController?.sections?.count ?? 0
    }
    
    
    override public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return fetchedResultsController?.sections?.get(section)?.numberOfObjects ?? 0
    }
    
    public func cellReuseIdentifierForIndexPath(indexPath: NSIndexPath) -> String
    {
        return "Cell"
    }
    
    public func configureCell(cell: UICollectionViewCell, forObject object: NSManagedObject?, atIndexPath indexPath: NSIndexPath)
    {
        debugPrint("override configureCell")
    }
    
    final override public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellReuseIdentifierForIndexPath(indexPath), forIndexPath: indexPath)
        
        configureCell(cell, forObject: objectForIndexPath(indexPath), atIndexPath: indexPath)
        
        return cell
    }
    
    // MARK: - ManagedObjectDetailControllerDelegate
    
    
    public func managedObjectDetailControllerDidFinish(controller: ManagedObjectDetailController, saved: Bool)
    {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Navigation
    
    private func prepareDetailController(detailController: ManagedObjectDetailController, object: NSManagedObject?)
    {
        detailController.managedObjectDetailControllerDelegate = self
        detailController.managedObjectContext = managedObjectContext?.childContext()
        
        if let managedObject = object
        {
            detailController.managedObjectID = managedObject.objectID
        }
    }
    
    override public func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if let controller = segue.destinationViewController as? ManagedObjectDetailController
        {
            prepareDetailController(controller, object: sender as? NSManagedObject)
        }
        
        if let navController = segue.destinationViewController as? UINavigationController,
            let controller = navController.managedObjectDetailController
        {
            prepareDetailController(controller, object: sender as? NSManagedObject)
        }
    }
    
    // MARK: - NSFetchedResultsControllerDelegate
    
    var blockOperation : NSBlockOperation?
    var shouldReloadCollectionView = false
    
    public func controllerWillChangeContent(controller: NSFetchedResultsController)
    {
        shouldReloadCollectionView = false
        blockOperation = NSBlockOperation()
    }
    
    public func controller(
        controller: NSFetchedResultsController,
        didChangeSection sectionInfo: NSFetchedResultsSectionInfo,
        atIndex sectionIndex: Int,
        forChangeType type: NSFetchedResultsChangeType)
    {
        if let collectionView = self.collectionView
        {
            switch type {
                
            case .Insert:
                
                blockOperation?.addExecutionBlock({
                    collectionView.insertSections( NSIndexSet(index: sectionIndex) )
                })
                
            case .Delete:
                
                blockOperation?.addExecutionBlock({
                    collectionView.deleteSections( NSIndexSet(index: sectionIndex) )
                })
                
            case .Update:
                
                blockOperation?.addExecutionBlock({
                    collectionView.reloadSections( NSIndexSet(index: sectionIndex ) )
                })
                
            default:
                break
            }
        }
    }
    
    public func controller(
        controller: NSFetchedResultsController,
        didChangeObject anObject: AnyObject,
        atIndexPath indexPath: NSIndexPath?,
        forChangeType type: NSFetchedResultsChangeType,
        newIndexPath: NSIndexPath?)
    {
        if let collectionView = self.collectionView
        {
            switch type
            {
            case .Insert where newIndexPath != nil:
                
                if collectionView.numberOfSections() > 0
                {
                    if collectionView.numberOfItemsInSection( newIndexPath!.section ) == 0
                    {
                        shouldReloadCollectionView = true
                    }
                    else
                    {
                        blockOperation?.addExecutionBlock { collectionView.insertItemsAtIndexPaths( [newIndexPath!] ) }
                    }
                }
                else
                {
                    shouldReloadCollectionView = true
                }
                
            case .Delete where indexPath != nil:
                
                if collectionView.numberOfItemsInSection( indexPath!.section ) == 1
                {
                    shouldReloadCollectionView = true
                }
                else
                {
                    blockOperation?.addExecutionBlock { collectionView.deleteItemsAtIndexPaths( [indexPath!] ) }
                }
                
            case .Update where indexPath != nil:
                
                blockOperation?.addExecutionBlock { collectionView.reloadItemsAtIndexPaths( [indexPath!] ) }
                
            case .Move where indexPath != nil && newIndexPath != nil:
                
                blockOperation?.addExecutionBlock { collectionView.moveItemAtIndexPath( indexPath!, toIndexPath: newIndexPath! ) }
                
            default:
                debugPrint("funky change")
                
            }
        }
    }
    
    public func controllerDidChangeContent(controller: NSFetchedResultsController)
    {
        // Checks if we should reload the collection view to fix a bug @ http://openradar.appspot.com/12954582
        if shouldReloadCollectionView
        {
            collectionView?.reloadData()
        }
        else if let blockOperation = self.blockOperation
        {
            collectionView?.performBatchUpdates({ blockOperation.start() }, completion: nil)
        }
    }
    
    
    public func controller(controller: NSFetchedResultsController, sectionIndexTitleForSectionName sectionName: String) -> String?
    {
        return sectionName
    }
    
    
    // MARK: UICollectionViewDelegate
    
    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
    return true
    }
    */
    
    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
    return true
    }
    */
    
    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
    return false
    }
    
    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
    return false
    }
    
    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */
    
    // MARK: - Rearranging
    
    var cellBeingDragged : UICollectionViewCell?
    var cachedCellMasksToBounds = false
    var cachedCellCornerRadius = CGFloatZero
    var cachedCellShadowOffset = CGSize(width: 0, height: 5)
    var cachedCellShadowRadius = CGFloat(5)
    var cachedCellShadowOpacity = Float(0.4)
    var cachedCellTransform = CGAffineTransformIdentity

    
    func setupRearranging()
    {
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: "handleLongGesture:")
        collectionView?.addGestureRecognizer(longPressGesture)
    }
    
    @available(iOS 9.0, *)
    func handleLongGesture(gesture: UILongPressGestureRecognizer)
    {
        if let collectionView = self.collectionView
        {
            let location = gesture.locationInView(collectionView)
            
            switch(gesture.state)
            {
            case .Began:
                
                collectionView.superview?.bringSubviewToFront(collectionView)
                
                if let indexPathForPressedItem = collectionView.indexPathForItemAtPoint(location)
                {
                    if let cell = collectionView.cellForItemAtIndexPath(indexPathForPressedItem)
                    {
                        cellBeingDragged = cell
                        cachCell(cell)
                    }
                    collectionView.beginInteractiveMovementForItemAtIndexPath(indexPathForPressedItem)
                }
                
            case .Changed:
                
                debugPrint(gesture.view)
                
                collectionView.updateInteractiveMovementTargetPosition(location)
                
            case .Ended:
                restoreCellBeingDragged()
                collectionView.endInteractiveMovement()
                
            default:
                restoreCellBeingDragged()
                collectionView.cancelInteractiveMovement()
            }
        }
    }
    
    func cachCell(cell: UICollectionViewCell)
    {
        cellBeingDragged = cell
        
        cachedCellCornerRadius = cell.cornerRadius
        cachedCellMasksToBounds = cell.layer.masksToBounds
        cachedCellShadowOffset = cell.layer.shadowOffset
        cachedCellShadowOpacity = cell.layer.shadowOpacity
        cachedCellShadowRadius = cell.layer.shadowRadius
        cachedCellTransform = cell.transform
        
        UIView.animateWithDuration(0.25)
            {
            cell.layer.masksToBounds = false
            cell.layer.cornerRadius = 0
            cell.layer.shadowOffset = CGSize(width: 0, height: 5)
            cell.layer.shadowRadius = 5
            cell.layer.shadowOpacity = 0.4
            cell.transform = CGAffineTransformScale(cell.transform, 1.05, 1.05)
        }
    }
    
    func restoreCellBeingDragged()
    {
        if let cell = cellBeingDragged
        {
        UIView.animateWithDuration(0.25)
            {
                cell.layer.masksToBounds = self.cachedCellMasksToBounds
                cell.layer.cornerRadius = self.cachedCellCornerRadius
                cell.layer.shadowOffset = self.cachedCellShadowOffset
                cell.layer.shadowRadius = self.cachedCellShadowRadius
                cell.layer.shadowOpacity = self.cachedCellShadowOpacity
                cell.transform = self.cachedCellTransform
            }
        }
    }

    override public func collectionView(collectionView: UICollectionView,
        moveItemAtIndexPath sourceIndexPath: NSIndexPath,
        toIndexPath destinationIndexPath: NSIndexPath)
    {
        ignoreControllerChanges = true
        
        // ... update data source.
        if let o1 = fetchedResultsController?.objectAtIndexPath(destinationIndexPath),
            let o2 = fetchedResultsController?.objectAtIndexPath(sourceIndexPath)
        {
            if let key = fetchRequest?.sortDescriptors?.first?.key
            {
                if let v1 = o1.valueForKey(key),
                    let v2 = o2.valueForKey(key)
                {
                    o2.setValue(v1, forKey: key)
                    o1.setValue(v2, forKey: key)
                    fetch()
                }
            }
        }
        ignoreControllerChanges = false
        
    }
    
}
