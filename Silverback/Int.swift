//
//  Int.swift
//  SilverbackFramework
//
//  Created by Christian Otkjær on 20/04/15.
//  Copyright (c) 2015 Christian Otkjær. All rights reserved.
//

import Foundation

public extension Int
{
    /**
    Calls function self times.
    
    - parameter function: Function to call
    */
    func times <T> (function: () -> T) -> Array<T>
    {
        return Array(0..<self).map { _ in return function() }
    }
    
    /**
    Calls function self times.
    
    - parameter function: Function to call
    */
    func times (function: () -> ())
    {
        for _ in (0..<self)
        {
            function()
        }
    }
    
    /**
    Calls function self times passing a value from 0 to self on each call.
    
    - parameter function: Function to call
    */
    func times <T> (function: (Int) -> T) -> Array<T>
    {
        return Array(0..<self).map { function($0) }
    }
    
    /**
    Checks if a number is even.
    
    - returns: **true** if self is even
    */
    var even: Bool
        {
            return (self % 2) == 0
    }
    
    /**
    Checks if a number is odd.
    
    - returns: true if self is odd
    */
    var odd: Bool
        {
            return !even
    }
    
    /**
    Iterates function, passing in integer values from self up to and including limit.
    
    - parameter limit: Last value to pass
    - parameter function: Function to invoke
    */
    func upTo(limit: Int, @noescape function: (Int) -> ())
    {
        self.stride(to: limit, by: 1).forEach { function($0) }
    }
    
    /**
    Iterates function, passing in integer values from self down to and including limit.
    
    - parameter limit: Last value to pass
    - parameter function: Function to invoke
    */
    func downTo(limit: Int, function: (Int) -> ())
    {
        if limit > self
        {
            return
        }
        
        for index in Array(Array(limit...self).reverse())
        {
            function(index)
        }
    }
    
    /**
    Clamps self to a specified range.
    
    - parameter range: Clamping range
    - returns: Clamped value
    */
    func clamp(range: Range<Int>) -> Int
    {
        return clamp(range.startIndex, range.endIndex - 1)
    }
    
    /**
    Clamps self to a specified range.
    
    - parameter lower: Lower bound (included)
    - parameter upper: Upper bound (included)
    - returns: Clamped value
    */
    func clamp(lower: Int, _ upper: Int) -> Int
    {
        return Swift.max(lower, Swift.min(upper, self))
    }
    
    /**
    Checks if self is included a specified range.
    
    - parameter range: Range
    - parameter string: If true, "<" is used for comparison
    - returns: true if in range
    */
    func isIn(range: Range<Int>, strict: Bool = false) -> Bool
    {
        if strict
        {
            return range.startIndex < self && self < range.endIndex - 1
        }
        
        return range.startIndex <= self && self <= range.endIndex - 1
    }
    
    /**
    Checks if self is included in a closed interval.
    
    - parameter interval: Interval to check
    - returns: true if in the interval
    */
    func isIn(interval: ClosedInterval<Int>) -> Bool
    {
        return interval.contains(self)
    }
    
    /**
    Checks if self is included in an half open interval.
    
    - parameter interval: Interval to check
    - returns: true if in the interval
    */
    func isIn(interval: HalfOpenInterval<Int>) -> Bool
    {
        return interval.contains(self)
    }
    
    /**
    Returns an [Int] containing the digits in self.
    
    :return: Array of digits
    */
    var digits: [Int]
        {
            var result = [Int]()
            
            for char in String(self).characters
            {
                let string = String(char)
                if let toInt = Int(string)
                {
                    result.append(toInt)
                }
            }
            
            return result
    }
    
    /**
    Absolute value.
    
    - returns: abs(self)
    */
    var abs: Int
        {
            return Swift.abs(self)
    }
    
    /**
    Calculates greatest common divisor (GCD) of self and n.
    
    - parameter n:
    - returns: Greatest common divisor
    */
    func gcd(n: Int) -> Int
    {
        return n == 0 ? self : n.gcd(self % n)
    }
    
    /**
    Calculates least common multiple (LCM) of self and n
    
    - parameter n:
    - returns: Least common multiple
    */
    func lcm(n: Int) -> Int
    {
        return (self * n).abs / gcd(n)
    }
    
    /**
    Computes the factorial of self
    
    - returns: Factorial
    */
    var factorial: Int
        {
            return self == 0 ? 1 : self * (self - 1).factorial
    }
    
}

public extension Int
{
    public func format(format: String? = "") -> String
    {
        return String(format: "%\(format)d", self)
    }
}

// MARK: - Primes

let SomeSafePrimes = [5, 7, 11, 23, 47, 59, 83, 107, 167, 179, 227, 263, 347, 359, 383, 467, 479, 503, 563, 587, 719, 839, 863, 887, 983, 1019, 1187, 1283, 1307, 1319, 1367, 1439, 1487, 1523, 1619, 1823, 1907]

let PrimesLessThan1000 = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71, 73, 79, 83, 89, 97, 101, 103, 107, 109, 113, 127, 131, 137, 139, 149, 151, 157, 163, 167, 173, 179, 181, 191, 193, 197, 199, 211, 223, 227, 229, 233, 239, 241, 251, 257, 263, 269, 271, 277, 281, 283, 293, 307, 311, 313, 317, 331, 337, 347, 349, 353, 359, 367, 373, 379, 383, 389, 397, 401, 409, 419, 421, 431, 433, 439, 443, 449, 457, 461, 463, 467, 479, 487, 491, 499, 503, 509, 521, 523, 541, 547, 557, 563, 569, 571, 577, 587, 593, 599, 601, 607, 613, 617, 619, 631, 641, 643, 647, 653, 659, 661, 673, 677, 683, 691, 701, 709, 719, 727, 733, 739, 743, 751, 757, 761, 769, 773, 787, 797, 809, 811, 821, 823, 827, 829, 839, 853, 857, 859, 863, 877, 881, 883, 887, 907, 911, 919, 929, 937, 941, 947, 953, 967, 971, 977, 983, 991, 997]

extension Int
{
    var prime : Bool {
    
        if self <= 1 { return false }
        
        else if self <= 3 { return true }
        
        else if self % 2 == 0 { return false }
        
        else if self % 3 == 0 { return false }
        
        for var i = 5 ; i * i < self; i += 6
        {
            if self % i == 0 { return false }
            if self % (i + 2) == 0 { return false }
        }
        
        return true
    }
}

/**
NSTimeInterval conversion extensions
*/
public extension Int
{
    var years: NSTimeInterval
        { return 365 * self.days }
    
    var year: NSTimeInterval
        { return self.years }
    
    var weeks: NSTimeInterval
        { return 7 * self.days }
    
    var week: NSTimeInterval
        { return self.weeks }
    
    var days: NSTimeInterval
        { return 24 * self.hours }
    
    var day: NSTimeInterval
        { return self.days }
    
    var hours: NSTimeInterval
        { return 60 * self.minutes }
    
    var hour: NSTimeInterval
        { return self.hours }
    
    var minutes: NSTimeInterval
        { return 60 * self.seconds }
    
    var minute: NSTimeInterval
        { return self.minutes }
    
    var seconds: NSTimeInterval
        { return NSTimeInterval(self) }
    
    var second: NSTimeInterval
        { return self.seconds }
}

//MARK: - ByteConcertible

extension Byte : ByteConvertible
{
    static var zero : Byte { return Byte(0) }
    
    var byte : Byte { return self }
    
    init(byte: Byte)
    {
        self.init(byte)
    }
    
    // MARK: - ByteBufferable
    
    init(buffer: ByteBuffer) throws
    {
        self = try buffer.read()
    }
    
    func write(buffer: ByteBuffer)
    {
        buffer.write(self)
    }
}

extension Int8 : ByteConvertible
{
    var byte : Byte { return Byte(bitPattern: self) }
    
    init(byte: Byte)
    {
        self.init(bitPattern: byte)
    }
}

extension UInt16 : ByteBufferable
{
    var bytes : [Byte] {
        
        let mask = UInt16(0xff)
        
        return [1, 0].map{ Byte( (self >> (8 * $0)) & mask ) }
    }
    
    init(bytes: [Byte]) throws
    {
        switch bytes.count
        {
        case 0,1:
            throw BytesConvertibleError.InsufficientBytes(sizeof(Byte), 0)
            
        case 2:
            self = bytes.reduce(UInt16(0)) { ($0 << 8) + UInt16($1) }
            
        default:
            throw BytesConvertibleError.MalformedBytes(bytes)
        }
    }
    
    init(buffer: ByteBuffer) throws
    {
        try self.init(bytes: try buffer.read(sizeof(UInt16)))
    }
    
    func write(buffer: ByteBuffer)
    {
        buffer.write(self.bytes)
    }
}

extension Int16 : ByteBufferable
{
    var bytes : [Byte] { return UInt16(bitPattern: self).bytes }
    
    init(bytes: [Byte]) throws
    {
        self.init(bitPattern: try UInt16(bytes: bytes))
    }
    
    init(buffer: ByteBuffer) throws
    {
        try self.init(bytes: try buffer.read(sizeof(Int16)))
    }
    
    func write(buffer: ByteBuffer)
    {
        buffer.write(self.bytes)
    }
}

extension UInt32 : ByteBufferable
{
    var bytes : [Byte] {
        
        let mask = UInt32(0xff)
        
        return [3, 2, 1, 0].map{ Byte( (self >> (8 * $0)) & mask ) }
        }
    
    init(bytes: [Byte]) throws
    {
        switch bytes.count
        {
        case sizeof(UInt32):
            
            var value : UInt32 = 0
            
            for byte in bytes
            {
                value = value << 8
                value += UInt32(byte)
            }
            
            self.init(value)
            
        default:
            throw BytesConvertibleError.MalformedBytes(bytes)
            
        }
    }
    
    init(buffer: ByteBuffer) throws { try self.init(bytes: try buffer.read(sizeof(UInt32))) }
    
    func write(buffer: ByteBuffer) { buffer.write(self.bytes) }
}

extension Int32 : ByteBufferable
{
    var bytes : [Byte] { return UInt32(bitPattern: self).bytes }
    
    init(bytes: [Byte]) throws { self.init(bitPattern: try UInt32(bytes: bytes)) }
    
    init(buffer: ByteBuffer) throws { try self.init(bytes: try buffer.read(sizeof(Int32))) }
    
    func write(buffer: ByteBuffer) { buffer.write(self.bytes) }
}

extension UInt64 : ByteBufferable
{
    var bytes : [Byte] {
        
        let mask = UInt64(0xff)
        
        return [7, 6, 5, 4, 3, 2, 1, 0].map{ Byte( (self >> (8 * $0)) & mask ) }
    }
    
    init(bytes: [Byte]) throws
    {
        switch bytes.count
        {
        case sizeof(UInt64):
            
            var value : UInt64 = 0
            
            for byte in bytes
            {
                value = value << 8
                value += UInt64(byte)
            }
            
            self.init(value)
            
        default:
            throw BytesConvertibleError.MalformedBytes(bytes)
        }
    }

    init(buffer: ByteBuffer) throws { try self.init(bytes: try buffer.read(sizeof(UInt64))) }
    
    func write(buffer: ByteBuffer) { buffer.write(self.bytes) }
}

extension Int64 : ByteBufferable
{
    var bytes : [Byte] { return UInt64(bitPattern: self).bytes }
    
    init(bytes: [Byte]) throws { self.init(bitPattern: try UInt64(bytes: bytes)) }
    
    init(buffer: ByteBuffer) throws { try self.init(bytes: try buffer.read(sizeof(Int64))) }
    
    func write(buffer: ByteBuffer) { buffer.write(self.bytes) }
}

extension Int : ByteBufferable
{
    var bytes : [Byte]
        {
            if self > Int(Int8.min) && self < Int(Int8.max)
            {
                return Int8(self).bytes
            }
            
            if self > Int(Int16.min) && self < Int(Int16.max)
            {
                return Int16(self).bytes
            }
            
            if self > Int(Int32.min) && self < Int(Int32.max)
            {
                return Int32(self).bytes
            }
            
            let mask = 0xff
            
            let count = 0.stride(to: sizeof(Int), by: 1).reverse()
            
            return count.map{ Byte( (self >> (8 * $0)) & mask ) }
    }
    
    init(bytes: [Byte]) throws
    {
        switch bytes.count
        {
        case 1:
            self.init(try Int8(bytes: bytes))
        case 2:
            self.init(try Int16(bytes: bytes))
        case 4:
            self.init(try Int32(bytes: bytes))
        case 8:
            self.init(bitPattern: try UInt(bytes: bytes))
        default:
            throw BytesConvertibleError.MalformedBytes(bytes)
        }
    }
    
    init(buffer: ByteBuffer) throws { try self.init(bytes: try buffer.read(1, dynamic: true)) }
    
    func write(buffer: ByteBuffer) { buffer.write(self.bytes, optionalPrefixCount: 1) }
}

extension UInt : ByteBufferable
{
    var bytes : [Byte]
        {
            if self < UInt(UInt8.max)
            {
                return UInt8(self).bytes
            }
            
            if self < UInt(UInt16.max)
            {
                return UInt16(self).bytes
            }
            
            if self < UInt(UInt32.max)
            {
                return UInt32(self).bytes
            }

            let mask = UInt(0xff)

            let count = 0.stride(to: sizeof(UInt), by: 1).reverse()

            return count.map{ Byte( (self >> UInt(8 * $0)) & mask ) }
    }
    
    init(bytes: [Byte]) throws
    {
        switch bytes.count
        {
        case 1:
            self.init(try Int8(bytes: bytes))
        case 2:
            self.init(try Int16(bytes: bytes))
        case 4:
            self.init(try Int32(bytes: bytes))
        case 8:
            var value : UInt = 0
            
            for byte in bytes
            {
                value = value << 8
                value += UInt(byte)
            }
            
            self.init(value)
        default:
            throw BytesConvertibleError.MalformedBytes(bytes)
        }
    }
    
    init(buffer: ByteBuffer) throws { try self.init(bytes: try buffer.read(1, dynamic: true)) }
    
    func write(buffer: ByteBuffer) { buffer.write(self.bytes, optionalPrefixCount: 1) }
}
