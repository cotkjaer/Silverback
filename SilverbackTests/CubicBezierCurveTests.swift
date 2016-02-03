//
//  CubicBezierCurveTests.swift
//  Silverback
//
//  Created by Christian Otkjær on 25/11/15.
//  Copyright © 2015 Christian Otkjær. All rights reserved.
//

import XCTest

class CubicBezierCurveTests: XCTestCase
{
    func testInit()
    {
        let c = CubicBezierCurve(p0: CGPoint(x:0, y : 50), p1:CGPoint(x: 300, y: 100) , p2: CGPoint(x: 100, y: 00), p3: CGPoint(x: 400, y: 70))
        
        UIGraphicsBeginImageContext(CGSize(widthAndHeight: 500))
        
        c.draw()
        
        let img = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        UIImagePNGRepresentation(img)!.writeToFile("/Users/cot/Desktop/watchImage.png", atomically:false)
        
        XCTAssert(img.size.width > 100)
        
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testCgPathElements()
    {
        let cgPath = UIBezierPath(ovalInRect: CGRect(x: 100, y: 200, width: 300, height: 50)).CGPath
        
        let elements = cgPath.elements()
        
        XCTAssertEqual(elements.count, 6)
        
        debugPrint(cgPath.elements())
    }
    
    func testWarpText()
    {
        let text = NSDateFormatter(timeStyle: .FullStyle, dateStyle: .FullStyle).stringFromDate(NSDate())// "Lorem π ipsum € dolor § sit $ amet"
        let font = UIFont.systemFontOfSize(17)
        let textPath = UIBezierPath(string: text, withFont: font)
        
        let frame = textPath.bounds
        
        let curve = CubicBezierCurve(p0: frame.bottomLeft, p1: frame.topCenter.with(y: frame.maxX), p2: frame.bottomCenter, p3: frame.bottomRight)
        
        for align in Array<NSTextAlignment>(arrayLiteral: .Center, .Justified, .Left, .Natural, .Right)
        {
            let warpedTextPath = curve.warp(text, font: font, textAlignment: align)
            
            UIImagePNGRepresentation(warpedTextPath.image(fillColor: UIColor.blackColor(), lineWidth: 1, backgroundColor: UIColor.greenColor()))!.writeToFile("/Users/cot/Desktop/testWarpText\(align.description).png", atomically:false)
            
        }
    }
}
