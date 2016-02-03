//
//  CGSize.swift
//  SilverbackFramework
//
//  Created by Christian Otkjær on 20/04/15.
//  Copyright (c) 2015 Christian Otkjær. All rights reserved.
//

import CoreGraphics

// MARK: - CGSize

extension CGSize
{
    public init(widthAndHeight: CGFloat)
    {
        self.width = widthAndHeight
        self.height = widthAndHeight
    }
    
    // MARK: with
    
    public func with(width  width: CGFloat) -> CGSize
    {
        return CGSize(width: width, height: height)
    }
    
    public func with(height  height: CGFloat) -> CGSize
    {
        return CGSize(width: width, height: height)
    }
    
    ///Returns *true* if `size` fits inside `self`
    public func fits(size: CGSize) -> Bool
    {
        return width >= size.width && height >= size.height
    }
}


//MARK: - Width and Height

extension CGSize
{
    public var minWidthHeight : CGFloat { return min(width, height) }
    public var maxWidthHeight : CGFloat { return max(width, height) }
}

// MARK: Equatable
//
//extension CGSize//: Equatable
//{
//    public func isEqualTo(size:CGSize) -> Bool
//    {
//        return self == size
//    }
//}
//
//public func == (s1: CGSize, s2: CGSize) -> Bool
//{
//    return s1.width == s2.width && s1.height == s2.height
//}

// MARK: - ceil

public func ceil(size: CGSize) -> CGSize
{
    return CGSize(width: ceil(size.width), height: ceil(size.height))
}

// MARK: - floor

public func floor(size: CGSize) -> CGSize
{
    return CGSize(width: floor(size.width), height: floor(size.height))
}


// MARK: operators

public func + (s1: CGSize, s2: CGSize) -> CGSize
{
    return CGSize(width: s1.width + s2.width, height: s1.height + s2.height)
}

public func += (inout s1: CGSize, s2: CGSize)
{
    s1.width += s2.width
    s1.height += s2.height
}

public func - (s1: CGSize, s2: CGSize) -> CGSize
{
    return CGSize(width: s1.width - s2.width, height: s1.height - s2.height)
}

public func -= (inout s1: CGSize, s2: CGSize)
{
    s1.width -= s2.width
    s1.height -= s2.height
}

public func * (size: CGSize, factor: CGFloat) -> CGSize
{
    return CGSize(width: size.width * factor, height: size.height * factor)
}

public func * (factor: CGFloat, size: CGSize) -> CGSize
{
    return size * factor
}

public func *= (inout size: CGSize, factor: CGFloat)
{
    size.width *= factor
    size.height *= factor
}

public func / (size: CGSize, factor: CGFloat) -> CGSize
{
    return CGSize(width: size.width / factor, height: size.height / factor)
}

public func /= (inout size: CGSize, factor: CGFloat)
{
    size.width /= factor
    size.height /= factor
}

public func * (size: CGSize, transform: CGAffineTransform) -> CGSize
{
    return CGSizeApplyAffineTransform(size, transform)
}

public func *= (inout size: CGSize, transform: CGAffineTransform)
{
    size = size * transform//CGSizeApplyAffineTransform(size, transform)
}

