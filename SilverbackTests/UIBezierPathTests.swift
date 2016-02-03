//
//  UIBezierPathTests.swift
//  Silverback
//
//  Created by Christian Otkjær on 26/11/15.
//  Copyright © 2015 Christian Otkjær. All rights reserved.
//

import XCTest

class UIBezierPathTests: XCTestCase
{
    func path() -> UIBezierPath
    {
        let path = UIBezierPath()
        path.moveToPoint(CGPoint(x: 0, y: 0))
        path.addLineToPoint(CGPoint(x: 100, y: 0))
        path.addLineToPoint(CGPoint(x: 50, y: 100))
        path.closePath()
        path.moveToPoint(CGPoint(x: 0, y: 100))
        path.addQuadCurveToPoint(CGPoint(x: 100, y: 100),
            controlPoint: CGPoint(x: 50, y: 200))
        path.closePath()
        path.moveToPoint(CGPoint(x: 100, y: 0))
        path.addCurveToPoint(CGPoint(x: 200, y: 0),
            controlPoint1: CGPoint(x: 125, y: 100),
            controlPoint2: CGPoint(x: 175, y: -100))
        path.closePath()

        return path
    }

    
    func testInitElements()
    {
        let p2 = UIBezierPath(elements: path().elements)
        
        XCTAssertEqual(p2, path())
    }

    func testInitString()
    {
        let helloπ = UIBezierPath(string: "Hello π", withFont: UIFont.systemFontOfSize(72))
        
        XCTAssertGreaterThan(helloπ.elements.count, 20)
        
        UIImagePNGRepresentation(helloπ.image())!.writeToFile("/Users/cot/Desktop/testInitStringHello.png", atomically:false)
    }

    func testInitStringZapfino()
    {
        if let font = UIFont(name: "Zapfino", size: 32)
        {
            
            let helloπ = UIBezierPath(string: "Zapfino is the best font, EVER!", withFont: font)
            
            XCTAssertGreaterThan(helloπ.elements.count, 20)
            
            UIImagePNGRepresentation(helloπ.image())!.writeToFile("/Users/cot/Desktop/testInitStringZapfino.png", atomically:false)
        }
        else
        {
            XCTFail("could not make font")
        }
    }

    func testInterpolated()
    {
        let scale = 10
        let points = (1...100).map({ CGPoint(x: $0*scale, y: Int.random(lower: 0, upper: $0*scale))})
        
        if let path = UIBezierPath(quadraticBezierInterpolatedPoints: points)
        {
            let linePath = UIBezierPath()
            linePath.moveToPoint(points[0])
            points[1..<points.count].forEach{ linePath.addLineToPoint($0)}
            
            XCTAssertGreaterThan(path.bounds.width, 0)
        }
        else
        {
            XCTFail("could not make path")
        }
    }

    func testInterpolatedRadial()
    {
        let points = π2.stride(to: 0, by: -π/180).map{ CGPoint(x: cos($0), y: sin($0)) * CGFloat.random(lower: 100, upper: 200) }
        
        if let path = UIBezierPath(quadraticBezierInterpolatedPoints: points)
        {
            let linePath = UIBezierPath()
            linePath.moveToPoint(points[0])
            points[1..<points.count].forEach{ linePath.addLineToPoint($0)}
            
            XCTAssertGreaterThan(path.bounds.width, 0)
        }
        else
        {
            XCTFail("could not make path")
        }
    }
}
