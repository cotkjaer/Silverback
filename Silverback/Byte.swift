//
//  Byte.swift
//  Silverback
//
//  Created by Christian Otkjær on 05/12/15.
//  Copyright © 2015 Christian Otkjær. All rights reserved.
//

import Foundation

public typealias Byte = UInt8
public typealias Bytes = [Byte]

extension Byte : BytesConvertible
{
    // MARK: - ByteBufferable
    
    public static func read(buffer: ByteBuffer) throws -> Byte
    {
        return try buffer.read()
    }
    
    public func toBytes() -> [Byte] { return [self] }
    
    public static func fromBytes(bytes: [Byte], offset: Int) throws -> (Int, Byte)
    {
        if let byte = bytes.get(offset)
        {
            return (offset+1, byte)
        }
        
        throw BytesConvertibleError.InsufficientBytes(1, offset)
    }
}
