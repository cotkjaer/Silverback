//
//  NSRange.swift
//  Silverback
//
//  Created by Christian Otkjær on 02/11/15.
//  Copyright © 2015 Christian Otkjær. All rights reserved.
//

import Foundation

// MARK: - String

extension NSRange
{
    public func rangeInString(string: String) -> Range<String.Index>
    {
        let startIndex = string.startIndex.advancedBy(location)
        let endIndex = startIndex.advancedBy(length)
        return startIndex..<endIndex
    }
}

extension NSRange
{
    public init(location: Int, length: Int)
    {
        self.location = location
        self.length = length
    }
    
    public init(range: Range<Int>)
    {
        location = range.startIndex
        length = range.endIndex - range.startIndex
    }
    
    public var startIndex: Int { get { return location } }
    public var endIndex: Int { get { return location + length } }
    public var asRange: Range<Int> { get { return location..<location + length } }
    public var isEmpty: Bool { get { return length == 0 } }
    
    public func contains(index: Int) -> Bool
    {
        return index >= location && index < endIndex
    }
    
    public func clamp(index: Int) -> Int
    {
        return max(startIndex, min(endIndex - 1, index))
    }
    
    public func intersects(range: NSRange) -> Bool
    {
        return NSIntersectionRange(self, range).isEmpty == false
    }
    
    public func intersection(range: NSRange) -> NSRange
    {
        return NSIntersectionRange(self, range)
    }
    
    public func union(range: NSRange) -> NSRange
    {
        return NSUnionRange(self, range)
    }
}
