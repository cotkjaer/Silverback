//
//  CGAffineTransform.swift
//  SilverbackFramework
//
//  Created by Christian Otkjær on 20/04/15.
//  Copyright (c) 2015 Christian Otkjær. All rights reserved.
//

import CoreGraphics

// MARK: - Equatable

extension CGAffineTransform: Equatable
{
    public func isEqualTo(transform:CGAffineTransform) -> Bool
{
        return self == transform
    }
}

public func == (t1: CGAffineTransform, t2: CGAffineTransform) -> Bool
{
    return CGAffineTransformEqualToTransform(t1, t2)
}

// MARK: - DebugPrintable

extension CGAffineTransform: CustomDebugStringConvertible
{
    public var debugDescription: String
{
            return "(\(a), \(b), \(c), \(d), \(tx), \(ty))"
    }
}

// MARK: - Operators

public func * (t1: CGAffineTransform, t2: CGAffineTransform) -> CGAffineTransform
{
    return CGAffineTransformConcat(t1, t2)
}

public func *= (inout t1: CGAffineTransform, t2: CGAffineTransform)
{
    t1 = t1 * t2//CGAffineTransformConcat(t1, t2)
}