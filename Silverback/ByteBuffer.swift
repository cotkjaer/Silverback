//
//  ByteBuffer.swift
//  Silverback
//
//  Created by Christian Otkjær on 08/10/15.
//  Copyright © 2015 Christian Otkjær. All rights reserved.
//

public protocol ByteBufferable
{
    static func read(buffer: ByteBuffer) throws -> Self
//    init(buffer: ByteBuffer) throws
    
    func write(buffer: ByteBuffer)
}

public class ByteBuffer
{
    private var buffer = Buffer<Byte>()
    
    // MARK: - Write
    
    public func write(bytes:[Byte], optionalPrefixCount: Int? = nil)
    {
        if let count = optionalPrefixCount
        {
            let bytesCount = bytes.count
            
            let countBytes = Array(0..<count).reverse().map{ Byte(0xFF & (bytesCount >> ($0 * 8))) }
            
            buffer.write(countBytes)
        }
        
        buffer.write(bytes)
    }
    
    public func write(byte: Byte)
    {
        buffer.write(byte)
    }
    
    public func write<B:ByteBufferable>(bufferable: B)
    {
        bufferable.write(self)
    }
    
    public func writeOptional<B:ByteBufferable>(optionalByteBufferable: B?)
    {
        write(optionalByteBufferable != nil)
        
        if let bufferable = optionalByteBufferable
        {
            write(bufferable)
        }
    }
    
    public func write<S:SequenceType where S.Generator.Element : ByteBufferable>(bufferables: S)
    {
        let array = Array(bufferables)
        
        write(array.count)
        array.forEach{ write($0) }
    }
    
//    // MARK: ToBytesConvertible
//
//    public func write<B:ToBytesConvertible>(bytesConvertible: B)
//    {
//        write(bytesConvertible.toBytes())
//    }
//    
//    public func writeOptional<B:ToBytesConvertible>(optionalBytesConvertible: B?)
//    {
//        write(optionalBytesConvertible != nil)
//        
//        if let bytes = optionalBytesConvertible?.toBytes()
//        {
//            write(bytes)
//        }
//    }
//    
//    public func write<S:SequenceType where S.Generator.Element : ToBytesConvertible>(bytesConvertibles: S)
//    {
//        let array = Array(bytesConvertibles)
//        
//        write(array.count)
//        array.forEach{ write($0) }
//    }
    
//    // MARK: - Functions
//    
//    public func write(function: (()->[Byte]))
//    {
//        write(function())
//    }

//    
//    public func writeOptional(string: String?)
//    {
//        write(string != nil)
//        
//        if let bytes = string?.toBytes()
//        {
//            write(bytes)
//        }
//    }

    // MARK: - Read
    
    public func read(count: Int, dynamic : Bool = false) throws -> [Byte]
    {
        if dynamic
        {
            let bytesToRead = try Int(bytes: try buffer.peek(count))
            
            if count + bytesToRead > buffer.available { throw BytesConvertibleError.InsufficientBytes(count + bytesToRead, buffer.available) }
            
            try buffer.skip(count)
            
            return try buffer.read(bytesToRead)
        }
        
        return try buffer.read(count)
    }
    
    public func read<B:ByteBufferable>(type: B.Type) throws -> B
    {
        return try B.read(self) //B(buffer: self)
    }
    
    public func read() throws -> Byte
    {
        return try buffer.read()
    }

    // MARK: - ByteBufferable
    
    public func read<B:ByteBufferable>() throws -> B
    {
        return try B.read(self) //B(buffer: self)
    }
    
    public func readOptional<B:ByteBufferable>() throws -> B?
    {
        if try read() as Bool
        {
            return try read() as B
        }
        
        return nil
    }
    
    public func read<B:ByteBufferable where B:Hashable>() throws -> Set<B>
    {
        return Set(try 0.stride(to: try read() as Int, by: 1).map{ _ in try read() as B })
    }
    
    public func read<B:ByteBufferable>() throws -> [B]
    {
        return try 0.stride(to: try read() as Int, by: 1).map{ _ in try read() as B }
    }

    // MARK: - Available
    
    public var available : Int { return buffer.available }
}

// MARK: - CustomDebugStringConvertible

extension ByteBuffer : CustomDebugStringConvertible
{
    public var debugDescription : String {
        
        return "\(buffer.available) : " + buffer.elements.map{ String($0, radix: 16, uppercase: true, paddedToSize: 2) }.joinWithSeparator(" ")
    }
}
