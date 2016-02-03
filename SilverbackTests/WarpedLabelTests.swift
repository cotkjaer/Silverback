//
//  WarpedLabelTests.swift
//  Silverback
//
//  Created by Christian Otkjær on 29/11/15.
//  Copyright © 2015 Christian Otkjær. All rights reserved.
//

import XCTest

class WarpedLabelTests: XCTestCase
{
    let text = NSDateFormatter(timeStyle: .FullStyle, dateStyle: .FullStyle).stringFromDate(NSDate())// "Lorem π ipsum € dolor § sit $ amet"
    
    func testNoPath()
    {
        let wLabel = WarpedLabel(frame: CGRectZero)
        
        wLabel.text = text
        
        wLabel.sizeToFit()
        
        XCTAssertGreaterThan(wLabel.bounds.width, 100)
        XCTAssertGreaterThanOrEqual(wLabel.bounds.height, wLabel.font.pointSize)
        
        XCTAssertNil(wLabel.path)
    }
    
    func testPath()
    {
        let wLabel = WarpedLabel(frame: CGRectZero)
        
        wLabel.text = text
        
        wLabel.sizeToFit()
        
        let bounds = wLabel.bounds
        
        let radius = bounds.width / 2

//        let path = UIBezierPath(roundedRect: CGRect(size: CGSize(widthAndHeight: radius)), cornerRadius: radius/4)
        
        let path = UIBezierPath()
        
        path.moveToPoint(CGPoint(x: -radius, y: 0))
        path.addArcWithCenter(CGPointZero, radius: radius, startAngle: π, endAngle: 0, clockwise: true)
        
        wLabel.textAlignment = .Justified
        wLabel.path = path
        
        XCTAssertNotNil(wLabel.path)
        
        wLabel.sizeToFit()
        
        let newBounds = wLabel.bounds
        
        XCTAssertGreaterThan(newBounds.height, bounds.height)
        XCTAssertGreaterThan(newBounds.width, bounds.width)
        
        debugPrint(wLabel)
        
        if let image = wLabel.image, let png = UIImagePNGRepresentation(image)
        {
            png.writeToFile("/Users/cot/Desktop/WarpedLabelTestPath.png", atomically:false)
        }
        else
        {
            XCTFail("No image")
        }
    }

    func testLabel()
    {
        let font = UIFont.systemFontOfSize(9, weight: UIFontWeightLight)
        
        let size = CGSize(widthAndHeight: 60 + font.descender)
        
        let wLabel = WarpedLabel()
        
        wLabel.font = font
        wLabel.textAlignment = .Center
        
        wLabel.path = UIBezierPath(arcCenter: CGPointZero, radius: size.width / 2, startAngle: π, endAngle: 0, clockwise: true)
        
        wLabel.text = "Finger of Death"
        
        
        if let image = wLabel.image, let png = UIImagePNGRepresentation(image)
        {
            png.writeToFile("/Users/cot/Desktop/WarpedLabelTestLabel.png", atomically:false)
        }
        else
        {
            XCTFail("No image")
        }
    }
}
