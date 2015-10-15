//
//  Hash.swift
//  Silverback
//
//  Created by Christian Otkjær on 16/09/15.
//  Copyright © 2015 Christian Otkjær. All rights reserved.
//

import Foundation

public func hash(seed seed: Int = 11, hashValuesArray: [Int]) -> Int
{
    return hashValuesArray.reduce(0, combine: { (combinedHashValue, hashValue) -> Int in
        
        return seed &* combinedHashValue &+ hashValue
    })
}

public func hash(seed seed: Int = 11, _ hashValues: Int...) -> Int
{
    return hash(seed: seed, hashValuesArray:hashValues)
}