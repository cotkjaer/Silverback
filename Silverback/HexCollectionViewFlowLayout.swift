//
//  HexCollectionViewFlowLayout.swift
//  Silverback
//
//  Created by Christian Otkjær on 22/10/15.
//  Copyright © 2015 Christian Otkjær. All rights reserved.
//

import UIKit

public class HexCollectionViewFlowLayout: UICollectionViewFlowLayout
{
    /// describes whether each line of hexes should have the same number of hexes in it, or if every other line will have itemsPerLine and the rest will have itemsPerLine - 1
    var alternateLineLength = true { didSet { invalidateLayout() } }
    
    var itemsPerLine : Int? { didSet { invalidateLayout() } }
    
    
    init(flowLayout: UICollectionViewFlowLayout)
    {
        super.init()
        
        sectionInset = flowLayout.sectionInset
        
        itemSize = flowLayout.itemSize
        
        minimumLineSpacing = flowLayout.minimumLineSpacing
        minimumInteritemSpacing = flowLayout.minimumInteritemSpacing
        
        scrollDirection = flowLayout.scrollDirection
    }
    
    required public init?(coder aDecoder: NSCoder)
    {
        super.init(coder:aDecoder)
    }
    
    // Mark: Item Size
    
    private func updateCellSize()
    {
        if let itemsPLine = itemsPerLine, let boundsSize = self.collectionView?.bounds.size
        {
            let lineLength = (scrollDirection == .Horizontal ? boundsSize.height : boundsSize.width)
            
            let boundsLength = lineLength / (CGFloat(itemsPLine) + (alternateLineLength ? 0.0 : 0.5))
            
            var size = CGSize(width: boundsLength, height: boundsLength)
            
            switch scrollDirection
            {
            case .Horizontal:
                size.width /= sin60
                
            case .Vertical:
                size.height = size.height / sin60
            }
            
            itemSize = size
        }
    }
    
    //Mark: - UICollectionViewLayout overrides
    
    override public func invalidateLayout()
    {
        updateCellSize()
        
        super.invalidateLayout()
    }
    
    override public func prepareLayout()
    {
        attributesCache.removeAll(keepCapacity: true)
        
        super.prepareLayout()
    }
    
    override public func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]?
    {
        if let numberOfItems = self.collectionView?.numberOfItemsInSection(0)
        {
            return (0..<numberOfItems).map({ self.layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: $0, inSection: 0))! } )
        }
        
        return nil
    }
    
    var attributesCache = Dictionary<NSIndexPath, UICollectionViewLayoutAttributes>()
    
    func rowAndColForIndexPath(indexPath: NSIndexPath) -> (row: Int, col: Int)
    {
        let itemsInUpperLine = (itemsPerLine ?? 1) - (alternateLineLength ? 1 : 0)
        
        let itemsInLowerLine = (itemsPerLine ?? 1)
        
        let twoLinesItemCount = itemsInLowerLine + itemsInUpperLine
        
        var col = (indexPath.item % twoLinesItemCount)
        
        var row = (indexPath.item / twoLinesItemCount)
        row = row * 2
        
        if col >= itemsInUpperLine
        {
            row += 1
            col -= itemsInUpperLine
        }
        
        debugPrint("item: \(indexPath.item) -> (\(row), \(col))")
        
        return (row, col)
    }
    
    override public func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes?
    {
        if let attributes = attributesCache[indexPath]
        {
            return attributes
        }
        
        let attributes = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
        
        attributes.size = self.itemSize
        
        let (row, col) = rowAndColForIndexPath(indexPath)
        
        if scrollDirection == .Vertical
        {
            
            let horiOffset : CGFloat = ((row % 2) != 0) ? 0 : self.itemSize.width * 0.5
            let vertOffset : CGFloat = 0
            
            
            attributes.center = CGPoint(
                x: ( (col * self.itemSize.width) + (0.5 * self.itemSize.width) + horiOffset),
                y: ( ( (row * 0.75) * self.itemSize.height) + (0.5 * self.itemSize.height) + vertOffset) )
            
        }
        else
        {
            let horiOffset : CGFloat = 0
            let vertOffset : CGFloat = ((row % 2) != 0) ? 0 : self.itemSize.height * 0.5
            
            attributes.center = CGPoint(
                x: ( ( (row * 0.75) * itemSize.width) + (0.5 * itemSize.width) + horiOffset),
                y: ( (col * itemSize.height) + (0.5 * itemSize.height) + vertOffset) )
        }
        
        attributesCache[indexPath] = attributes
        
        return attributes
    }
    
    override public func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool
    {
        return false
    }
    
    //    private var lastIndexPath : NSIndexPath?
    //        {
    //            if let collectionView = self.collectionView
    //            {
    //                let section = collectionView.numberOfSections() - 1
    //
    //                if section >= 0
    //                {
    //                    let item = collectionView.numberOfItemsInSection(section) - 1
    //
    //                    if item >= 0
    //                    {
    //                        return NSIndexPath(forItem: item, inSection: section)
    //                    }
    //                }
    //            }
    //
    //            return nil
    //    }
    
    private var cachedCollectionViewContentSize : CGSize?
    
    override public func collectionViewContentSize() -> CGSize
    {
        if let size = cachedCollectionViewContentSize
        {
            return size
        }
        
        if let collectionView = self.collectionView,
            let lastIndexPath = collectionView.lastIndexPath,
            let attributes = layoutAttributesForItemAtIndexPath(lastIndexPath)
        {
            return CGSize(
                width: max(collectionView.bounds.width, attributes.frame.maxX),
                height: max(collectionView.bounds.height, attributes.frame.maxY))
        }
        
        return CGSizeZero
    }
}
