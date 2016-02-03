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

// MARK: - ByteConvertible

extension Bool : ByteConvertible//, ByteBufferable
{
//    public func write(buffer: ByteBuffer)
//    {
//        let byte = self ? Byte.max : Byte.zero
//        
//        byte.write(buffer)
//    }
//    
//    public init(buffer: ByteBuffer) throws
//    {
//        let byte = try buffer.read()
//        
//        self = byte != Byte.zero// ? false : true
//    }
//
//    public func toBytes() -> [Byte]
//    {
//        return [byte]
//    }
    
    public var byte : Byte { return self ? Byte.max : Byte.zero }

    public init(byte: Byte)
    {
        self = byte != Byte.zero
    }
    
    public typealias FromBytesConvertibleType = Bool
    
    public static func fromBytes(bytes: [Byte], offset: Int) throws -> (Int, Bool)
    {
        guard let byte = bytes.get(offset) else { throw BytesConvertibleError.InsufficientBytes(1, offset) }
        
        return (offset + 1, Bool(byte: byte))
    }

    public static func read(buffer: ByteBuffer) throws -> Bool
    {
        return Bool(byte:try buffer.read())
    }
}

