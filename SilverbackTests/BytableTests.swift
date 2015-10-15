//
//  BytableTests.swift
//  Silverback
//
//  Created by Christian Otkjær on 09/10/15.
//  Copyright © 2015 Christian Otkjær. All rights reserved.
//

import XCTest

class BytableTests: XCTestCase {

    func testBool()
    {
        XCTAssertEqual([Byte(0)], false.bytes)
        XCTAssertEqual([Byte.max], true.bytes)
    }

    func testToAndFromBytesInt8()
    {
        let ints = Array<Int8>(arrayLiteral: 0, 1, -1, Int8.max, Int8.min)

        for int in ints
        {
            XCTAssertEqual(sizeof(int.dynamicType), int.bytes.count)
            XCTAssertEqual(try! Int8(bytes: int.bytes), int)
        }
    }

    func testToAndFromBytesInt16()
    {
        let ints = Array<Int16>(arrayLiteral: 0, 1, -1, Int16.max, Int16.min)
        
        for int in ints
        {
            XCTAssertEqual(sizeof(int.dynamicType), int.bytes.count)
            XCTAssertEqual(try! Int16(bytes: int.bytes), int)
        }
    }

    func testToAndFromBytesInt32()
    {
        let ints = Array<Int32>(arrayLiteral: 0, 1, -1, Int32.max, Int32.min)
        
        for int in ints
        {
            XCTAssertEqual(sizeof(int.dynamicType), int.bytes.count)
            XCTAssertEqual(try! Int32(bytes: int.bytes), int)
        }
    }

    func testToAndFromBytesInt64()
    {
        let ints = Array<Int64>(arrayLiteral: 0, 1, -1, Int64.max, Int64.min)
        
        for int in ints
        {
            XCTAssertEqual(sizeof(int.dynamicType), int.bytes.count)
            XCTAssertEqual(try! Int64(bytes: int.bytes), int)
        }
    }

    func testToAndFromBytesInt()
    {
        let ints = Array<Int>(arrayLiteral: 0, 1, -1, Int(Int8.min), Int(Int8.min) - 1, Int(Int16.min), Int(Int16.min) - 1, Int(Int32.min), Int(Int32.min) - 1, Int(Int8.max), Int(Int8.max) - 1, Int(Int16.max), Int(Int16.max) - 1, Int(Int32.max), Int(Int32.max) - 1, Int.max, Int.min)
        
        for int in ints
        {
            XCTAssertEqual(try! Int(bytes: int.bytes), int)
        }
    }

    func testToAndFromBytesUInt8()
    {
        let ints = Array<UInt8>(arrayLiteral: 0, 1, UInt8.max, UInt8.min)
        
        for int in ints
        {
            XCTAssertEqual(sizeof(int.dynamicType), int.bytes.count)
            XCTAssertEqual(try! UInt8(bytes: int.bytes), int)
        }
    }
    
    func testToAndFromBytesUInt16()
    {
        let ints = Array<UInt16>(arrayLiteral: 0, 1, UInt16.max, UInt16.min)
        
        for int in ints
        {
            XCTAssertEqual(sizeof(int.dynamicType), int.bytes.count)
            XCTAssertEqual(try! UInt16(bytes: int.bytes), int)
        }
    }

    func testToAndFromBytesUInt32()
    {
        let ints = Array<UInt32>(arrayLiteral: 0, 1, UInt32.max, UInt32.min)
        
        for int in ints
        {
            XCTAssertEqual(sizeof(int.dynamicType), int.bytes.count)
            XCTAssertEqual(try! UInt32(bytes: int.bytes), int)
        }
    }
    
    func testToAndFromBytesUInt64()
    {
        let ints = Array<UInt64>(arrayLiteral: 0, 1, UInt64.max, UInt64.min)
        
        for int in ints
        {
            XCTAssertEqual(sizeof(int.dynamicType), int.bytes.count)
            XCTAssertEqual(try! UInt64(bytes: int.bytes), int)
        }
    }
    
    func testToAndFromBytesUInt()
    {
        let ints = Array<UInt>(arrayLiteral: 0, 1, UInt.max, UInt.min)
        
        for int in ints
        {
            XCTAssertEqual(try! UInt(bytes: int.bytes), int)
        }
    }
 
    
    func testIntBytesLengths()
    {
        XCTAssertEqual(1, 1.bytes.count)
        XCTAssertEqual(2, (Int(Int8.min) - 1).bytes.count)
        XCTAssertEqual(2, Int(Int8.min).bytes.count)
        XCTAssertEqual(1, (Int(Int8.min) + 1).bytes.count)
        
        XCTAssertEqual(2, (Int(Int8.max) + 1).bytes.count)
        XCTAssertEqual(2, Int(Int8.max).bytes.count)
        XCTAssertEqual(1, (Int(Int8.max) - 1).bytes.count)

        XCTAssertEqual(4, (Int(Int16.min) - 1).bytes.count)
        XCTAssertEqual(4, Int(Int16.min).bytes.count)
        XCTAssertEqual(2, (Int(Int16.min) + 1).bytes.count)
        
        XCTAssertEqual(4, (Int(Int16.max) + 1).bytes.count)
        XCTAssertEqual(4, Int(Int16.max).bytes.count)
        XCTAssertEqual(2, (Int(Int16.max) - 1).bytes.count)
        
        XCTAssertEqual(8, (Int(Int32.min) - 1).bytes.count)
        XCTAssertEqual(8, Int(Int32.min).bytes.count)
        XCTAssertEqual(4, (Int(Int32.min) + 1).bytes.count)
        
        XCTAssertEqual(8, (Int(Int32.max) + 1).bytes.count)
        XCTAssertEqual(8, Int(Int32.max).bytes.count)
        XCTAssertEqual(4, (Int(Int32.max) - 1).bytes.count)
        
    }
}
