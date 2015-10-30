//
//  UICollectionView.swift
//  Silverback
//
//  Created by Christian Otkjær on 22/10/15.
//  Copyright © 2015 Christian Otkjær. All rights reserved.
//

import UIKit

public extension UICollectionView
{
    func performBatchUpdates(updates: (() -> Void)?)
    {
        performBatchUpdates(updates, completion: nil)
    }
    
    func reloadSection(section: Int)
    {
        if section >= 0 && section < numberOfSections()
        {
            self.reloadSections(NSIndexSet(index: section))
        }
    }
}

public extension UICollectionView
{
    //MARK: refresh
    
    public func refreshVisible(animated: Bool = true, completion: ((Bool) -> ())? = nil)
    {
        let animations = { self.reloadItemsAtIndexPaths(self.indexPathsForVisibleItems()) }
        
        if animated
        {
            performBatchUpdates(animations, completion: completion)
        }
        else
        {
            animations()
            completion?(true)
        }
    }
}

public extension UICollectionView
{
    public var lastIndexPath : NSIndexPath?
        {
            let section = numberOfSections() - 1
            
            if section >= 0
            {
                let item = numberOfItemsInSection(section) - 1
                
                if item >= 0
                {
                    return NSIndexPath(forItem: item, inSection: section)
                }
            }
            
            return nil
    }
    
    public var firstIndexPath : NSIndexPath?
        {
            if numberOfSections() > 0
            {
                if numberOfItemsInSection(0) > 0
                {
                    return NSIndexPath(forItem: 0, inSection: 0)
                }
            }
            
            return nil
    }
}