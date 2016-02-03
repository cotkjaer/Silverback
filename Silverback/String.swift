//
//  String.swift
//  SilverbackFramework
//
//  Created by Christian Otkjær on 20/04/15.
//  Copyright (c) 2015 Christian Otkjær. All rights reserved.
//

import Foundation
import UIKit

//MARK: - Lorem Ipsum

extension String
{
    public init(loremIpsumLength: Int)
    {
        self = "Lorem ipsum dolor sit amet donec ut eros sapien. Tortor risus mauris. Viverra donec augue. Tortor rutrum vestibulum donec in dui. Ac consectetuer aliquet est rhoncus rutrum tellus risus curae consequat ut vestibulum sapien risus elit. Tortor eu donec. Morbi urna non ac imperdiet quisque. Etiam viverra lacinia. Faucibus in placerat. Mauris integer at a erat tempor. Aliquet sed id blandit cursus at vero sit amet venenatis mauris elit in interdum id. Auctor ullamcorper enim nulla curabitur quisque nunc quisque ac. Elit justo auctor. Vulputate scelerisque erat quis elit accumsan. Ac ipsum id. Lorem dolor tristique. Porttitor accumsan velit dui justo enim. Sapien maecenas sed. Proin ac nulla sem nisl nec sit fermentum justo at neque volutpat. Pulvinar tincidunt turpis. Ac nam venenatis. Tristique nulla sollicitudin adipiscing neque posuere vestibulum vitae purus. Mi viverra urna arcu purus metus. Ut neque praesent. Lectus morbi integer eros dignissim nec pharetra pulvinar quis."
    }
}

//MARK: - replace

extension String
{
    public mutating func replace(target: String, with optionalReplacement: String?)
    {
        self = self.with(target, replacedBy: optionalReplacement)
    }
    
    @warn_unused_result
    public func with(target: String, replacedBy optionalReplacement: String?) -> String
    {
        if let replacement = optionalReplacement
        {
            return self.stringByReplacingOccurrencesOfString(target, withString: replacement)
        }
        
        return self
    }
}

public extension String
{
    init<T : UnsignedIntegerType>(_ v: T, radix: Int, uppercase: Bool = false, paddedToSize: Int)
    {
        self.init(v, radix: radix, uppercase: uppercase)
        
        let padSize = paddedToSize - self.characters.count
        
        if padSize > 0
        {
            self = String(Array<Character>(count: padSize, repeatedValue: "0")) + self
        }
    }
}


public func trim(string: String) -> String
{
    return string.trimmed
}

public extension String
{
    public var trimmed : String
        {
            return stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
    }
    
    public func stringByTrimmingTail(forCharactersInSet: NSCharacterSet = NSCharacterSet.whitespaceAndNewlineCharacterSet()) -> String
        {
            let characterSet = NSCharacterSet.whitespaceAndNewlineCharacterSet()
            
            var characters = self.characters
            
            while characterSet.containsCharacter(characters.last)
            {
                characters.removeLast()
            }
            
            return String(characters)
    }
}

public extension String
{
    public var uppercaseFirstLetter: String?
        {
        get
        { if !isEmpty
        { return self[0].uppercaseString }; return nil }
    }
}

/// Subscript
public extension String
{
    public subscript (i: Int) -> Character
        {
            return self[self.startIndex.advancedBy(i)]
    }
    
    public subscript (i: Int) -> String
        {
            return String(self[i] as Character)
    }
    
    public subscript (r: Range<Int>) -> String
        {
            let startIndex = self.startIndex.advancedBy(r.startIndex)
            let endIndex = startIndex.advancedBy(r.endIndex - r.startIndex)
            
            return self[Range(start: startIndex, end: endIndex)]
            
            //        return substringWithRange(Range(start: advance(startIndex, r.startIndex), end: advance(startIndex, r.endIndex)))
    }
}


public extension String
{
    public var reversed : String { return String(Array(self.characters.reverse())) }
}

public extension String
{
    public func sizeWithFont(font: UIFont) -> CGSize
    {
        let size: CGSize = self.sizeWithAttributes([NSFontAttributeName: font])
        
        return size
    }
}

public extension String
{
    public func beginsWith (str: String) -> Bool
    {
        if str.isEmpty
        {
            return true
        }
        
        if let range = rangeOfString(str)
        {
            return range.startIndex == self.startIndex
        }
        
        return false
    }
    
    public func endsWith (str: String) -> Bool
    {
        return reversed.beginsWith(str.reversed)
    }
}

// MARK: - BytesConvertible

extension String : BytesConvertible
{
    public func toBytes() -> [Byte]
    {
        let bytes = Array<Byte>(utf8)
        
        let length = bytes.count
        
        if length <= Int(Byte.max)
        {
            return [Byte(1), Byte(length)] + bytes
        }
        else if length <= Int(UInt16.max)
        {
            return [Byte(2)] + UInt16(length).toBytes() + bytes
        }
        else if UInt(bitPattern: length) <= UInt(UInt32.max)
        {
            return [Byte(4)] + UInt32(length).toBytes() + bytes
        }
        else
        {
            return [Byte(8)] + UInt64(length).toBytes() + bytes
        }
    }
    
    public static func fromBytes(bytes: [Byte], offset: Int) throws -> (Int, String)
    {
        var (off, bytesContainingLength) = try Byte.fromBytes(bytes, offset: offset)
        
        var stringLength  = 0
        
        switch bytesContainingLength
        {
        case 1:
            let (o, byteContainingStringLength) = try Byte.fromBytes(bytes, offset: off)
            stringLength = Int(byteContainingStringLength)
            off = o
            
        case 2:
            let (o, uint16ContainingStringLength) = try UInt16.fromBytes(bytes, offset: off)
            stringLength = Int(uint16ContainingStringLength)
            off = o
            
        case 4:
            let (o, uint32ContainingStringLength) = try UInt32.fromBytes(bytes, offset: off)
            stringLength = Int(uint32ContainingStringLength)
            off = o
            
        case 8:
            let (o, uint64ContainingStringLength) = try UInt64.fromBytes(bytes, offset: off)
            stringLength = Int(uint64ContainingStringLength)
            off = o
        
        default:
            throw BytesConvertibleError.MalformedBytes([bytes[offset]])
        }

        guard off + stringLength < bytes.count else { throw BytesConvertibleError.InsufficientBytes(off, stringLength) }
        
        let stringUtf8Bytes = Array(bytes[off..<off+stringLength])
        
        if let string = String(bytes: stringUtf8Bytes, encoding: NSUTF8StringEncoding)
        {
            return (off + stringLength, string)
        }
        else
        {
            throw BytesConvertibleError.MalformedBytes(stringUtf8Bytes)
        }
    }
    
    
    public init(bytes: [Byte]) throws
    {
        if let string = String(bytes: bytes, encoding: NSUTF8StringEncoding)
        {
            self.init(string)
        }
        else
        {
            throw BytesConvertibleError.MalformedBytes(bytes)
        }
    }
}

// MARK: - ByteBufferable

extension String : ByteBufferable
{
    public init(buffer: ByteBuffer) throws
    {
        let bytes = try buffer.read(2, dynamic: true)
        
        try self.init(bytes:bytes)
    }
    
    public static func read(buffer: ByteBuffer) throws -> String
    {
        return try String(buffer: buffer)
    }
    
    public func write(buffer: ByteBuffer)
    {
        let bytes = Array<Byte>(utf8)

        buffer.write(bytes, optionalPrefixCount: 2)
    }
}