//
//  IntTests.swift
//  Silverback
//
//  Created by Christian Otkjær on 16/09/15.
//  Copyright © 2015 Christian Otkjær. All rights reserved.
//

import XCTest

class IntTests: XCTestCase {
    
    func testTimes()
    {
        XCTAssertEqual(5.times({ return $0 }), [0,1,2,3,4])
        XCTAssertEqual(5.times({ return Int.random(lower: 0, upper: 10) }).count, 5)
        
        var count = 0
        5.times({ count++ })
        XCTAssertEqual(count, 5)
    }
    
    func testOddEven()
    {
        XCTAssert(2.even)
        XCTAssertFalse(129398121.even)

        let negativeFive = -5

        XCTAssert(negativeFive.odd)
        XCTAssert((-71).odd)
        XCTAssertFalse(80.odd)
    }
    
    func testUpTo()
    {
        var count = 0
        5.upTo(10) { _ in count++ }
        XCTAssertEqual(count, 5)
        
        count = 0
        10.upTo(5) { _ in count++ }
        XCTAssertEqual(count, 0)
        
        count = 0
        (-10).upTo(5) { _ in count++ }
        XCTAssertEqual(count, 15)
        
        
    }
    
}
