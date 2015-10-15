//
//  BufferTests.swift
//  Silverback
//
//  Created by Christian Otkjær on 08/10/15.
//  Copyright © 2015 Christian Otkjær. All rights reserved.
//

import XCTest

func XCTAssertThrows<T: ErrorType where T: Equatable>(error: T, block: () throws -> ()) {
    do {
        try block()
        XCTFail("No error")
    }
    catch let e as T {
        XCTAssertEqual(e, error)
    }
    catch let e {
        XCTFail("Wrong error \(e)")
    }
}

func XCTAssertNoThrows(block: () throws -> ())
{
    do {
        try block()
    }
    catch let e {
        XCTFail("Got error \(e)")
    }
}


//func XCTAssertEqual<T : Equatable>(@autoclosure expression1: () -> T?, @autoclosure _ expression2: () -> T?, _ message: String = default, file: String = default, line: UInt = default)
//{
//    
//}

class BufferTests: XCTestCase {

    func testBuffer()
    {
        XCTAssertNotNil(Buffer<Int>())
        
        XCTAssertNotNil(Buffer<Buffer<String>>())
    }
    
    func testWrite()
    {
        let buffer = Buffer<String>()

        buffer.write("a")
        
        XCTAssertEqual(1, buffer.available)
        
        buffer.write("b", "c", "d")

        XCTAssertEqual(4, buffer.available)

        buffer.write(["hello", "buffer"])

        XCTAssertEqual(6, buffer.available)
    }
    
    func testEnsureCapacity()
    {
        let buffer = Buffer<Byte>()
        
        buffer.write(Array<Byte>(count: 1000, repeatedValue: 0))
        
        XCTAssertEqual(1000, buffer.available)
    }
    
    func testRead()
    {
        let buffer = Buffer<Bool>()
        
        XCTAssertThrows(BufferError.InsufficientElements(1, 0), block: { try buffer.read() })

        buffer.write(true, false, true, false)
        
        XCTAssertEqual(4, buffer.available)
        
        XCTAssertEqual(true, try! buffer.read())

        XCTAssertThrows(BufferError.InsufficientElements(10, 3), block: { try buffer.read(10) })

        XCTAssertEqual(3, buffer.available)

        XCTAssertEqual([false, true], try! buffer.read(2))

        XCTAssertEqual(1, buffer.available)
    }
    
    func testPeek()
    {
        let buffer = Buffer<Int>()

        XCTAssertThrows(BufferError.InsufficientElements(1, 0), block: { try buffer.peek() })
        
        buffer.write(1)
        
        XCTAssertEqual(1, try! buffer.peek())
        XCTAssertEqual(1, try! buffer.peek())
        XCTAssertEqual(1, try! buffer.peek())

        XCTAssertThrows(BufferError.InsufficientElements(2, 1), block: { try buffer.peek(2) })

        buffer.write(2)
        buffer.write(3)
        
        XCTAssertEqual(3, try! buffer.peek(offset:2))
        XCTAssertEqual(2, try! buffer.peek(offset:1))
        XCTAssertEqual(2, try! buffer.peek(offset:1))

        XCTAssertThrows(BufferError.InsufficientElements(41, 3), block: { try buffer.peek(offset:40) })
    }
    
    func testSkip()
    {
        let buffer = Buffer<Int>()
        
        XCTAssertThrows(BufferError.InsufficientElements(1, 0), block: { try buffer.skip() })
        XCTAssertThrows(BufferError.InsufficientElements(100, 0), block: { try buffer.skip(100) })
        
        buffer.write(1,2,3,4,5)
        
        try! buffer.skip()
        try! buffer.skip()
        
        XCTAssertEqual(3, buffer.available)
        
        XCTAssertThrows(BufferError.InsufficientElements(100, 3), block: { try buffer.skip(100) })

        XCTAssertEqual(3, buffer.available)

        try! buffer.skip(3)

        XCTAssertEqual(0, buffer.available)
        
    }
}
