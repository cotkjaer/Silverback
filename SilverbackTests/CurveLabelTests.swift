//
//  CurveLabelTests.swift
//  Silverback
//
//  Created by Christian Otkjær on 27/11/15.
//  Copyright © 2015 Christian Otkjær. All rights reserved.
//

import XCTest

class CurveLabelTests: XCTestCase
{
    let text = NSDateFormatter(timeStyle: .FullStyle, dateStyle: .FullStyle).stringFromDate(NSDate())// "Lorem π ipsum € dolor § sit $ amet"

    func testNoCurve()
    {
        let cLabel = CurveLabel(frame: CGRectZero)
        
        cLabel.text = text
        
        cLabel.sizeToFit()
        
        XCTAssertGreaterThan(cLabel.bounds.width, 100)
        XCTAssertGreaterThan(cLabel.bounds.height, cLabel.font.pointSize)

        XCTAssertNil(cLabel.curve)
    }

    func testCurve()
    {
        let cLabel = CurveLabel(frame: CGRectZero)
        
        cLabel.text = text
        
        cLabel.sizeToFit()
        
        let bounds = cLabel.bounds
        
        XCTAssertGreaterThan(bounds.width, 100)
        XCTAssertGreaterThan(bounds.height, cLabel.font.pointSize)

        cLabel.curve = CubicBezierCurve(p0: bounds.bottomLeft, p1: bounds.topCenter.with(y: bounds.width), p2: bounds.bottomCenter, p3: bounds.centerRight)
        cLabel.backgroundColor = UIColor.purpleColor()
        
        XCTAssertNotNil(cLabel.curve)
        
        cLabel.sizeToFit()
        
        let newBounds = cLabel.bounds
        
        XCTAssertGreaterThan(newBounds.height, bounds.height)
        XCTAssertGreaterThan(newBounds.width, bounds.width)
        
        debugPrint(cLabel)
    }
}
