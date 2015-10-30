//
//  HexCollectionViewLayout.swift
//  Silverback
//
//  Created by Christian Otkjær on 22/10/15.
//  Copyright © 2015 Christian Otkjær. All rights reserved.
//

import UIKit

//private let sin60 : CGFloat = 0.866025403784439

public class HexCollectionViewLayout: UICollectionViewLayout
{
    @IBInspectable public var sectionSpacing: CGFloat = 100//sectionInsets : UIEdgeInsets = UIEdgeInsetsZero
    
    @IBInspectable public var sectionGrowthDirection: HexOrientation = .Horizontal
    
    
    public var numberOfHexesToFitHorizontally : CGFloat?
        { didSet { if numberOfHexesToFitHorizontally != oldValue { invalidateLayout() } } }
    
    public var numberOfHexesToFitVertically : CGFloat?
        { didSet { if numberOfHexesToFitVertically != oldValue { invalidateLayout() } } }
    
    //    public var fitLines : Bool = false
    //        { didSet { if fitLines != oldValue { invalidateLayout() } } }
    
    /**
    Defines the orientation of the Hexagons
    
    * Vertical : The Hexagons points in the vertical direction, and are arranged in horizontal lines
    * Horizontal : The Hexagons points in the horizontal direction, and are arranged in vertical lines
    
    */
    public var hexOrientation : HexOrientation = .Horizontal
        { didSet { if hexOrientation != oldValue { invalidateLayout() } } }
    
    public struct ScrollDirection : OptionSetType, BooleanType
    {
        public let rawValue: UInt
        public init(nilLiteral: ())                     { self.init(rawValue: 0) }
        public init(_ rawValue: UInt = 0)               { self.init(rawValue: rawValue) }
        public init(rawValue: UInt)                     { self.rawValue = rawValue }
        
        public var boolValue: Bool                      { return self.rawValue != 0 }
        public static var allZeros: ScrollDirection   { return self.init(0) }
        
        public static var None: ScrollDirection       { return self.init(0b0000) }
        public static var Horizontal: ScrollDirection { return self.init(0b0001) }
        public static var Vertical: ScrollDirection   { return self.init(0b0010) }
        public static var Both: ScrollDirection       { return self.init(0b0011) }
    }
    
    /**
     Defines the contraints imposed on scrolling the `collectionView`.
     
     * None - No scrolling; the `collectionView` CANNOT scroll
     * Horizontal - The `collectionView` is allowed to scroll in the horizontal direction
     * Vertical - The `collectionView` is allowed to scroll in the vertical direction
     * Both - The `collectionView` is allowed to scroll in both horizontal and vertical direction
     */
    @IBInspectable public var scrollDirections: ScrollDirection = .Both { didSet { invalidateLayout() } }
    
    /**
     The sidelength of the Hexagons
     Default value is 20.
     */
    @IBInspectable public var preferredHexSideLength : CGFloat = 100 { didSet { invalidateLayout() } }
    
    /**
     Defines the distance between hexes (measured orthogonal on the hexagon sides)
     
     The default value is 0 points.
     */
    @IBInspectable public var interHexSpacing : CGFloat = 0 { didSet { invalidateLayout() } }
    
    
    /**
     Defines the margin around each hex hexes (measured orthogonal on the hexagon sides)
     
     The default value is 0 points
     */
    @IBInspectable public var hexMargin : CGFloat = 0 { didSet { if hexMargin != oldValue { invalidateLayout() } } }
    
    //MARK: - Lines
    
    /**
    Defines the maximum number of hexes allowed per line
    
    The default value is 4.
    */
    @IBInspectable public var numberOfHexesPerLine : Int = 4 { didSet { invalidateLayout() } }
    
    /**
     Defines whether each line of hexes should have the same number of hexes in it, or if every other line will hold N hexes and the other half will hold N - 1
     */
    public var alternateLineLength = true { didSet { invalidateLayout() } }
    
    /**
     Defines the pattern that will modify each lines number of hexes ( subtracting the number in the patter)
     
     //TODO: implement
     */
    public var lineInsetPattern : [UInt] = [0] { didSet { invalidateLayout() } }
    
    var cachedSectionRelativeCenterByItem = Dictionary<Int, CGPoint>()
    
    private func sectionRelativeCenterForItem(item: Int) -> CGPoint
    {
        if let center = cachedSectionRelativeCenterByItem[item] { return center }
        
        let (line, index) = lineAndIndexForItem(item)
        
        var center = CGPoint(x: calculatedMarginedHexSize.width / 2, y: calculatedMarginedHexSize.height / 2)
        
        let indexOffset : CGFloat = line.even ? 0.5 : 0.0
        
        if hexOrientation == .Vertical
        {
            center.x += (CGFloat(index) + indexOffset) * calculatedMarginedHexSize.width
            center.x += (CGFloat(index) + indexOffset) * calculatedInterHexSpace
            
            center.y += (line * 0.75) * calculatedMarginedHexSize.height
            center.y += line * calculatedInterHexSpace * sin60
        }
        else
        {
            center.x += (line * 0.75) * calculatedMarginedHexSize.width
            center.x += line * calculatedInterHexSpace * sin60
            
            center.y += (CGFloat(index) + indexOffset) * calculatedMarginedHexSize.height
            center.y += (CGFloat(index) + indexOffset) * calculatedInterHexSpace
        }
        
        cachedSectionRelativeCenterByItem[item] = center
        
        return center
    }
    
    //MARK: - Init
    
    private func setup()
    {
        cachedItemAttributes.removeAll(keepCapacity: true)
    }
    
    public override init()
    {
        super.init()
        
        setup()
    }
    
    public required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    private var calculatedHexSize : CGSize = CGSizeZero
    private var calculatedMarginedHexSize : CGSize = CGSizeZero
    
    private var calculatedInterHexSpace = CGFloatZero
    private var calculatedHexMargin = CGFloatZero
    
    private var calculatedScale : CGFloat = 1
    
    private func prepareCachedHexDimensions()
    {
        //         pythagoras gives 2 * sin(120 - 90) * hexMargin, but since sin(30) = 0.5 -> hexMargin
        let preferredMarginedHexSideLength = preferredHexSideLength + hexMargin
        
        calculatedScale = 1
        
        if let bounds = self.collectionView?.bounds
        {
            //            var scale = CGFloatZero
            var horizontalScale = CGFloat.max
            
            if let numberOfHexesToFitHorizontally = self.numberOfHexesToFitHorizontally
            {
                if hexOrientation == .Vertical
                {
                    var unscaledLineLength = preferredMarginedHexSideLength * 2 * sin60 * numberOfHexesToFitHorizontally
                    
                    unscaledLineLength += interHexSpacing * (numberOfHexesToFitHorizontally - 1)
                    
                    //                    let constrainedLineLength = bounds.width
                    
                    horizontalScale = bounds.width / unscaledLineLength
                    //                    calculatedScale = constrainedLineLength / unscaledLineLength
                }
                else
                {
                    var unscaledLineLength = preferredMarginedHexSideLength / 2 + preferredMarginedHexSideLength * 1.5 * numberOfHexesToFitHorizontally
                    
                    unscaledLineLength += interHexSpacing * sin60 * (numberOfHexesToFitHorizontally - 1)
                    
                    //                    let constrainedLineLength = bounds.width
                    
                    //                    calculatedScale = constrainedLineLength / unscaledLineLength
                    
                    horizontalScale = bounds.width / unscaledLineLength
                }
            }
            
            var verticalScale = CGFloat.max
            
            if let numberOfHexesToFitVirtically = self.numberOfHexesToFitVertically
            {
                if hexOrientation == .Horizontal
                {
                    var unscaledLineLength = preferredMarginedHexSideLength * 2 * sin60 * numberOfHexesToFitVirtically
                    
                    unscaledLineLength += interHexSpacing * (numberOfHexesToFitVirtically - 1)
                    
                    //                    let constrainedLineLength = bounds.height
                    //
                    //                    calculatedScale = constrainedLineLength / unscaledLineLength
                    
                    verticalScale = bounds.height / unscaledLineLength
                }
                else
                {
                    var unscaledLineLength = preferredMarginedHexSideLength / 2 + preferredMarginedHexSideLength * 1.5 * numberOfHexesToFitVirtically
                    
                    unscaledLineLength += interHexSpacing * sin60 * (numberOfHexesToFitVirtically - 1)
                    
                    //                    let constrainedLineLength = bounds.height
                    //
                    //                    calculatedScale = constrainedLineLength / unscaledLineLength
                    
                    verticalScale = bounds.height / unscaledLineLength
                }
            }
            
            calculatedScale = min(verticalScale, horizontalScale)
            
            
            //        }
            //        if fitLines
            //        {
            //                var unscaledLineLength = preferredMarginedHexSideLength * 2 * sin60 * numberOfHexesPerLine
            //
            //                unscaledLineLength += interHexSpacing * (numberOfHexesPerLine - 1)
            //
            //                let constrainedLineLength = min(bounds.width, bounds.height)
            //                //let constrainedLineLength = hexOrientation == .Vertical ? bounds.width : bounds.height
            //
            //                calculatedScale = constrainedLineLength / unscaledLineLength
            //            }
        }
        //        else
        //        {
        //            calculatedScale = 1
        //        }
        
        let calculatedMarginedHexSideLength = preferredMarginedHexSideLength * calculatedScale
        
        let calculatedHexSideLength = preferredHexSideLength * calculatedScale
        calculatedInterHexSpace = round(interHexSpacing * calculatedScale)
        calculatedHexMargin = round(hexMargin * calculatedScale)
        
        let calculatedHexCircumscribedCircleRadius = round(calculatedHexSideLength)
        let calculatedHexInscribedCircleRadius = round(calculatedHexSideLength * sin60)
        
        if hexOrientation == .Vertical
        {
            calculatedMarginedHexSize = CGSize(
                width: round(calculatedMarginedHexSideLength * 2 * sin60),
                height: round(calculatedMarginedHexSideLength * 2))
            
            calculatedHexSize = CGSize(width: calculatedHexInscribedCircleRadius * 2,
                height: calculatedHexCircumscribedCircleRadius * 2)
        }
        else
        {
            calculatedMarginedHexSize = CGSize(
                width: round(calculatedMarginedHexSideLength * 2),
                height: round(calculatedMarginedHexSideLength * 2 * sin60))
            
            calculatedHexSize = CGSize(width: calculatedHexCircumscribedCircleRadius * 2,
                height: calculatedHexInscribedCircleRadius * 2)
        }
    }
    
    /// Cache for UICollectionViewLayoutAttributes
    var cachedItemAttributes = Dictionary<NSIndexPath, UICollectionViewLayoutAttributes>()
    
    //MARK: - UICollectionViewLayout overrides
    
    public override func invalidateLayout()
    {
        super.invalidateLayout()
        
        cachedItemAttributes.removeAll(keepCapacity: true)
        cachedSectionFrames.removeAll(keepCapacity: true)
        cachedLineAndIndexByItem.removeAll(keepCapacity: true)
        cachedSectionRelativeCenterByItem.removeAll(keepCapacity: true)
        
        //        calculatedCellSize = CGSizeZero
        cachedCollectionViewContentSize = nil
    }
    
    //MARK: prepareLayout()
    
    public override func prepareLayout()
    {
        super.prepareLayout()
        
        if let collectionView = self.collectionView
        {
            prepareCachedHexDimensions()
            
            let sectionCount = collectionView.numberOfSections()
            
            var sectionOffset = CGPointZero//CGPoint(x: collectionView.contentInset.left, y: collectionView.contentInset.top)
            
            for section in 0..<sectionCount
            {
                var sectionFrame = CGRect(origin: sectionOffset, size: CGSizeZero)
                
                let itemCount = collectionView.numberOfItemsInSection(section)
                
                for item in 0..<itemCount
                {
                    let indexPath = NSIndexPath(forItem: item, inSection: section)
                    
                    let attributes = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
                    
                    attributes.size = calculatedHexSize
                    attributes.center = sectionRelativeCenterForItem(item) + sectionOffset
                    
                    cachedItemAttributes[indexPath] = attributes
                    
                    sectionFrame.unionInPlace(attributes.frame)
                }
                
                cachedSectionFrames[section] = sectionFrame
                
                if sectionGrowthDirection == .Vertical //hexOrientation == .Vertical
                {
                    sectionOffset.y = sectionFrame.maxY + sectionSpacing
                }
                else
                {
                    sectionOffset.x = sectionFrame.maxX + sectionSpacing
                }
            }
        }
    }
    
    // MARK: Layout Attributes
    
    private var cachedLineAndIndexByItem = Dictionary<Int, (Int, Int)>()
    
    func lineAndIndexForItem(item: Int) -> (line: Int, index: Int)
    {
        if let res = cachedLineAndIndexByItem[item]
        {
            return res
        }
        
        let itemsInUpperLine = numberOfHexesPerLine - (alternateLineLength ? 1 : 0)
        
        let itemsInLowerLine = numberOfHexesPerLine
        
        let twoLinesItemCount = itemsInLowerLine + itemsInUpperLine
        
        var index = (item % twoLinesItemCount)
        
        var line = (item / twoLinesItemCount)
        line = line * 2
        
        if index >= itemsInUpperLine
        {
            line += 1
            index -= itemsInUpperLine
        }
        
        let res = (line, index)
        
        cachedLineAndIndexByItem[item] = res
        
        return res
    }
    
    // MARK: layoutAttributesForItemAtIndexPath()
    
    public override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes?
    {
        return cachedItemAttributes[indexPath]!
    }
    
    // MARK: layoutAttributesForElementsInRect()
    
    override public func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]?
    {
        //TODO: Needs to be reworked to perform
        
        return cachedItemAttributes.values.filter({ CGRectIntersectsRect($0.frame, rect) } )
    }
    
    public override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool
    {
        if let collectionView = self.collectionView
        {
            return newBounds.size != collectionView.bounds.size
        }
        
        return false
    }
    
    // MARK: collectionViewContentSize()
    
    private var cachedCollectionViewContentSize : CGSize?
    
    override public func collectionViewContentSize() -> CGSize
    {
        if let size = cachedCollectionViewContentSize
        {
            return size
        }
        
        if let _ = self.collectionView
            //            ,
            //            let lastIndexPath = collectionView.lastIndexPath
        {
            let sectionsFrame = cachedSectionFrames.values.reduce(CGRectZero) { CGRectUnion($0, $1) }
            
            cachedCollectionViewContentSize = sectionsFrame.size
            
            return cachedCollectionViewContentSize!
        }
        
        return CGSizeZero
    }
    
    //MARK: - Section frames
    
    private var cachedSectionFrames = Dictionary<Int, CGRect>()
    
    public func sectionsIntersectingRect(rect: CGRect) -> [Int]
    {
        return cachedSectionFrames.filter({ CGRectIntersectsRect($0.1, rect) }).map({ $0.0 } )
    }
    
    public func frameForSection(section: Int) -> CGRect?
    {
        return cachedSectionFrames[section]
    }
    
    //MARK: - helpers
    
    public static func sideLengthToFit(hexCount: Int, whithOrientation orientation: HexOrientation, inSize:CGSize) -> CGFloat
    {
        if orientation == .Vertical
        {
            return inSize.width / (hexCount * 2 * sin60)
        }
        
        return inSize.height / (hexCount * 2 * sin60)
    }
}

