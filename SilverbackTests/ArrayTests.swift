//
//  ArrayTests.swift
//  Silverback
//
//  Created by Christian Otkjær on 07/10/15.
//  Copyright © 2015 Christian Otkjær. All rights reserved.
//

import XCTest

class ArrayTests: XCTestCase
{
    func testChanges()
    {
        let a1 = ["a", "b", "c", "d"]
        let a2 = ["c", "f", "b", "e"]
    
        let deleted = a1.missingIndicies(a2)

        XCTAssertEqual(deleted, [0,3])

        let inserted = a2.missingIndicies(a1)
        
        XCTAssertEqual(inserted, [1,3])
    }
}
