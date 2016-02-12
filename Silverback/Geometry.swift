//
//  Geometry.swift
//  Sil/Users/cot/Projects/Silverback/Silverback/Geometry.swiftverback
//
//  Created by Christian Otkjær on 05/10/15.
//  Copyright © 2015 Christian Otkjær. All rights reserved.
//

import Foundation
import CoreGraphics

/// π/2 ~ 3,141592653589793
public let π = CGFloat(M_PI)

/// 2 * π ~ 6,28318530717959
public let π2 = π * 2

/// 4 * π ~ 12,56637061435917
public let π4 = π * 4

/// π/2 ~ 1,5707963267949
public let π_2 = CGFloat(M_PI_2)

/// π/4 ~ 0,78539816339745
public let π_4 = CGFloat(M_PI_4)

/// π/8 ~ 0,39269908169872
public let π_8 = π_4 / 2

/// π/16 ~ 0,19634954084936
public let π_16 = π_4 / 4


public struct LineSegment
{
    var beginPoint: CGPoint
    var endPoint: CGPoint
    
    func distanceTo(point: CGPoint) -> CGFloat
    {
        return minimumDistanceBetweenLineSegment(beginPoint, endPoint, point)
    }
}

/**
 Minimum distance between line segment v-w and point p
 - parameter v: line-segment begin point
 - parameter w: line-segment end point
 - parameter p: point to find distance to
 */
public func minimumDistanceBetweenLineSegment(v: CGPoint, _ w: CGPoint, _ p: CGPoint) -> CGFloat
{
    if v == w { return v.distanceTo(p) }
    
    // |w-v|^2 - avoid a squareroot
    let l2 = v.distanceSquaredTo(w)
    
    // Consider the line extending the segment, parameterized as v + t (w - v).
    // The projection of point p onto that line falls where t = [(p-v) . (w-v)] / |w-v|^2
    let t = dot(p - v, w - v) / l2
    
    if t < 0 // Beyond the 'v' end of the segment
    {
        return distance(p, v)
    }
    else if t > 1 // Beyond the 'w' end of the segment
    {
        return distance(p, w)
    }
    else // Projection falls on the segment
    {
        let projection = v + t * (w - v)
        return distance(p, projection)
    }
}

/**
 Distance between a line-segment and a point
 - parameter lineSegment: line-segment
 - parameter point: point
 - returns: Minimum distance between a line-segment and a point
 */
public func distance(lineSegment:(CGPoint, CGPoint), _ point: CGPoint) -> CGFloat
{
    return minimumDistanceBetweenLineSegment(lineSegment.0, lineSegment.1, point)
}
