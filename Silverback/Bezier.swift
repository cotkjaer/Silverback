//
//  Bezier.swift
//  Silverback
//
//  Created by Christian Otkjær on 24/11/15.
//  Copyright © 2015 Christian Otkjær. All rights reserved.
//

import UIKit

// MARK: Single Line String Path

/*
public func CGPathCreateSingleLineStringWithAttributedString(attrString: NSAttributedString) -> CGPathRef
{
    var letters = CGPathCreateMutable();
    
    let line : CTLineRef = CTLineCreateWithAttributedString(attrString as CFAttributedStringRef)
    
    let runArray : CFArrayRef = CTLineGetGlyphRuns(line)
    
    // for each RUN
    for var runIndex : CFIndex = 0; runIndex < CFArrayGetCount(runArray); runIndex++
    {
        // Get FONT for this run
        let run: CTRunRef = CFArrayGetValueAtIndex(runArray, runIndex) as! CTRunRef
        let runFont: CTFontRef = CFDictionaryGetValue(CTRunGetAttributes(run), UnsafePointer<Void>(kCTFontAttributeName)) as! CTFontRef
        
        // for each GLYPH in run
        for var runGlyphIndex : CFIndex = 0; runGlyphIndex < CTRunGetGlyphCount(run); runGlyphIndex++
        {
            // get Glyph & Glyph-data
            let thisGlyphRange = CFRangeMake(runGlyphIndex, 1)
            var glyph : CGGlyph
            var position = CGPointZero
            CTRunGetGlyphs(run, thisGlyphRange, &glyph);
            CTRunGetPositions(run, thisGlyphRange, &position);
            
            // Get PATH of outline
            
            let letter = CTFontCreatePathForGlyph(runFont, glyph, nil)
            var t = CGAffineTransformMakeTranslation(position.x, position.y)
            CGPathAddPath(letters, &t, letter)
        }
    }
    
    if let finalPath : CGPathRef = CGPathCreateCopy(letters)
    {
        return finalPath
    }
    return letters
}
*/


/**
evaluate a point on a bezier-curve using DeCasteljau Subdivision
- parameter a: begin point
- parameter b: control point 1
- parameter c: control point 2
- parameter d: end point
- parameter t: percentage of distance traveled from begin point to end point, defaults to 0.5
*/
public func DeCasteljauCubicBezierPoint(a: CGPoint, b : CGPoint, c : CGPoint, d : CGPoint, t: CGFloat = 0.5) -> CGPoint
{
    let ab = lerp(a,b,t)           // point between a and b
    let bc = lerp(b,c,t)           // point between b and c
    let cd = lerp(c,d,t)           // point between c and d
    let abbc = lerp(ab,bc,t)       // point between ab and bc
    let bccd = lerp(bc,cd,t)       // point between bc and cd
    return lerp(abbc,bccd,t)       // point on the bezier-curve
}

/**
 evaluate a point on a cubic Bézier curves using definition
 - parameter a: begin point
 - parameter b: control point 1
 - parameter c: control point 2
 - parameter d: end point
 - parameter t: percentage of distance traveled from begin point to end point, defaults to 0.5
 */
public func cubicBezierPoint(a: CGPoint, b : CGPoint, c : CGPoint, d : CGPoint, t: CGFloat = 0.5) -> CGPoint
{
    return ((1 - t) * (1 - t) * (1 - t)) * a
        + 3 * ((1 - t) * (1 - t)) * t * b
        + 3 * (1 - t) * (t * t) * c
        + (t * t * t) * d
}

/**
 evaluate a point on a quadratic Bézier curves using definition
 - parameter a: begin point
 - parameter b: control point 1
 - parameter c: control point 2
 - parameter d: end point
 - parameter t: percentage of distance traveled from begin point to end point, defaults to 0.5
 */
public func quadraticBezierPoint(a: CGPoint, b : CGPoint, c : CGPoint, t: CGFloat = 0.5) -> CGPoint
{
    return (1 - t) * (1 - t) * a
        + 2 * (1 - t) * t * b
        + t * t * c
}
