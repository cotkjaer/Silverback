//
//  GraphicsPathTests.swift
//  Silverback
//
//  Created by Christian Otkjær on 25/11/15.
//  Copyright © 2015 Christian Otkjær. All rights reserved.
//

import XCTest
import UIKit

class GraphicsPathTests: XCTestCase
{
    override func setUp()
    {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown()
    {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testInit()
    {
        let uiPath = UIBezierPath(ovalInRect: CGRect(origin: CGPointZero, size: CGSize(width: 100, height: 100)))
        
        let graphicsPath = GraphicsPath(uiBezierPath: uiPath)
        
        debugPrint(graphicsPath)
        
        XCTAssertGreaterThan(graphicsPath.elements.count, 2)
    }
    

    func testInitStringI()
    {
        let graphicsPath = GraphicsPath(string: "F", withFont: UIFont.systemFontOfSize(17))

        debugPrint(graphicsPath)
        
        let frame = graphicsPath.frame
        
        XCTAssertGreaterThan(frame.size.width, 2)
        XCTAssertGreaterThan(frame.size.height, 10)
        
        XCTAssertGreaterThan(graphicsPath.elements.count, 2)
        
        var size = graphicsPath.frame.size
        size.width += 2
        size.height += 2
        
        UIGraphicsBeginImageContext(size)
        
        graphicsPath.fill()
        
        let img = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        UIImagePNGRepresentation(img)!.writeToFile("/Users/cot/Desktop/testInitStringI.png", atomically:false)
        
        
    }

    
    func testInitAttributedString()
    {
        let attrText = NSAttributedString(string: "Hello π", attributes: [NSFontAttributeName : UIFont.systemFontOfSize(100)])
        
        let graphicsPath = GraphicsPath(attributedString: attrText)
        
        debugPrint(graphicsPath)
        
        let frame = graphicsPath.frame
        
        XCTAssertGreaterThan(frame.size.width, 0)
        XCTAssertGreaterThan(frame.size.height, 0)
        
        XCTAssertGreaterThan(graphicsPath.elements.count, 2)
        
        var size = graphicsPath.frame.size
        size.width += 2
        size.height += 2
        
        UIGraphicsBeginImageContext(size)
        
        
        graphicsPath.fill()
        
        let img = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        UIImagePNGRepresentation(img)!.writeToFile("/Users/cot/Desktop/testInitAttributedString.png", atomically:false)
        
        
    }
    
    

}
