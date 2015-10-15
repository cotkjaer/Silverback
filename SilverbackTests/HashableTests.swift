//
//  HashableTests.swift
//  Silverback
//
//  Created by Christian Otkjær on 12/10/15.
//  Copyright © 2015 Christian Otkjær. All rights reserved.
//

import XCTest

class HashableTests: XCTestCase {

    func testContainedIn()
    {
        var i: Int? = 10
        
        var set : Set<Int>? = Set(0,10,20,30)
        var array : Array<Int>? = [0,1,2,3,4,5,6,7,8,9,10]
        
        XCTAssertEqual(true, i?.containedIn(set))
        XCTAssertEqual(true, i?.containedIn(array))
        
        i = 50
        
        XCTAssertEqual(false, i?.containedIn(set))
        XCTAssertEqual(false, i?.containedIn(array))
        
        i = nil
        
        XCTAssertEqual(nil, i?.containedIn(set))
        XCTAssertEqual(nil, i?.containedIn(array))
        
        
        set?.removeAll()
        array?.removeAll()
        
        XCTAssertEqual(nil, i?.containedIn(set))
        XCTAssertEqual(nil, i?.containedIn(array))

        i = 10
        
        XCTAssertEqual(false, i?.containedIn(set))
        XCTAssertEqual(false, i?.containedIn(array))
        
        set = nil
        array = nil
    
        XCTAssertEqual(false, i?.containedIn(set))
        XCTAssertEqual(false, i?.containedIn(array))
        
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }

}
