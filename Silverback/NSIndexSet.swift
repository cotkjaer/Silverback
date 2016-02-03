//
//  NSIndexSet.swift
//  Silverback
//
//  Created by Christian Otkjær on 01/10/15.
//  Copyright © 2015 Christian Otkjær. All rights reserved.
//

import Foundation

// MARK: - Sets and NSIndexSet

extension NSIndexSet
{
    public convenience init<S:SequenceType where S.Generator.Element == Int>(indicies: S)
    {
        let mutable = NSMutableIndexSet()
        
        indicies.forEach { mutable.addIndex($0) }
        
        self.init(indexSet: mutable)
    }
    
    public var indicies : Set<Int>
        {
            var set = Set<Int>()
        
            enumerateIndexesUsingBlock { set.insert($0.0) }
        
            return set
    }
}