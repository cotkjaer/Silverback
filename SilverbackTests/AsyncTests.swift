//
//  AsyncTests.swift
//  Silverback
//
//  Created by Christian Otkjær on 18/09/15.
//  Copyright © 2015 Christian Otkjær. All rights reserved.
//

import XCTest

class AsyncTests: XCTestCase {

        
    func testDelay()
    {
        let expectation = expectationWithDescription("delayed closure did run")

        var counter = 0
        
        delay(0.2) {
            
            counter++
            
            XCTAssertGreaterThan(counter, 1)
            
            expectation.fulfill()
        }
        
        XCTAssertEqual(counter, 0)
        
        counter++

        XCTAssertEqual(counter, 1)

        waitForExpectationsWithTimeout(1) { error in

            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }

}
