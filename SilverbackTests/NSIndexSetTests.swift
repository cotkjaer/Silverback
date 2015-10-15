//
//  NSIndexSetTests.swift
//  Silverback
//
//  Created by Christian Otkjær on 01/10/15.
//  Copyright © 2015 Christian Otkjær. All rights reserved.
//

import XCTest

class NSIndexSetTests: XCTestCase {

    func testInit()
    {
        XCTAssertEqual(NSIndexSet(index: 1), NSIndexSet(indicies: [1,1,1]))
        XCTAssertEqual(NSIndexSet(indicies: [1,2,3,3]), NSIndexSet(indicies: Set(1,2,3)))
    }
    
    func testIndicies()
    {
        XCTAssertEqual(NSIndexSet(indexesInRange: NSMakeRange(10, 10)).indicies, Set(10,11,12,13,14,15,16,17,18,19))
    }
}
