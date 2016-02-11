//
//  Set.swift
//  SilverbackFramework
//
//  Created by Christian Otkjær on 20/04/15.
//  Copyright (c) 2015 Christian Otkjær. All rights reserved.
//

import Foundation

public func + <T:Hashable>(lhs: Set<T>?, rhs: T) -> Set<T>
{
    return Set(rhs).union(lhs)
}

public func + <T:Hashable>(lhs: T, rhs: Set<T>?) -> Set<T>
{
    return rhs + lhs
}

public func - <T:Hashable, S : SequenceType where S.Generator.Element == T>(lhs: Set<T>, rhs: S?) -> Set<T>
{
    if let r = rhs
    {
        return lhs.subtract(r)
    }
    
    return lhs
}


public func - <T:Hashable>(lhs: Set<T>, rhs: T?) -> Set<T>
{
    return lhs - Set(rhs)
}


// MARK: - Optionals

public extension Set
{
    /**
     Initializes a set from the non-nil elements in `elements`
     
     - parameter elements: list of optional members for the set
     */
    init(_ elements: Element?...)
    {
        self.init(elements)
    }
    
    init(_ optionalMembers: [Element?])
    {
        self.init(optionalMembers.flatMap{ $0 })
    }
    
    init(_ optionalArray: [Element]?)
    {
        self.init(optionalArray ?? [])
    }
    
    init(_ optionalArrayOfOptionalMembers: [Element?]?)
    {
        self.init(optionalArrayOfOptionalMembers ?? [])
    }
    
    
    /**
     Picks a random member from the set
     
     - returns: A random member, or nil if set is empty
     */
    @warn_unused_result
    public func random() -> Element?
    {
        return Array(self).random()
    }
    
    @warn_unused_result
    func union<S : SequenceType where S.Generator.Element == Element>(sequence: S?) -> Set<Element>
    {
        if let s = sequence
        {
            return union(s)
        }
        
        return self
    }
    
    mutating func unionInPlace<S : SequenceType where S.Generator.Element == Element>(sequence: S?)
    {
        if let s = sequence
        {
            unionInPlace(s)
        }
    }
    
    /// Insert an optional element into the set
    /// - returns: **true** if the element was inserted, **false** otherwise
    @warn_unused_result
    mutating func insert(optionalElement: Element?) -> Bool
    {
        if let element = optionalElement
        {
            if !contains(element)
            {
                insert(element)
                return true
            }
        }
        
        return false
    }
    
    /// Return a `Set` contisting of the non-nil results of applying `transform` to each member of `self`
    @warn_unused_result
    func map<U:Hashable>(@noescape transform: Element -> U?) -> Set<U>
    {
        return Set<U>(flatMap(transform))
    }
    
    ///Remove all members in `self` that are accepted by the predicate
    mutating func remove(@noescape predicate: Element -> Bool)
    {
        subtractInPlace(filter(predicate))
    }
    
    /// Return a `Set` contisting of the members of `self`, that satisfy the predicate `includeMember`.
    @warn_unused_result
    func sift(@noescape includeMember: Element throws -> Bool) rethrows -> Set<Element>
    {
        return try Set(filter(includeMember))
    }
    
    /// Return a `Set` contisting of the members of `self`, that are `T`s
    @warn_unused_result
    func cast<T:Hashable>(type: T.Type) -> Set<T>
    {
        return map{ $0 as? T }
    }
    
    /// Returns **true** `optionalMember` is non-nil and contained in `self`, **flase** otherwise.
    @warn_unused_result
    func contains(optionalMember: Element?) -> Bool
    {
        return optionalMember?.containedIn(self) == true
    }
}

// MARK: - Subsets

public extension Set
{
    /// Returns **all** the subsets of this set. That might be quite a lot!
    @warn_unused_result
    func subsets() -> Set<Set<Element>>
    {
        var subsets = Set<Set<Element>>()
        
        if count > 1
        {
            if let element = first
            {
                subsets.insert(Set<Element>(element))
                
                let rest = self - element
                
                subsets.insert(rest)
                
                for set in rest.subsets()
                {
                    subsets.insert(set)
                    subsets.insert(set + element)
                }
            }
        }
        
        return subsets
    }
}




