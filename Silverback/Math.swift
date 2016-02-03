//
//  Math.swift
//  Silverback
//
//  Created by Christian Otkjær on 14/12/15.
//  Copyright © 2015 Christian Otkjær. All rights reserved.
//


public protocol Subtractable
{
    func - (lhs: Self, rhs: Self) -> Self
}

public protocol Addable
{
    func + (lhs: Self, rhs: Self) -> Self
}

extension Double : Addable, Subtractable {}
extension Float : Addable, Subtractable {}
extension Int : Addable, Subtractable {}

import CoreGraphics
extension CGFloat : Addable, Subtractable {}


/**
 *  Generator that "strides" through an array two elements at a time.
 */
struct StrindingPair <T>: GeneratorType {
    typealias Element = (T, T?)
    
    var g: Array<T>.Generator
    var e: T?
    
    init(_ a: Array <T>)
    {
        g = a.generate()
        e = g.next()
    }
    
    mutating func next() -> Element?
    {
        if e == nil {
            return nil
        }
        
        let next = g.next()
        let result = (e!, next)
        e = next
        
        return result
    }
}

// MARK: Comparing

public func compare <T: Comparable> (lhs: T, rhs: T) -> Int
{
    return lhs == rhs ? 0 : (lhs > rhs ? 1 : -1)
}


// MARK: - Clamp

public func clamp<T:Comparable>(value: T, minimum: T, maximum: T) -> T
{
    if value > maximum { return maximum }
    if value < minimum { return minimum }
    return value
}
