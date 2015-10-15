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
func either<T>(this: T, or that: T) -> T
{
    return Bool.random() ? this : that
}

/// Randomly returns one of the `T`s
@warn_unused_result
func random<T>(t: T, _ ts: T...) -> T
{
    return (ts + [t]).random()!
}

/// Randomly executes **either** `this()` or `that()`
@warn_unused_result
func either<T>(@noescape this: () throws -> T, @noescape or that: () throws -> T) rethrows -> T
{
    return try Bool.random() ? this() : that()
}

public extension Bool
{
    func toggled() -> Bool
    {
        return !self
    }
    
    mutating func toggle() -> Bool
    {
        self = !self
        return self
    }
    
    static func random() -> Bool
    {
        return UInt64.random() < UInt64.max / 2
    }

    /// Executes `this()` if self is **true**, `that()` if self is **false**
    /// - returns: The result of executing either closure-parameter
    func onTrue<T>(@noescape this: () throws -> T, @noescape onFalse that: () throws -> T) rethrows -> T
    {
        return self ? try this() : try that()
    }

    /// Executes `this()` if self is **true**, `that()` if self is **false**
    func onTrue<T>(@noescape this: () throws -> T) rethrows -> T?
    {
        return self ? try this() : nil
    }
    
}

// MARK: - ByteConvertible

extension Bool : ByteConvertible
{
    var byte : Byte { return self ? Byte.max : Byte.zero }
    
    init(byte: Byte)
    {
        self = byte == Byte.zero ? false : true
    }
}

