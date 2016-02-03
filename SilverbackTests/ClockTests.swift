//
//  ClockTests.swift
//  Silverback
//
//  Created by Christian Otkjær on 10/11/15.
//  Copyright © 2015 Christian Otkjær. All rights reserved.
//

import XCTest

class ClockTests: XCTestCase
{
    func testSecond()
    {
        var runCounter = 0

        let clock = Clock(unit: .Second) { runCounter++ }

        XCTAssertEqual(runCounter, 0)
        XCTAssertEqual(clock.running, false)

        clock.start()
        
        XCTAssertEqual(runCounter, 0)
        XCTAssertEqual(clock.running, true)
        
        let expectation = expectationWithDescription("scheduled closure did run")
        
        let fulfillTask =
        Task({ XCTAssertGreaterThanOrEqual(runCounter, 9)
             expectation.fulfill() })
        
        fulfillTask.schedule(10)
        
        waitForExpectationsWithTimeout(12) { e in
            
            if let error = e
            {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
}
