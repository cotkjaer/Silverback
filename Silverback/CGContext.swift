//
//  CGContext.swift
//  SilverbackFramework
//
//  Created by Christian Otkjær on 12/08/15.
//  Copyright (c) 2015 Christian Otkjær. All rights reserved.
//

import CoreGraphics

public func CGContextRotateAroundPoint(context: CGContextRef,  point: CGPoint,  angle: CGFloat)
{
    CGContextTranslateCTM(context,  point.x , point.y)
    CGContextRotateCTM(context, angle)
    CGContextTranslateCTM(context, -point.x, -point.y)
}

public func CGContext(context: CGContextRef, rotate angle: CGFloat, aroundPoint point: CGPoint)
{
    CGContextRotateAroundPoint(context, point: point, angle: angle)
}