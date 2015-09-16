//
//  OperatorsTests.swift
//  Silverback
//
//  Created by Christian Otkjær on 16/09/15.
//  Copyright © 2015 Christian Otkjær. All rights reserved.
//

import XCTest

class OperatorsTests: XCTestCase
{
    func testOptionalEquals()
    {
        let one : Int? = 1
        let none : Int? = nil
        
        XCTAssert(none =?= none)
        XCTAssert(none =?= one)
        XCTAssert(one =?= none)
        XCTAssert(one =?= one)

        XCTAssert(none =!= none)
        XCTAssertFalse(none =!= one)
        XCTAssertFalse(one =!= none)
        XCTAssert(one =!= one)
    }

    func testPowOperator()
    {
        XCTAssertEqual(256, 4 ** 4)
        XCTAssertEqual(1.0/256.0, 4 ** -4)
        XCTAssertEqual(256, -4 ** 4)
        XCTAssertEqual(1.0/256.0, -4 ** -4)
        
        XCTAssertEqual(1, 4 ** 0)
        XCTAssertEqual(4, 4 ** 1)
        XCTAssertEqual(1.0/4.0, 4 ** -1)
        XCTAssertEqual(-1.0/4.0, -4 ** -1)
    }
    
    func testConditionalAssign()
    {
        var variable = 2
        
        variable >?= 1
        
        XCTAssertEqual(variable , 2)
        
        variable >?= 23
        
        XCTAssertEqual(variable , 23)
    }
    
}
