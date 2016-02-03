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
    

    func testFirstWhere()
    {
        let array = Array(arrayLiteral: 1,2,3,4,4,4,5,6,7,7,7,8,10)
        
        if let (index, number) = array.firstWhere( { $0 > 4 } )
        {
            XCTAssertEqual(number, 5)
            XCTAssertEqual(index, 6)
        }
        else
        {
            XCTFail("nothing found")
        }
        
        if let (index, number) = array.firstWhere( { $0 > 7 } )
        {
            XCTAssertEqual(number, 8)
            XCTAssertEqual(index, 11)
        }
        else
        {
            XCTFail("nothing found")
        }
        
        if let (index, number) = array.firstWhere( { $0 > 0 } )
        {
            XCTAssertEqual(number, 1)
            XCTAssertEqual(index, 0)
        }
        else
        {
            XCTFail("nothing found")
        }
        
        if let (index, number) = array.firstWhere( { $0 > 10 } )
        {
            XCTFail("found index \(index), element: \(number)")
        }
    }
    
    func testLastWhere()
    {
        let array = Array(arrayLiteral: 1,2,3,4,4,4,5,6,7,7,7,8,10)
        
        if let (index, number) = array.lastWhere( { $0 < 5 } )
        {
            XCTAssertEqual(number, 4)
            XCTAssertEqual(index, 5)
        }
        else
        {
            XCTFail("nothing found")
        }

        if let (index, number) = array.lastWhere( { $0 < 10 } )
        {
            XCTAssertEqual(number, 8)
            XCTAssertEqual(index, 11)
        }
        else
        {
            XCTFail("nothing found")
        }

        if let (index, number) = array.lastWhere( { $0 < 100 } )
        {
            XCTAssertEqual(number, 10)
            XCTAssertEqual(index, 12)
        }
        else
        {
            XCTFail("nothing found")
        }

        if let (index, number) = array.lastWhere( { $0 < 1 } )
        {
            XCTFail("found index \(index), element: \(number)")
        }
    }
    
}
