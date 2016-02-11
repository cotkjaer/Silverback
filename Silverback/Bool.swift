//
//  Bool.swift
//  SilverbackFramework
//
//  Created by Christian Otkjær on 20/04/15.
//  Copyright (c) 2015 Christian Otkjær. All rights reserved.
//

import Foundation

/// Randomly returns **either** `this` or `that`
@warn_unused_result
public func either<T>(this: T, or that: T) -> T
{
    return Bool.random() ? this : that
}

/// Randomly returns one of the `T`s
@warn_unused_result
public func random<T>(t: T, _ ts: T...) -> T
{
    return (ts + [t]).random()!
}

/// Randomly executes **either** `this()` or `that()`
@warn_unused_result
public func either<T>(@noescape this: () throws -> T, @noescape or that: () throws -> T) rethrows -> T
{
    if Bool.random()
    {
        return try this()
    }
    else
    {
        return try that()
    }
}

public extension Bool
{
    public func toggled() -> Bool
    {
        return !self
    }
    
    public mutating func toggle() -> Bool
    {
        self = !self
        return self
    }
    
    public static func random() -> Bool
    {
        return UInt64.random() < UInt64.max / 2
    }

    /// Executes `this()` if self is **true**, `that()` if self is **false**
    /// - returns: The result of executing either closure-parameter
    public func onTrue<T>(@noescape this: () throws -> T, @noescape onFalse that: () throws -> T) rethrows -> T
    {
        return self ? try this() : try that()
    }

    /// Executes `this()` if self is **true**, `that()` if self is **false**
    public func onTrue<T>(@noescape this: () throws -> T) rethrows -> T?
    {
        return self ? try this() : nil
    }
}
