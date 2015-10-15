//
//  SequenceTypeTests.swift
//  Silverback
//
//  Created by Christian Otkjær on 16/09/15.
//  Copyright © 2015 Christian Otkjær. All rights reserved.
//

import XCTest

class SequenceTypeTests: XCTestCase {

    func testUniques() {
        XCTAssertEqual([1,6,7,4,3,2,1,2,3,1,3,4,0].uniques, [1,6,7,4,3,2,0])
    }

    func testJoinedWithSeparatorPrefixSuffix()
    {
        XCTAssertEqual(["foo", "bar", "baz"].joinedWithSeparator("-", prefix: "O", suffix:""), "Ofoo-Obar-Obaz")
    }

}
