//
// Double.swift
// SilverbackFramework
//
// Created by Christian Otkjær on 20/04/15.
// Copyright (c) 2015 Christian Otkjær. All rights reserved.
//

import Foundation

extension Double
{
    /**
    Absolute value.
    
    - returns: fabs(self)
    */
    public var abs: Double
{
            return Foundation.fabs(self)
    }
    
    /**
    Squared root.
    
    - returns: sqrt(self)
    */
    public var sqrt: Double
{
            return Foundation.sqrt(self)
    }
    
    /**
    Rounds self to the largest integer <= self.
    
    - returns: floor(self)
    */
    public var floor: Double
{
            return Foundation.floor(self)
    }
    
    /**
    Clamps self to a specified range.
    
    - parameter lower: Lower bound
    - parameter upper: Upper bound
    - returns: Clamped value
    */
    func clamp (lower: Double, _ upper: Double) -> Double
{
        return Swift.max(lower, Swift.min(upper, self))
    }
    
    /**
    Rounds self to the smallest integer >= self.
    
    - returns: ceil(self)
    */
    public var ceil: Double
{
            return Foundation.ceil(self)
    }
    
    /**
    Rounds self to the nearest integer.
    
    - returns: round(self)
    */
    public var round: Double
{
            return Foundation.round(self)
    }

    /**
    Rounding to arbitrary number
    
    :params: number the number to round to
    */
    public func roundToNearest(number: Double) -> Double
{
        let remainder = self % number
        return remainder < number / 2 ? self - remainder : self - remainder + number
    }
    
    public func format(format: String? = "") -> String
{
        return String(format: "%\(format)f", self)
    }
}


//MARK: - Bytes

extension Double : BytesInitializable//Convertible
{
    typealias FormBytesConvertibleType = Double
    
    public static func fromBytes(bytes: [Byte], offset: Int) throws -> (Int, Double)
    {
        let length = sizeofValue(Double)
        
        guard bytes.count >= offset + length else { throw BytesConvertibleError.InsufficientBytes(offset, length) }
        
        var pointer = UnsafePointer<Byte>(bytes)
        pointer = pointer.advancedBy(offset)
        
        let doublePointer =  UnsafePointer<Double>(pointer)

        return (offset + length, doublePointer.memory)
    }
    
    public func toBytes() -> [Byte]
    {
        let length = sizeofValue(Double)
        
        let bytes = Array<Byte>(count: length, repeatedValue: 0)
        let bPointer = UnsafeMutablePointer<Byte>(bytes)
        
        var this = self
        
        memcpy(bPointer, &this, length)
        
        return bytes
    }
    
    public init(bytes: [Byte]) throws
    {
        (_ , self) = try Double.fromBytes(bytes, offset: 0)
    }
    
    public init(buffer: ByteBuffer) throws
    {
//        let length = sizeofValue(Double)
//
//        let bytes = try buffer.read(length)
//        
        try self.init(bytes: try buffer.read(sizeof(Double)))
    }
}
