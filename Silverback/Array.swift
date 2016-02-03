//
//  Array.swift
//  SilverbackFramework
//
//  Created by Christian Otkjær on 05/05/15.
//  Copyright (c) 2015 Christian Otkjær. All rights reserved.
//

import Foundation

//MARK: - Functional Inits

extension Array
{
    /// Init with elements produced by calling `block`, `count`times.
    init(count: Int, @noescape block: (Int) -> Element)
    {
        self.init()
        
        for i in 0..<count
        {
            append(block(i))
        }
    }
    
    /// Init with elements produced by `block`. 
    /// -warning: Calls `block` until it returns nil
    init(@noescape block: () -> Element?)
    {
        self.init()
        
        while let e = block()
        {
            append(e)
        }
    }
}


// MARK: - Safe versions of standard array operations
public extension Array
{
    @warn_unused_result func map<U>(transform: Element -> U?) -> Array<U>
    {
        return flatMap(transform)
    }
    
    /**
    Gets the element at the specified optional index, if it exists and is within the arrays bounds.
    
    - parameter optionaleIndex: the optional index to look up
    - returns: the element at the index in self
    */
    public func get(optionaleIndex: Int?) -> Element?
    {
        if let index = optionaleIndex
        {
            if index < count && index >= 0
            {
                return self[index]
            }
        }
        
        return nil
    }
}

// MARK: - Optional versions of standard methods

public extension Array where Element : Equatable
{
    ///Returns the first index where `optionalElement` appears in `self` or `nil` if `optionalElement` is not found.
    public func indexOf(optionalElement: Element?) -> Index?
    {
        return indexOf{ $0 == optionalElement }
    }
    
    ///Returns the first element that is equal to `optionalElement` or `nil` if `optionalElement` is not found.
    @warn_unused_result
    func find(optionalElement: Element?) -> Element?
    {
        return find{ $0 == optionalElement }
    }
}

// MARK: - List operations
public extension Array
{
    /// appends an optional element to the array
    /// - returns: `element` if the element was appended, `nil` otherwise
    @warn_unused_result
    mutating func append(optionalElement: Element?) -> Element?
    {
        if let element = optionalElement
        {
            append(element)
            return element
        }
        
        return nil
    }

    var tail : Array<Element>?
        {
            switch count
            {
            case 0, 1: return nil
                
            case 2: return [self[1]]
                
            default: return Array(self[1..<count])
            }
    }
    
    var head : Element? { return first }
}

//// MARK: - Set-like operations
//public func intersect<E: Equatable>(arrays: [E]...) -> [E]
//{
//    switch arrays.count
//    {
//    case 0:
//        return []
//        
//    case 1:
//        return arrays[0]
//        
//    case 2:
//        
//        return arrays[0].filter({ arrays[1].indexOf($0) != nil })
//        
//    default:
//        
//        return arrays.reduce(arrays[0], combine: { (intersection, array) -> [E] in
//            intersection.filter({ array.indexOf($0) != nil })
//        })
//    }
//}

public extension Array
{
    /**
    Creates a dictionary with an optional entry for every element in the array.
    
    - Note: Different calls to *transform* may yield the same *result-key*, the later call overwrites the value in the dictionary with its own *result-value*
    
    - Parameter transform: closure to apply to the elements in the array
    - Returns: the dictionary compiled from the results of calling *transform* on each element in array
    */
    func mapToDictionary<K:Hashable, V>(@noescape transform: (Element) -> (K, V)?) -> Dictionary<K, V>
    {
        return reduce([:]) {
            (var dictionary, element) in
            if let (key, value) = transform(element)
            {
                dictionary[key] = value
            }
            return dictionary
        }
    }
    
    /**
    Creates a set with an optional entry for every element in the array. Calls _transform_ in the same sequence as a *for-in loop* would. The returned non-nil results are accumulated to the resulting set
    
    - Parameter transform: closure to apply to elements in the array
    - Returns: the set compiled from the results of calling *transform* on each element in array
    */
    func mapToSet<E:Hashable>(@noescape transform: (Element -> E?)) -> Set<E>
    {
        return reduce(Set<E>()) {
            (var set, element) in
            if let setElement = transform(element)
            {
                set.insert(setElement)
            }
            return set
        }
    }
    
    /**
    Finds the first element which meets the condition.
    
    - parameter condition: A closure which takes an Element and returns a Bool
    - returns: First element to match contidion or nil, if none matched
    */
    @warn_unused_result
    func find(@noescape condition: Element throws -> Bool) rethrows -> Element?
    {
        for element in self
        {
            if try condition(element) { return element }
        }
        return nil
    }
    
    /**
    Finds and returns the first element of the specified type (cast as that type).
    
    - parameter type: A type to look for
    - returns: First element to match the type or nil, if none did
    */
    @warn_unused_result
    func find<T>(type: T.Type) -> T?
    {
        return find({$0 is T}) as? T
    }
    
    /**
    Randomly rearranges (shuffles) the elements of self using the [Fisher-Yates shuffle](https://en.wikipedia.org/wiki/Fisher–Yates_shuffle)
    */
    mutating func shuffle()
    {
        if count > 1
        {
            for var i = count - 1; i >= 1; i--
            {
                let j = Int.random(lower: 0, upper: i+1)
                
                if j != i
                {
                    swap(&self[i], &self[j])
                }
            }
        }
    }
    
    /**
    Shuffles the values of the array into a new one
    
    - returns: Shuffled copy of self
    */
    func shuffled() -> Array
    {
        var shuffled = self
        
        shuffled.shuffle()
        
        return shuffled
    }
    
    /**
    Picks a random element from the array
    
    - returns: random element from the array or nil if the array is empty
    */
    func random() -> Element?
    {
        switch count
        {
        case 0:
            return nil
        case 1:
            return first
        default:
            return self[Int.random(lower: 0, upper: count-1)]
        }
    }
    
    /**
    Iterates on each element of the array.
    
    - parameter closure: Function to call for each index x element, setting the stop parameter to true will stop the iteration
    */
    public func iterate(closure: ((index: Int, element: Element, inout stop: Bool) -> ()))
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
    public func iterate(closure: ((element: Element, inout stop: Bool) -> ()))
    {
        var stop : Bool = false
        
        for element in self
        {
            closure(element: element, stop: &stop)
            
            if stop { break }
        }
    }
    
    /**
    Checks if test returns true for any element of self.
    
    - parameter test: Function to call for each element
    - returns: true if test returns true for any element of self
    */
    func any(@noescape test: (Element) -> Bool) -> Bool
    {
        return find(test) != nil
    }
    
    /**
    Checks if test returns true for all the elements in self
    
    - parameter test: Function to call for each element
    - returns: True if test returns true for all the elements in self
    */
    func all(test: (Element) -> Bool) -> Bool
    {
        for item in self
        {
            if !test(item)
            {
                return false
            }
        }
        
        return true
    }
    
    /**
    Opposite of filter.
    
    - parameter exclude: Function invoked to test elements for the exclusion from the array
    - returns: self filtered 
    */
    func reject(exclude: (Element -> Bool)) -> Array
    {
        return filter { return !exclude($0) }
    }
    
    /// Removes the first element to match `predicate` from the array and returns the found element
    mutating func take(@noescape predicate: (Element throws -> Bool) = { $0 != nil }) rethrows -> Element?
    {
        if let index = try indexOf(predicate)
        {
            let element = self[index]
            
            removeAtIndex(index)
            
            return element
        }
        
        return nil
    }
    
    
    /**
    Returns an array containing the first n elements of self.
    
    - parameter n: Number of elements to take
    - returns: First n elements
    */
    func take(n: Int) -> Array
    {
        return Array(self[0..<Swift.max(0, n)])
    }
    
    /**
    Returns the elements of the array up until an element does not meet the condition.
    
    - parameter condition: A function which returns a boolean if an element satisfies a given condition or not.
    - returns: Elements of the array up until an element does not meet the condition
    */
    func takeWhile (condition: (Element) -> Bool) -> Array
    {
        var lastTrue = -1
        
        for (index, value) in self.enumerate()
        {
            if condition(value)
            {
                lastTrue = index
            }
            else
            {
                break
            }
        }
        
        return take(lastTrue + 1)
        
    }
    
    /**
    Constructs an array removing the duplicate values in self if Array.Element implements the Equatable protocol.
    
    - returns: Array of unique values
    */
    func unique<T: Equatable>() -> [T]
    {
        var result = [T]()
        
        for item in self
        {
            if !result.contains(item as! T)
            {
                result.append(item as! T)
            }
        }
        
        return result
    }
    
    /**
    Returns an Array of elements for which call(element) is unique
    
    - parameter call: The closure to use to determine uniqueness
    - returns: The set of elements for which call(element) is unique
    */
    func uniqueBy <T: Equatable> (call: (Element) -> (T)) -> [Element]
    {
        var result: [Element] = []
        var uniqueItems: [T] = []
        
        for item in self
        {
            let callResult: T = call(item)
            if !uniqueItems.contains(callResult)
            {
                uniqueItems.append(callResult)
                result.append(item)
            }
        }
        
        return result
    }
    
    /**
    Returns the number of elements which meet the condition
    
    - parameter test: Function to call for each element
    - returns: the number of elements meeting the condition
    */
    func countWhere (test: (Element) -> Bool) -> Int
    {
        var result = 0
        
        for item in self
        {
            if test(item)
            {
                result++
            }
        }
        
        return result
    }
        
    /// Return an `Array` contisting of the members of `self`, that are `T`s
    @warn_unused_result
    func cast<T>(type: T.Type) -> Array<T>
    {
        return map{ $0 as? T }
    }
    
    /**
    Creates an array with the elements at the specified indexes.
    
    - parameter indexes: Indexes of the elements to get
    - returns: Array with the elements at indexes
    */
    func at(indexes: Int...) -> [Element]
    {
        return indexes.flatMap { get($0) }
    }
    
    /**
    Generates an array with all elements up till predicate evaluates true
    
    - parameter include: if **true** the element that makes the predicate ture is included as the last element in the generated array
    - parameter predicate:
    
    - returns: subarray
    */
    func upTill(include include: Bool = true, @noescape _ predicate: (Element -> Bool)) -> Array<Element>
    {
        if let index = indexOf(predicate)
        {
            if include
            {
                return Array(self[0...index])
            }
            else if index > 0
            {
                return Array(self[0..<index])
            }
            else
            {
                return[]
            }
        }
        
        return self
    }
    
    /**
    Generates an array with all elements up till predicate evaluates to a given target
    
    - parameter include: if **true** the element that makes the predicate hit the target is included as the last element in the generated array, default **true**
    - parameter target: the target value for the predicate, default **true**
    - parameter predicate:
    
    - returns: subarray
    */
    @warn_unused_result func stopFilter(include include: Bool = true, target: Bool = true, @noescape _ predicate: Element -> Bool) -> Array<Element>
    {
        if let index = indexOf({ predicate($0) == target })
        {
            if include
            {
                return Array(self[0...index])
            }
            else if index > 0
            {
                return Array(self[0..<index])
            }
            else
            {
                return[]
            }
        }
        
        return self
    }
    
    /**
    Calls the passed block for each element in the array, either n times or infinitely, if n isn't specified
    
    - parameter n: the number of times to cycle through
    - parameter block: the block to run for each element in each cycle
    */
    func cycle(n: Int? = nil, block: (Element) -> ())
    {
        var cyclesRun = 0
        while true
        {
            if let n = n
            {
                if cyclesRun >= n
                {
                    break
                }
            }
            for item in self
            {
                block(item)
            }
            cyclesRun++
        }
    }
    

    /**
     Runs a binary search to find the **last** element for which the predicate evaluates to `true`.
     
     The predicate should return `true` for all elements in the array below a certain index and `false` for all elements above that index
     
     - parameter predicate: the predicate to test elements
     - returns: The found index and element, or `nil` if there are no elements in the array for which the predicate returns `true`
     */
    @warn_unused_result
    public func lastWhere(@noescape predicate: Element -> Bool) -> (Int, Element)?
    {
        guard count > 0 else { return nil }
        
        var low = 0
        var high = count - 1
        
        while low <= high
        {
            let mid = (high + low) / 2
            
            if predicate(self[mid])
            {
                if mid == high || !predicate(self[mid + 1])
                {
                    return (mid, self[mid])
                }
                else
                {
                    low = mid + 1
                }
            }
            else
            {
                high = mid - 1
            }
        }
        
        return nil
    }

    
    /**
     Runs a binary search to find the first element for which the predicate evaluates to **true**
     The predicate should return **false** for all elements in the array below a certain index and **true** for all elements above that index
     If that index is beyond the last index in the array, nil is returned
     
     - parameter predicate: the predicate to test elements
     - returns: the first index and element at that index, or nil if there are no elements for which the predicate returns true
     */
    @warn_unused_result
    public func firstWhere(@noescape predicate: Element -> Bool) -> (Int, Element)?
    {
        if count == 0
        {
            return nil
        }
        
        var low = 0
        var high = count - 1
        while low <= high
        {
            let mid = low + (high - low) / 2
            
            if predicate(self[mid])
            {
                if mid == 0 || !predicate(self[mid - 1])
                {
                    return (mid, self[mid])
                }
                else
                {
                    high = mid
                }
            }
            else
            {
                low = mid + 1
            }
        }
        
        return nil
    }
    
    /**
    Runs a binary search to find the smallest element for which the predicate evaluates to true
    The predicate should return true for all elements in the array above a certain index and false for all elements below a certain index
    If that index is beyond the last index in the array, it returns nil
    
    - parameter predicate: the predicate to test each element
    - returns: the min index and element at that index, or nil if there are no elements for which the predicate returns true
    */
    public func bSearch(predicate: Element -> Bool) -> (Int, Element)?
    {
        if count == 0
        {
            return nil
        }
        
        var low = 0
        var high = count - 1
        while low <= high
        {
            let mid = low + (high - low) / 2
            
            if predicate(self[mid])
            {
                if mid == 0 || !predicate(self[mid - 1])
                {
                    return (mid, self[mid])
                }
                else
                {
                    high = mid
                }
            }
            else
            {
                low = mid + 1
            }
        }
        
        return nil
    }
    
    /**
    Runs a binary search to find some element for which the block returns 0.
    The block should return a negative number if the current value is before the target in the array, 0 if it's the target, and a positive number if it's after the target
    The Spaceship operator is a perfect fit for this operation, e.g. if you want to find the object with a specific date and name property, you could keep the array sorted by date first, then name, and use this call:
    let match = bSearch
    {
    [targetDate, targetName] <=> [$0.date, $0.name] }
    
    See http://ruby-doc.org/core-2.2.0/Array.html#method-i-bsearch regarding find-any mode for more
    
    - parameter block: the block to run each time
    - returns: an item (there could be multiple matches) for which the block returns true
    */
    func bSearch (block: (Element) -> (Int)) -> Element?
    {
        let match = bSearch
            {
                item in
                block(item) >= 0
        }
        if let (_, element) = match
        {
            return block(element) == 0 ? element : nil
        }
        else
        {
            return nil
        }
    }
    
    /**
    Sorts the array by the value returned from the block, in ascending order
    
    - parameter block: the block to use to sort by
    - returns: an array sorted by that block, in ascending order
    */
    func sortUsing <U:Comparable> (block: ((Element) -> U)) -> [Element]
    {
        return self.sort({ block($0.0) < block($0.1) })
    }
    
    /**
    Prepends an element to the front of the array.
    
    - parameter newElement: Element to prepend
    */
    public mutating func prepend(newElement: Element)
    {
        insert(newElement, atIndex: 0)
    }
}




// MARK: List , Queue and Stack operations
public extension Array {
    /**
    Treats the array as a Stack; removing the last element of the array and returning it.
    
    - returns: The removed element, or nil if the array is empty
    */
    mutating func pop() -> Element?
    {
        if isEmpty { return nil }
        
        return removeLast()
    }
    
    /**
    Treats the array as a Stack or Queue; appending the list of elements to the end of the array.
    
    - parameter elements: The elements to append
    */
    mutating func push(elements: Element...)
    {
        switch elements.count
        {
        case 0: return
            
        case 1: self.append(elements[0])
            
        default: self += elements
        }
    }
    
    /**
    Treats the array as a Queue; removing the first element in the array and returning it.
    
    - returns: The removed element, or nil if the array is empty
    */
    mutating func shift() -> Element?
    {
        if isEmpty { return nil }
        
        return removeAtIndex(0)
    }
    
    /**
    Prepends a list of elements to the front of the array. The elements are prepended as a list, **not** one at a time. Thus the order in the list is preserved in the array
    
    - parameter elements: The elements to prepend
    */
    mutating func unshift(elements: Element...)
    {
        switch elements.count
        {
        case 0: return
            
        case 1: self.insert(elements[0], atIndex: 0)
            
        default: self = elements + self
        }
    }
}

// MARK: - Changes

public extension Array where Element : Equatable
{
    func missingIndicies(otherArray: Array<Element>) -> [Index]
    {
        return enumerate().filter{!otherArray.contains($0.element)}.map{$0.index}
    }
}

//MARK: - Last Index

extension Array
{
    public var lastIndex : Index? { return isEmpty ?  nil : count - 1 }
}

/**
Add a optional array
*/
infix operator ?+ { associativity left precedence 130 }

public func ?+ <T> (first: [T], optionalSecond: [T]?) -> [T]
{
    if let second = optionalSecond
    {
        return first + second
    }
    else
    {
        return first
    }
}

infix operator ?+= { associativity right precedence 90 }

public func ?+= <T> (inout left: [T], optionalRight: [T]?)
{
    if let right = optionalRight
    {
        left += right
    }
}

/**
Remove an element from the array
*/
public func - <T: Equatable> (first: [T], second: T) -> [T]
{
    return first - [second]
}

/**
Difference operator
*/
public func - <T: Equatable> (first: [T], second: [T]) -> [T]
{
    return first.filter { !second.contains($0) }
}

/**
Intersection operator
*/
public func & <T: Equatable> (first: [T], second: [T]) -> [T]
{
    return first.filter { second.contains($0) }
}

/**
Union operator
*/
public func | <T: Equatable> (first: [T], second: [T]) -> [T]
{
    return first + (second - first)
}