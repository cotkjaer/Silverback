//
//  ChoiceTests.swift
//  Silverback
//
//  Created by Christian Otkjær on 12/10/15.
//  Copyright © 2015 Christian Otkjær. All rights reserved.
//

import XCTest

class ChoiceTests: XCTestCase
{
    func testGenericChoiceGenerics()
    {
        XCTAssertNotNil(GenericChoice<Int>())
        XCTAssertNotNil(GenericChoice<String>())
        XCTAssertNotNil(GenericChoice<Bool>())
        XCTAssertNotNil(GenericChoice<Byte>())
    }
    
    func testChoose()
    {
        var choice = GenericChoice(options: Set(1,2,3,4,4,3,2,1))
        
        XCTAssertEqual(4, choice.options.count)
        
        XCTAssertEqual(true, choice.chooseOption(1))
        XCTAssertEqual(1, choice.option)
        
        XCTAssertEqual(true, choice.chooseOption(3))
        XCTAssertEqual(3, choice.option)
        
        XCTAssertEqual(false, choice.chooseOption(5))
        XCTAssertEqual(3, choice.option)

        XCTAssertEqual(true, choice.chooseOption(nil))
        XCTAssertEqual(nil, choice.option)
        
        choice = GenericChoice(options: Set(1,2,3,4), defaultOption: 2)
        
        XCTAssertEqual(4, choice.options.count)
        XCTAssertEqual(2, choice.defaultOption)
        XCTAssertEqual(2, choice.option)
        
        XCTAssertEqual(true, choice.chooseOption(3))
        XCTAssertEqual(3, choice.option)
        XCTAssertEqual(2, choice.defaultOption)

        XCTAssertEqual(false, choice.chooseOption(nil))
        XCTAssertEqual(3, choice.option)

    }
    
    func testUnchoose()
    {
        let choice = GenericChoice(options: Set("A","B","C"))
        
        XCTAssertEqual(3, choice.options.count)
        
        XCTAssertEqual(true, choice.chooseOption("A"))
        XCTAssertEqual("A", choice.option)
        
        XCTAssertEqual(true, choice.unchooseOption("A"))
        XCTAssertEqual(nil, choice.option)
        
        XCTAssertEqual(true, choice.chooseOption("C"))
        XCTAssertEqual("C", choice.option)
        
        XCTAssertEqual(false, choice.unchooseOptions("A", "B"))
        XCTAssertEqual("C", choice.option)
        
        XCTAssertEqual(true, choice.unchooseOptions("C", "B"))
        XCTAssertEqual(nil, choice.option)

        XCTAssertEqual(false, choice.unchooseOptions([]))
        XCTAssertEqual(choice.defaultOption, choice.option)

        XCTAssertEqual(false, choice.unchooseOption(nil))
        XCTAssertEqual(choice.defaultOption, choice.option)
    }
    
    func testDefaultOption()
    {
        var choice = GenericChoice(options: Set("A","B","C"), defaultOption: "D")
        
        XCTAssertEqual(3, choice.options.count)
        XCTAssertEqual(nil, choice.defaultOption)

        choice = GenericChoice(options: Set("A","B","C"), defaultOption: "A")
        
        XCTAssertEqual(3, choice.options.count)
        XCTAssertEqual("A", choice.defaultOption)
        XCTAssertEqual(nil, choice.chosenOption)
        XCTAssertEqual(nil, choice.forcedOption)
        XCTAssertEqual("A", choice.option)

        XCTAssertEqual(true, choice.chooseOption("C"))
        XCTAssertEqual("C", choice.option)
        
        XCTAssertEqual(false, choice.unchooseOptions("A", "B"))
        XCTAssertEqual("C", choice.option)
        
        XCTAssertEqual(true, choice.unchooseOptions("C", "B"))
        XCTAssertEqual(choice.defaultOption, choice.option)
    }
    
}
