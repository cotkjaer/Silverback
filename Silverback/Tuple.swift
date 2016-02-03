//
//  Tuple.swift
//  Silverback
//
//  Created by Christian Otkjær on 14/12/15.
//  Copyright © 2015 Christian Otkjær. All rights reserved.
//

import Foundation

public func sorted <T: Comparable> (tuple: (T, T)) -> (T, T)
{
    let (first, last) = tuple
    
    if first <= last
    {
        return (first, last)
    }
    else
    {
        return (last, first)
    }
}
