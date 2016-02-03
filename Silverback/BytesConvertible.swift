//
//  BytesConvertible.swift
//  Silverback
//
//  Created by Christian Otkjær on 28/01/16.
//  Copyright © 2016 Christian Otkjær. All rights reserved.
//

import Foundation

//MARK: - Bytes Protocols

public protocol FromBytesConvertible
{
    typealias FromBytesConvertibleType
    
    static func fromBytes(bytes: [Byte], offset: Int) throws -> (Int, FromBytesConvertibleType)
}

public protocol ToBytesConvertible
{
    func toBytes() -> [Byte]
}

public protocol BytesConvertible : ToBytesConvertible, FromBytesConvertible, ByteBufferable {}

// MARK: - Default implem

extension BytesConvertible
{
    public func write(buffer: ByteBuffer)
    {
        buffer.write(toBytes())
    }
}

public protocol BytesInitializable : BytesConvertible
{
    init(bytes: [Byte]) throws
}

// MARK: - Default

extension BytesInitializable
{
    public static func read(buffer: ByteBuffer) throws -> Self
    {
        return try self.init(bytes: buffer.read(sizeof(Self)))
    }
}


public enum BytesConvertibleError : ErrorType
{
    case InsufficientBytes(Int, Int)
    case MalformedBytes([Byte])
}


public protocol ByteConvertible : BytesInitializable
{
    init(byte: Byte)
    
    var byte: Byte { get }
}

//MARK: - Default implementation

extension ByteConvertible
{
    // MARK: - FromBytesConvertible
    
    public init(bytes: [Byte]) throws
    {
        switch bytes.count
        {
        case 0:
            throw BytesConvertibleError.InsufficientBytes(1, 0)
        case 1:
            self.init(byte: bytes[0])
        default:
            throw BytesConvertibleError.MalformedBytes(bytes)
        }
    }
    
    // MARK: - ToBytesConvertible
    
    public func toBytes() -> [Byte]
    {
        return [byte]
    }
}
