//
//  UICollectionView.swift
//  Silverback
//
//  Created by Christian Otkjær on 22/10/15.
//  Copyright © 2015 Christian Otkjær. All rights reserved.
//

import UIKit

// MARK: - CustomDebugStringConvertible

extension UICollectionViewScrollDirection : CustomDebugStringConvertible, CustomStringConvertible
{
    public var description : String { return debugDescription }
    
    public var debugDescription : String
        {
            switch self
            {
            case .Vertical: return "Vertical"
            case .Horizontal: return "Horizontal"
            }
    }
}


//MARK: - IndexPaths

extension UICollectionView
{
    //    public func visibleCells() -> [UICollectionViewCell]
    //    {
    //        return indexPathsForVisibleItems().flatMap{ self.cellForItemAtIndexPath($0) }
    //    }
    
    public func indexPathForLocation(location : CGPoint) -> NSIndexPath?
    {
        for cell in visibleCells()
        {
            if cell.bounds.contains(location.convert(fromView: self, toView: cell))
            {
                return indexPathForCell(cell)
            }
        }
        
        return nil
    }
    
    public func indexPathForView(view: UIView) -> NSIndexPath?
    {
        let superviews = view.superviews
        
        if let myIndex = superviews.indexOf(self)
        {
            if let cell = Array(superviews[myIndex..<superviews.count]).cast(UICollectionViewCell).first
            {
                return indexPathForCell(cell)
            }
        }
        
        return nil
    }
}

public class LERPCollectionViewLayout: UICollectionViewLayout
{
    public enum Alignment
    {
        case Top, Bottom, Left, Right
    }
    
    public var alignment = Alignment.Left { didSet { if oldValue != alignment { invalidateLayout() } } }
    
    public enum Axis
    {
        case Vertical, Horizontal
    }
    
    public var axis = Axis.Horizontal { didSet { if oldValue != axis { invalidateLayout() } } }
    
    public enum Distribution
    {
        case Fill, Stack
    }
    
    public var distribution = Distribution.Fill { didSet { if oldValue != distribution { invalidateLayout() } } }
    
    private var attributes = Array<UICollectionViewLayoutAttributes>()
    
    override public func prepareLayout()
    {
        super.prepareLayout()
        
        attributes.removeAll()
        
        if let sectionCount = collectionView?.numberOfSections()
        {
            for section in 0..<sectionCount
            {
                if let itemCount = collectionView?.numberOfItemsInSection(section)
                {
                    for item in 0..<itemCount
                    {
                        let indexPath = NSIndexPath(forItem: item, inSection: section)
                        
                        if let attrs = layoutAttributesForItemAtIndexPath(indexPath)
                        {
                            attributes.append(attrs)
                        }
                    }
                }
            }
        }
    }
    
    override public func collectionViewContentSize() -> CGSize
    {
        if var frame = attributes.first?.frame
        {
            for attributesForItemAtIndexPath in attributes
            {
                frame.unionInPlace(attributesForItemAtIndexPath.frame)
            }
            
            return CGSize(width: frame.right, height: frame.top)
        }
        
        return CGSizeZero
    }
    
    override public func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool
    {
        return collectionView?.bounds != newBounds
    }
    
    override public func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]?
    {
        var attributesForElementsInRect = [UICollectionViewLayoutAttributes]()
        
        for attributesForItemAtIndexPath in attributes
        {
            if CGRectIntersectsRect(attributesForItemAtIndexPath.frame, rect)
            {
                attributesForElementsInRect.append(attributesForItemAtIndexPath)
            }
        }
        
        return attributesForElementsInRect
    }
    
    func factorForIndexPath(indexPath: NSIndexPath) -> CGFloat
    {
        if let itemCount = collectionView?.numberOfItemsInSection(indexPath.section)
        {
            let factor = itemCount > 1 ? CGFloat(indexPath.item) / (itemCount - 1) : 0
            
            return factor
        }
        
        return 0
    }
    
    func zIndexForIndexPath(indexPath: NSIndexPath) -> Int
    {
        if let selectedItem = collectionView?.indexPathsForSelectedItems()?.first?.item,
            let itemCount = collectionView?.numberOfItemsInSection(indexPath.section)
        {
            
            return itemCount - abs(selectedItem - indexPath.item)
        }
        
        return 0
    }
    
    override public func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes?
    {
        if let collectionView = self.collectionView
            //            let attrs = super.layoutAttributesForItemAtIndexPath(indexPath)
        {
            let attrs = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
            
            let factor = factorForIndexPath(indexPath)
            
            let l = ceil(min(collectionView.bounds.height, collectionView.bounds.width))
            let l_2 = l / 2
            
            var lower = collectionView.contentOffset + CGPoint(x: l_2, y: l_2)
            var higher = lower//CGPoint(x: l_2, y: l_2)
            
            switch axis
            {
            case .Horizontal:
                higher.x += collectionView.bounds.width - l
            case .Vertical:
                higher.y += collectionView.bounds.height - l
            }
            
            switch alignment
            {
            case .Top, .Left:
                break
                
            case .Bottom:
                swap(&higher.y, &lower.y)
                
            case .Right:
                swap(&higher.x, &lower.x)
            }
            
            attrs.frame = CGRect(center: lerp(lower, higher, factor), size: CGSize(widthAndHeight: l))
            
            attrs.zIndex = zIndexForIndexPath(indexPath)
            
            return attrs
        }
        
        return nil
    }
}




//MARK: - FlowLayout

extension UICollectionViewController
{
    public var flowLayout : UICollectionViewFlowLayout? { return collectionViewLayout as? UICollectionViewFlowLayout }
}

//MARK: - batch updates

public extension UICollectionView
{
    public func performBatchUpdates(updates: (() -> Void)?)
    {
        performBatchUpdates(updates, completion: nil)
    }
    
    public func reloadSection(section: Int)
    {
        if section >= 0 && section < numberOfSections()
        {
            self.reloadSections(NSIndexSet(index: section))
        }
    }
}

//MARK: refresh

public extension UICollectionView
{
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

// MARK: - Index Paths

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

// MARK: - TODO: Move to own file

class PaginationCollectionViewFlowLayout: UICollectionViewFlowLayout
{
    init(flowLayout: UICollectionViewFlowLayout)
    {
        super.init()
        
        itemSize = flowLayout.itemSize
        sectionInset = flowLayout.sectionInset
        minimumLineSpacing = flowLayout.minimumLineSpacing
        minimumInteritemSpacing = flowLayout.minimumInteritemSpacing
        scrollDirection = flowLayout.scrollDirection
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder:aDecoder)
    }
    
    func applySelectedTransform(attributes: UICollectionViewLayoutAttributes?) -> UICollectionViewLayoutAttributes?
    {
        return attributes
    }
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]?
    {
        if let layoutAttributesList = super.layoutAttributesForElementsInRect(rect)
        {
            return layoutAttributesList.map( self.applySelectedTransform )
        }
        
        return nil
    }
    
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes?
    {
        let attributes = super.layoutAttributesForItemAtIndexPath(indexPath)
        
        return applySelectedTransform(attributes)
    }
    
    // Mark : - Pagination
    
    var pageWidth : CGFloat { return itemSize.width + minimumLineSpacing }
    
    let flickVelocity : CGFloat = 0.3
    
    override func targetContentOffsetForProposedContentOffset(proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint
    {
        var contentOffset = proposedContentOffset
        
        if let collectionView = self.collectionView
        {
            let rawPageValue = collectionView.contentOffset.x / pageWidth
            
            let currentPage = velocity.x > 0 ? floor(rawPageValue) : ceil(rawPageValue)
            
            let nextPage = velocity.x > 0 ? ceil(rawPageValue) : floor(rawPageValue);
            
            let pannedLessThanAPage = abs(1 + currentPage - rawPageValue) > 0.5
            
            let flicked = abs(velocity.x) > flickVelocity
            
            if pannedLessThanAPage && flicked
            {
                contentOffset.x = nextPage * pageWidth
            }
            else
            {
                contentOffset.x = round(rawPageValue) * pageWidth
            }
        }
        
        return contentOffset
    }
}