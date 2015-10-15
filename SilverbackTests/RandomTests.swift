//
//  RandomTests.swift
//  Silverback
//
//  Created by Christian Otkjær on 19/09/15.
//  Copyright © 2015 Christian Otkjær. All rights reserved.
//

import XCTest

class RandomTests: XCTestCase {

    func testRandomIntLimits()
    {
        let goodPairs = [(-10, -1), (-10, 0), (-10, 10), (0,1), (0,10), (5,17)]
        
        let iterations = 10000
        
        for (lower, upper) in goodPairs
        {
            var counters = Dictionary<Int,Int>()

            for _ in 1.stride(through: iterations, by: 1)
            {
                let r = Int.random(lower: lower, upper: upper)
                
                counters[r] = (counters[r] ?? 0) + 1
                
                XCTAssertGreaterThanOrEqual(r, lower)
                XCTAssertLessThan(r, upper)
            }
            
            let ratio : Double = Double(iterations) / Double(counters.count)
            
            for (_, count) in counters
            {
                XCTAssertGreaterThan(count, Int(0.9 * ratio))
                XCTAssertLessThan(count,  Int(1.1 * ratio))
            }
            
            let M = max(counters.values)!
            let m = min(counters.values)!
            
            XCTAssertGreaterThanOrEqual(M, m)
            XCTAssertEqualWithAccuracy(Double(m), Double(M), accuracy: 0.2 * ratio)
        }
    }
    
    func testRandomInt()
    {
        let outcomes = 10
        
        var counters = Array<Int>(count: outcomes, repeatedValue: 0)
        
        let iterations = 10000
        
        for _ in 1.stride(through: iterations, by: 1)
        {
            let index = Int.random(lower: 0, upper: outcomes)
            
            counters[index]++
        }

        let M = max(counters)!
        let m = min(counters)!
        
        
        XCTAssertGreaterThan(M, m)
        XCTAssertEqualWithAccuracy(Double(m), Double(M), accuracy: Double((iterations * 1) / ( outcomes * 10)))
        
        for count in counters
        {
            XCTAssertGreaterThan(count,  (iterations * 9) / ( outcomes * 10))
            XCTAssertLessThan(count,  (iterations * 11) / ( outcomes * 10))
        }
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }

}
