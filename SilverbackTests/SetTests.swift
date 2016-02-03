//
//  SetTests.swift
//  Silverback
//
//  Created by Christian Otkjær on 18/09/15.
//  Copyright © 2015 Christian Otkjær. All rights reserved.
//

import XCTest



//MARK: - Hashable

class A : Hashable
{
    var hashValue : Int { return 1 }
}

class B: A { override var hashValue : Int { return 2 } }

class C: A { override var hashValue : Int { return 3 } }


func == (lhs: A, rhs:A) -> Bool
{
    return lhs.hashValue == rhs.hashValue
}

class SetTests: XCTestCase {

    let set0 = Set<Int>()
    let set1 = Set(1)
    let set23 = Set(2, 3)
    let set123 = Set("1","2",nil,"3", "1")

    func testListInit()
    {
        let setset = Set(set0, set1, set23, nil)

        XCTAssertEqual(set1.count, 1)
        XCTAssertEqual(set23.count, 2)
        XCTAssertEqual(set123.count, 3)
        XCTAssertEqual(setset.count, 3)
        
        let randomSet = setset.map{$0.random()}
        
        XCTAssertEqual(randomSet.count, 2)
    }

    func testMap()
    {
        let setABC = Set<A>(A(), B(), A(), C(), nil, C())
        let setBC = Set<A>(B(), C(), B(), C(), B(), C(), B(), C(), B(), C(), nil, C())
        
        XCTAssertEqual(setABC.count, 3)
        XCTAssertEqual(setBC.count, 2)

        XCTAssert(setABC.dynamicType == Set<A>.self)

        XCTAssert(setABC.dynamicType == setBC.dynamicType)

        let mapped = setABC.map({ $0 as? C })

        XCTAssert(mapped.dynamicType == Set<C>.self)

        XCTAssertEqual(mapped.count, 1)

        XCTAssertEqual(setABC.map{ if $0.dynamicType == A.self { return nil } ; return $0 }, setBC)
    }

    func testSift()
    {
        let setABC = Set<A>(A(), B(), A(), C(), nil, C())
        let setBC = Set<A>(B(), C(), B(), C(), B(), C(), B(), C(), B(), C(), nil, C())

        let filteredForC = setABC.sift({$0 is C})
        
        XCTAssert(filteredForC.dynamicType == Set<A>.self)
        
        XCTAssert(filteredForC.dynamicType == setABC.dynamicType)
        
        XCTAssertEqual(filteredForC, setBC.sift({ $0 is C }))
        XCTAssertEqual(setBC.filter({ $0.hashValue == 1 }).count, 0)
    }

    func testRandom()
    {
        let numbers = Array(0..<1000)
        
        let set = Set(numbers)
        
        var array1 : [Int] = []
        var array2 : [Int] = []
        
        for _ in (0..<10)
        {
            if let r1 = set.random()
            {
                array1.append(r1)
            }
            else
            {
                XCTFail("Could not get random")
            }

            if let r2 = set.random()
            {
                array2.append(r2)
            }
            else
            {
                XCTFail("Could not get random")
            }
        }
        
        XCTAssertNotEqual(array1, array2)
        XCTAssertEqual(array1.count, array2.count)
    
    }
    
    func testUnion()
    {
        var noSet : Set<Int>? = Set()
        
        XCTAssertEqual(set1.union(set23), Set(1,2,3))
        XCTAssertEqual(set23.union(set0), set23)
        XCTAssertEqual(set23.union(noSet), set23)
        
        var set = Set<Int>()
        
        set.unionInPlace(noSet)
        
        XCTAssertEqual(set, Set())
        
        set.unionInPlace(set23)
        
        XCTAssertEqual(set, set23)
        
        set.unionInPlace(noSet)
        
        XCTAssertEqual(set, set23)
        
        noSet = nil
        
        set.unionInPlace(noSet)
        
        XCTAssertEqual(set, set23)
        
        XCTAssertEqual(set23.union(noSet), set23)
        
        noSet = Set(4)
        
        set.unionInPlace(noSet)
        
        XCTAssertEqual(set, Set(2,3,4))
        
        XCTAssertEqual(set23.union(noSet), Set(2,3,4))
    }
}
