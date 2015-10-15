//
//  ByteBufferTests.swift
//  Silverback
//
//  Created by Christian Otkjær on 08/10/15.
//  Copyright © 2015 Christian Otkjær. All rights reserved.
//

import XCTest

class ByteBufferTests: XCTestCase {

    func testByteBuffer()
    {
        XCTAssertNotNil(ByteBuffer())
    }
    
    func testWriteAndRead()
    {
        let buffer = ByteBuffer()
        
        buffer.write(true)
        buffer.write(false)
        
        buffer.write("hello buffer")
        buffer.write(-1)
        
        XCTAssertNoThrows({ try buffer.read() as Bool })
        XCTAssertNoThrows({ try buffer.read() as Bool })
        XCTAssertNoThrows({ try buffer.read() as String })
        XCTAssertNoThrows({ try buffer.read() as Int })
        
        buffer.write(true)
        buffer.write(false)
        
        buffer.write("hello buffer")
        buffer.write(-1)
        
        XCTAssertEqual(true, try! buffer.read() as Bool)
        XCTAssertEqual(false, try! buffer.read() as Bool)
        XCTAssertEqual("hello buffer", try! buffer.read() as String)
        XCTAssertEqual(-1, try! buffer.read() as Int )
    }
    
    func testWriteAndReadIntsOfVaryingSizes()
    {
        let buffer = ByteBuffer()

        let ints = Array<Int>(arrayLiteral: 0, 1, -1, Int(Int8.min), Int(Int8.min) - 1, Int(Int16.min), Int(Int16.min) - 1, Int(Int32.min), Int(Int32.min) - 1, Int(Int8.max), Int(Int8.max) - 1, Int(Int16.max), Int(Int16.max) - 1, Int(Int32.max), Int(Int32.max) - 1, Int.max, Int.min)
        
        for int in ints
        {
            buffer.write(int)
            buffer.write(int)

            XCTAssertNoThrows({ try buffer.read() as Int })
            XCTAssertEqual(int, try! buffer.read() as Int )
        }
    }

    func testReadAndWriteOptionals()
    {
        let buffer = ByteBuffer()
        
        let arrays:  Array<String?> = ["hello buffer", nil, "", "I love 🐫s"]
        
        for a in arrays
        {
            buffer.writeOptional(a)
            buffer.writeOptional(a)
            
            XCTAssertNoThrows({ try buffer.readOptional() as String? })
            XCTAssertEqual(a, try! buffer.readOptional() as String? )
        }
    }
    
    func testReadAndWriteArrays()
    {
        let buffer = ByteBuffer()

        let arrays: Array<Array<Int>> = [[], [1,2,3,4], [2,Int(Int32.min) - 1,2,2,Int.min], Array(1...1000)]
        
        for a in arrays
        {
            buffer.write(a)
            buffer.write(a)
        
            XCTAssertNoThrows({ try buffer.read() as [Int] })
            XCTAssertEqual(a, try! buffer.read() as [Int] )
            XCTAssertEqual(0, buffer.available)
        }
    }

    func testReadAndWriteSets()
    {
        let buffer = ByteBuffer()
        
        let sets: Array<Set<String>> = [["Hello", "Hello"], [], ["Hello", "buffer"]]
        
        for set in sets
        {
            buffer.write(set)
            
            var readSet = Set("false")
            
            XCTAssertNoThrows({ readSet = try buffer.read(); XCTAssertEqual(set, readSet) })
            XCTAssertEqual(0, buffer.available)
        }
    }

    func testByteBufferable()
    {
        let buffer = ByteBuffer()

        XCTAssert(Byte(1) is ByteBufferable)
        
        buffer.write(Byte(12))
        
        XCTAssertEqual(1, buffer.available)
        
        var b : Byte = 0
        
        XCTAssertNoThrows({ b = try Byte(buffer: buffer); XCTAssertEqual(Byte(12), b) })
        
    }

}
