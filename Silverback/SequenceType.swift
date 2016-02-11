//
//  SequenceType.swift
//  Silverback
//
//  Created by Christian Otkjær on 16/09/15.
//  Copyright © 2015 Christian Otkjær. All rights reserved.
//

// MARK: - Iteration

public func max<S : SequenceType where S.Generator.Element:IntegerArithmeticType>(sequence: S) -> S.Generator.Element?
{
    var max: S.Generator.Element? = nil
    
    for e in sequence
    {
        if e > max || max == nil
        {
            max = e
        }
    }
    
    return max
}

public func min<S : SequenceType where S.Generator.Element:IntegerArithmeticType>(sequence: S) -> S.Generator.Element?
{
    var min: S.Generator.Element? = nil
    
    for e in sequence
    {
        if e < min || min == nil
        {
            min = e
        }
    }
    
    return min
}

public extension SequenceType
{
    ///Return true iff **any** of the elements in self satisfies `predicate`
    @warn_unused_result
    func any(@noescape predicate: (Self.Generator.Element) throws -> Bool) rethrows -> Bool
    {
        return try contains(predicate)
    }
    
    ///Return true iff **none** of the elements in self satisfies `predicate`
    @warn_unused_result
    func none(@noescape predicate: (Self.Generator.Element) throws -> Bool) rethrows -> Bool
    {
        return try any{ try !predicate($0) }
    }
    
    ///Return true iff **all** the elements in self satisfies `predicate`
    @warn_unused_result
    func all(@noescape predicate: (Generator.Element) throws -> Bool) rethrows -> Bool
    {
        return try !any{ try !predicate($0) }
    }
    
    
    /**
    counts the elements accepted by `predicate`
    
    - parameter predicate: only elements that are accepted, ie. where the predicate returns *true* when applied to the element are counted
    
    - returns: the number of elements accepted by `predicate`
    */
    func count(@noescape predicate: ((element: Generator.Element) throws -> Bool)) rethrows -> Int
    {
        return try filter(predicate).count
    }
    
    /**
    Iterates on each element of the sequence.
    
    - parameter closure: invoked for each element in `for in` order
    
    Iterations continues until the closure returns **false**
    */
    func iterate(@noescape closure: ((element: Generator.Element) -> Bool))
    {
        for element in self
        {
            if closure(element: element) { break }
        }
    }
    
    /**
    Finds the first element which meets the condition.
    
    - parameter condition: A closure which takes an Element and returns a Bool
    - returns: First element to match contidion or nil, if none matched
    */
    @warn_unused_result
    func find(@noescape condition: Generator.Element -> Bool) -> Generator.Element?
    {
        for element in self
        {
            if condition(element) { return element }
        }
        
        return nil
    }
}

// MARK: - Iterate

public extension SequenceType
{
    /**
     Iterates on each element of the array.
     
     - parameter closure: Function to call for each index x element, setting the stop parameter to true will stop the iteration
     */
    public func iterate(closure: ((index: Int, element: Generator.Element, inout stop: Bool) -> ()))
    {
        var stop : Bool = false
        
        for (index, element) in enumerate()
        {
            closure(index: index, element: element, stop: &stop)
            
            if stop { break }
        }
    }
    
    /**
     Iterates on each element of the array with its index.
     
     - parameter call: Function to call for each element
     */
    public func iterate(closure: ((element: Generator.Element, inout stop: Bool) -> ()))
    {
        var stop : Bool = false
        
        for element in self
        {
            closure(element: element, stop: &stop)
            
            if stop { break }
        }
    }

}


public extension SequenceType where Generator.Element: Hashable
{
    var uniques: [Generator.Element]
        {
            var added = Set<Generator.Element>()
            
            return filter {
                if added.contains($0) { return false }
                else { added.insert($0); return true }
            }
    }
    
    /**
    Checks whether this sequence shares any elements with `sequence`
    
    - parameter sequence: optional sequence of the same type of elements
    
    - returns: **true** if the two sequences share any elements
    */
    @warn_unused_result
    func intersects<S : SequenceType where S.Generator.Element == Generator.Element>(sequence: S?) -> Bool
    {
        return sequence?.contains({ contains($0) }) ?? false
    }
}

extension SequenceType where Generator.Element == String
{
    @warn_unused_result
    public func joinedWithSeparator(separator: String, prefix: String, suffix: String) -> String
    {
        return map{ prefix + $0 + suffix }.joinWithSeparator(separator)
    }
}

extension SequenceType where Generator.Element : CustomDebugStringConvertible
{
    public func debugDescription(separator: String, prefix: String, suffix: String = "") -> String
    {
        return map{ prefix + $0.debugDescription + suffix }.joinWithSeparator(separator)
    }
    
    //    @warn_unused_result
    //    func joinWithSeparator(separator: String, prefix: String, suffix: String) -> String
    //    {
    //        return map{ prefix + $0 + suffix }.joinWithSeparator(separator)
    //    }
}

extension SequenceType where Generator.Element: Comparable
{
    public func span() -> (Generator.Element, Generator.Element)?
    {
        if let mi = minElement(), let ma = maxElement()
        {
            return (mi, ma)
        }
        
        return nil
    }
}

extension SequenceType where Generator.Element: Hashable
{
    public func frequencies() -> [(element: Generator.Element, frequency: Int)]
    {
        var frequency =  Dictionary<Generator.Element,Int>()
        
        forEach { frequency[$0] = (frequency[$0] ?? 0) + 1 }
        
        return frequency.map{($0.0, $0.1)}.sort{ $0.1 > $1.1 }
    }
}

