//
//  ByteBuffer.swift
//  Silverback
//
//  Created by Christian Otkjær on 08/10/15.
//  Copyright © 2015 Christian Otkjær. All rights reserved.
//

typealias Byte = UInt8

enum BytesConvertibleError : ErrorType
{
    case InsufficientBytes(Int, Int)
    case MalformedBytes([Byte])
}

protocol ByteConvertible : ByteBufferable//, BytesConvertible
{
    init(byte: Byte)
    
    var byte: Byte { get }
}

//MARK: - Default implementation

extension ByteConvertible
{
    // MARK: - BytesConvertible
    
    init(bytes: [Byte]) throws {
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
    
    var bytes : [Byte] { return [byte] }
    
    // MARK: - ByteBufferable
    
    init(buffer: ByteBuffer) throws
    {
        self.init(byte: try buffer.read())
    }
    
    func write(buffer: ByteBuffer)
    {
        buffer.write(byte)
    }
}

protocol BytesConvertible
{
    var bytes: [Byte] { get }
    
    init(bytes: [Byte]) throws
}

protocol ByteBufferable
{
    init(buffer: ByteBuffer) throws
    
    func write(buffer: ByteBuffer)
}

class ByteBuffer
{
    private var buffer = Buffer<Byte>()
    
    // MARK: - Write
    
    func write(bytes:[Byte], optionalPrefixCount: Int? = nil)
    {
        if let count = optionalPrefixCount
        {
            let bytesCount = bytes.count
            
            let countBytes = Array(0..<count).reverse().map{ Byte(0xFF & (bytesCount >> ($0 * 8))) }
            
            buffer.write(countBytes)
        }
        
        buffer.write(bytes)
    }
    
    func write(byte: Byte)
    {
        buffer.write(byte)
    }
    
    func write<B:ByteBufferable>(bytable: B)
    {
        bytable.write(self)
    }
    
    func writeOptional<B:ByteBufferable>(optionalByteBufferable: B?)
    {
        write(optionalByteBufferable != nil)
        
        if let bytable = optionalByteBufferable
        {
            write(bytable)
        }
    }
    
    func write<S:SequenceType where S.Generator.Element : ByteBufferable>(bytables: S)
    {
        let array = Array(bytables)
        
        write(array.count)
        array.forEach{ write($0) }
    }
    
    // MARK: - Read
    
    func read(count: Int, dynamic : Bool = false) throws -> [Byte]
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
    
    func read<B:ByteBufferable>(type: B.Type) throws -> B
    {
        return try B(buffer: self)
    }
    
    func read() throws -> Byte
    {
        return try buffer.read()
    }
    
    func read<B:ByteBufferable>() throws -> B
    {
        return try B(buffer: self)
    }
    
    func readOptional<B:ByteBufferable>() throws -> B?
    {
        if try read() as Bool
        {
            return try read() as B
        }
        
        return nil
    }
    
    func read<B:ByteBufferable where B:Hashable>() throws -> Set<B>
    {
        return Set(try 0.stride(to: try read() as Int, by: 1).map{ _ in try read() as B })
    }
    
    func read<B:ByteBufferable>() throws -> [B]
    {
        return try 0.stride(to: try read() as Int, by: 1).map{ _ in try read() as B }
    }
    
    var available : Int { return buffer.available }
}

// MARK: - CustomDebugStringConvertible

extension ByteBuffer : CustomDebugStringConvertible
{
    var debugDescription : String {
        
        return "\(buffer.available) : " + buffer.elements.map{ String($0, radix: 16, uppercase: true, paddedToSize: 2) }.joinWithSeparator(" ")
    }
}
