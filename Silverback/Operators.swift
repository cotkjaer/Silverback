//
//  Operators.swift
//  SilverbackFramework
//
//  Created by Christian Otkjær on 18/06/15.
//  Copyright (c) 2015 Christian Otkjær. All rights reserved.
//

import Foundation

/// compares two optional Equatables and returns true if they are equal or one or both are nil
infix operator =?= { precedence 130 }

/// compares two optional Equatables and returns true if they are equal or one or both are nil
public func =?= <T:Equatable> (lhs: T?, rhs: T?) -> Bool
{
    if lhs == nil { return true }
    if rhs == nil { return true }
    return lhs == rhs
}

infix operator =!= { precedence 130 }

/// compares two optional Equatables and returns true if they are equal or both are nil
public func =!= <T:Equatable> (lhs: T?, rhs: T?) -> Bool
{
    if lhs == nil && rhs == nil { return true }
    if lhs == nil { return false }
    if rhs == nil { return false }
    return lhs! == rhs!
}

infix operator ** { associativity left precedence 160 }
public func ** (left: Double, right: Double) -> Double { return pow(left, right) }

infix operator **= { associativity right precedence 90 }
public func **= (inout left: Double, right: Double) { left = left ** right }


infix operator >?= { associativity right precedence 90 }
/// Assign right to left only if right > left
public func >?= <T:Comparable>(inout left: T, right: T) { if right > left { left = right } }

/// Assign right to left only if check(left,right) is true
public func conditionalAssign<T:Comparable>(inout left: T, right: T,@noescape check: ((T,T) -> Bool)) { if check(left,right) { left = right } }

infix operator ><= { associativity right precedence 90 }
/// Assign `right` to `left` only if `left` is not already equal to `right`
public func ><= <T:Equatable>(inout left: T, right: T)
{
    if left != right { left = right }
}

///Wrap try catch log in one go
public func tryCatchLog(call: (() throws ->()))
{
    do { try call() } catch let e as NSError { debugPrint(e) } catch { debugPrint("caught unknown error") }
}

public func box<T : Comparable>(n: T, mi: T, ma: T) -> T
{
    let realMin = min(mi, ma)
    let realMax = max(mi, ma)
    
    return min(realMax, max(realMin, n))
}

/// Matches operator, it may be declared for various entities that can be said to "match" in some way
infix operator ~~ { associativity left precedence 160 }

/// The inverse of the _matches operator_
infix operator !~ { associativity left precedence 160 }


///Protocol to describe dynamic equatable properties
public protocol OptionalEquatable
{
    func equals(thing: Any?) -> Bool
}

///Protocol to describe dynamically comparable entities - good for comparing objects in a hierarchy
public protocol OptionalComparable
{
    func lessThan(thing: Any?) -> Bool
}

@warn_unused_result
public func sum<T: IntegerArithmeticType where T:IntegerLiteralConvertible>(vs: T...) -> T
{
    return vs.reduce(0) { return $0 + $1 }
}

//MARK: - Sum

extension SequenceType where Generator.Element : IntegerArithmeticType, Generator.Element : IntegerLiteralConvertible
{
    func sum() -> Generator.Element
    {
        return reduce(0) { return $0 + $1 }
    }
}