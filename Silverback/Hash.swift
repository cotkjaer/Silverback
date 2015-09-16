//
//  Hash.swift
//  Silverback
//
//  Created by Christian Otkjær on 16/09/15.
//  Copyright © 2015 Christian Otkjær. All rights reserved.
//

import Foundation

public func hash(seed seed: Int = 11, hashValues: Int...) -> Int
{
    return hashValues.reduce(0, combine: { (combinedHashValue, hashValue) -> Int in
        
        return seed &* combinedHashValue &+ hashValue
    })
}