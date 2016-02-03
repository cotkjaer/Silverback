//
//  CGPath.swift
//  Silverback
//
//  Created by Christian Otkjær on 26/11/15.
//  Copyright © 2015 Christian Otkjær. All rights reserved.
//


import UIKit

// MARK: - Contains

extension CGPath
{
    public func contains(point: CGPoint) -> Bool
    {
        return CGPathContainsPoint(self, nil, point, false)
    }
}


//MARK: - Elements

extension CGPathRef : CustomDebugStringConvertible
{
    private typealias PathApplier = @convention(block) (UnsafePointer<CGPathElement>) -> Void
    // Note: You must declare PathApplier as @convention(block), because
    // if you don't, you get "fatal error: can't unsafeBitCast between
    // types of different sizes" at runtime, on Mac OS X at least.
    
    private func pathApply(path: CGPath!, block: PathApplier) {
        let callback: @convention(c) (UnsafeMutablePointer<Void>, UnsafePointer<CGPathElement>) -> Void = { (info, element) in
            let block = unsafeBitCast(info, PathApplier.self)
            block(element)
        }
        
        CGPathApply(path, unsafeBitCast(block, UnsafeMutablePointer<Void>.self), unsafeBitCast(callback, CGPathApplierFunction.self))
    }
 
    public var debugDescription : String {
    
        pathApply(self) { element in
            switch (element.memory.type) {
            case CGPathElementType.MoveToPoint:
                print("move(\(element.memory.points[0]))")
            case .AddLineToPoint:
                print("line(\(element.memory.points[0]))")
            case .AddQuadCurveToPoint:
                print("quadCurve(\(element.memory.points[0]), \(element.memory.points[1]))")
            case .AddCurveToPoint:
                print("curve(\(element.memory.points[0]), \(element.memory.points[1]), \(element.memory.points[2]))")
            case .CloseSubpath:
                print("close()")
            }
        }
     
        return ""
    }
    
    public func elements() -> Array<CGPathElement>
    {
        var cgPathElements = Array<CGPathElement>()
        
        withUnsafeMutablePointer(&cgPathElements) { cgPathElementsPointer in
            
            pathApply(self) { elementPointer in
                
                let element = elementPointer.memory
                
                switch element.type
                {
                case CGPathElementType.MoveToPoint:
                    debugPrint("move(\(element.points[0]))")
                case .AddLineToPoint:
                    debugPrint("line(\(element.points[0]))")
                case .AddQuadCurveToPoint:
                    debugPrint("quadCurve(\(element.points[0]), \(element.points[1]))")
                case .AddCurveToPoint:
                    debugPrint("curve(\(element.points[0]), \(element.points[1]), \(element.points[2]))")
                case .CloseSubpath:
                    debugPrint("close()")
                }
                
                cgPathElementsPointer.memory.append(element)
//                array.append(element)
                
//                UnsafeMutablePointer<Array<CGPathElement>>(cgPathElementsPointer).memory.append(elementPointer.memory)
            }
            
//            CGPathApply(self, cgPathElementsPointer) { cgPathElementsPointer, cgPathElementPointer in
//                
//                UnsafeMutablePointer<Array<CGPathElement>>(cgPathElementsPointer).memory.append(cgPathElementPointer.memory)
//            }
        }
        
        return cgPathElements
    }
    
    
    
    
    func enumerateElements(closure : CGPathElement -> ())
    {
        pathApply(self) { (elementPointer: UnsafePointer<CGPathElement>) -> Void in
            
            closure(elementPointer.memory)
            
        }
    }
}

// MARK: - Text

//MARK: - Font

extension CTRunRef
{
    var font : CTFontRef
        {
            let key = unsafeAddressOf(kCTFontAttributeName)
            
            let attributes = CTRunGetAttributes(self)
            
            let value = CFDictionaryGetValue(attributes, key)
            
            let font:CTFontRef = unsafeBitCast(value, CTFontRef.self)
            
            return font
    }
}

// MARK: Single Line String Path

public func CGPathCreateSingleLineStringWithAttributedString(attrString: NSAttributedString) -> CGPathRef
{
    let letters = CGPathCreateMutable()
    
    let line = CTLineCreateWithAttributedString(attrString)
    
    let anyArray = CTLineGetGlyphRuns(line) as [AnyObject]
    
    if let runArray = anyArray as? Array<CTRunRef>
    {
        for run in runArray
        {
            // for each glyph in run
            
            for runGlyphIndex in 0..<CTRunGetGlyphCount(run)
            {
                // get glyph and position
                let thisGlyphRange = CFRangeMake(runGlyphIndex, 1)
                var glyph : CGGlyph = 0
                var position : CGPoint = CGPointZero
                
                CTRunGetGlyphs(run, thisGlyphRange, &glyph)
                
                CTRunGetPositions(run, thisGlyphRange, &position)
                
                // Get PATH of outline

                let letter = CTFontCreatePathForGlyph(run.font, glyph, nil)
                var t = CGAffineTransformMakeTranslation(position.x, position.y)
                CGPathAddPath(letters, &t, letter)
            }
        }
    }
    
    return CGPathCreateCopy(letters) ?? letters
}

/*
// MARK: - Multiple Line String Path

CGPathRef CGPathCreateMultilineStringWithAttributedString(NSAttributedString *attrString, CGFloat maxWidth, CGFloat maxHeight)
{
    
    CGMutablePathRef letters = CGPathCreateMutable();
    
    CGRect bounds = CGRectMake(0, 0, maxWidth, maxHeight);
    
    CGPathRef pathRef = CGPathCreateWithRect(bounds, NULL);
    
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)(attrString));
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), pathRef, NULL);
    
    CFArrayRef lines = CTFrameGetLines(frame);
    
    CGPoint *points = malloc(sizeof(CGPoint) * CFArrayGetCount(lines));
    
    CTFrameGetLineOrigins(frame, CFRangeMake(0, 0), points);
    
    NSInteger numLines = CFArrayGetCount(lines);
    // for each LINE
    for (CFIndex lineIndex = 0; lineIndex < numLines; lineIndex++)
    {
        CTLineRef lineRef = CFArrayGetValueAtIndex(lines, lineIndex);
        
        CFRange r = CTLineGetStringRange(lineRef);
        
        NSParagraphStyle *paragraphStyle = [attrString attribute:NSParagraphStyleAttributeName atIndex:r.location effectiveRange:NULL];
        NSTextAlignment alignment = paragraphStyle.alignment;
        
        
        CGFloat flushFactor = 0.0;
        if (alignment == NSTextAlignmentLeft) {
            flushFactor = 0.0;
        } else if (alignment == NSTextAlignmentCenter) {
            flushFactor = 0.5;
        } else if (alignment == NSTextAlignmentRight) {
            flushFactor = 1.0;
        }
        
        
        
        CGFloat penOffset = CTLineGetPenOffsetForFlush(lineRef, flushFactor, maxWidth);
        
        // create a new justified line if the alignment is justified
        if (alignment == NSTextAlignmentJustified) {
            lineRef = CTLineCreateJustifiedLine(lineRef, 1.0, maxWidth);
            penOffset = 0;
        }
        
        CGFloat lineOffset = numLines == 1 ? 0 : maxHeight - points[lineIndex].y;
        
        CFArrayRef runArray = CTLineGetGlyphRuns(lineRef);
        
        // for each RUN
        for (CFIndex runIndex = 0; runIndex < CFArrayGetCount(runArray); runIndex++)
        {
            // Get FONT for this run
            CTRunRef run = (CTRunRef)CFArrayGetValueAtIndex(runArray, runIndex);
            CTFontRef runFont = CFDictionaryGetValue(CTRunGetAttributes(run), kCTFontAttributeName);
            
            // for each GLYPH in run
            for (CFIndex runGlyphIndex = 0; runGlyphIndex < CTRunGetGlyphCount(run); runGlyphIndex++)
            {
                // get Glyph & Glyph-data
                CFRange thisGlyphRange = CFRangeMake(runGlyphIndex, 1);
                CGGlyph glyph;
                CGPoint position;
                CTRunGetGlyphs(run, thisGlyphRange, &glyph);
                CTRunGetPositions(run, thisGlyphRange, &position);
                
                position.y -= lineOffset;
                position.x += penOffset;
                
                CGPathRef letter = CTFontCreatePathForGlyph(runFont, glyph, NULL);
                CGAffineTransform t = CGAffineTransformMakeTranslation(position.x, position.y);
                CGPathAddPath(letters, &t, letter);
                CGPathRelease(letter);
            }
        }
        
        // if the text is justified then release the new justified line we created.
        if (alignment == NSTextAlignmentJustified) {
            CFRelease(lineRef);
        }
    }
    
    free(points);
    
    CGPathRelease(pathRef);
    CFRelease(frame);
    CFRelease(framesetter);
    
    CGRect pathBounds = CGPathGetBoundingBox(letters);
    CGAffineTransform transform = CGAffineTransformMakeTranslation(-pathBounds.origin.x, -pathBounds.origin.y);
    CGPathRef finalPath = CGPathCreateCopyByTransformingPath(letters, &transform);
    CGPathRelease(letters);
    
    return finalPath;
}
*/