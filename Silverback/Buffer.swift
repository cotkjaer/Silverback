//
//  Buffer.swift
//  Silverback
//
//  Created by Christian Otkjær on 08/10/15.
//  Copyright © 2015 Christian Otkjær. All rights reserved.
//

private struct Slot<Element> : CustomDebugStringConvertible
{
    let element: Element?
    
    var debugDescription: String {
        
        if let e = element
        {
            return "\(e)"
        }
        
        return "<empty>"
    }
}

enum BufferError : ErrorType, Equatable
{
    case InsufficientElements(Int, Int)
}

// MARK: - Equatable

func == (lhs: BufferError, rhs:BufferError) -> Bool
{
    switch (lhs, rhs)
    {
    case let (.InsufficientElements(w1, g1), .InsufficientElements(w2, g2)):
        return w1 == w2 && g1 == g2
    }
}

class Buffer<Element> : CustomDebugStringConvertible
{
    private var slots = Array<Slot<Element>>(count: 64, repeatedValue: Slot(element: nil))
    
    private var readPosition = 0
    private var writePosition = 0
    
    var available: Int { return writePosition - readPosition }
    
    var isEmpty: Bool { return available < 1 }
    
    private func ensureCapacity(count: Int)
    {
        let arraySize = slots.count
        
        if arraySize > writePosition + count
        {
            return
        }
        
        if readPosition > arraySize / 2
        {
            for var i = readPosition; i < writePosition; i++
            {
                slots[i - readPosition] = slots[i]
            }
            
            writePosition -= readPosition
            readPosition = 0
        }
        
        slots += Array<Slot<Element>>(count: max(arraySize, count), repeatedValue: Slot(element: nil))
    }
    
    // MARK: - public
    
    func peek(offset offset: Int = 0) throws -> Element
    {
        return try peek(1, offset: offset)[0]
    }
    
    func peek(count: Int, offset: Int = 0) throws -> [Element]
    {
        if offset + count > available { throw BufferError.InsufficientElements(offset + count, available) }
        
        return (0..<count).flatMap { slots[readPosition + offset + $0].element }
    }
    
    func skip(count: Int = 1) throws
    {
        if count > available { throw BufferError.InsufficientElements(count, available) }
        
        readPosition += count
        
        if readPosition == writePosition
        {
            readPosition = 0
            writePosition = 0
        }
    }
    
    func read() throws -> Element
    {
        let res = try peek()
        
        if ++readPosition == writePosition
        {
            readPosition = 0
            writePosition = 0
        }
        
        return res
    }
    
    func read(count: Int) throws -> [Element]
    {
        if count > available { throw BufferError.InsufficientElements(count, available) }
        
        return try (0..<count).flatMap { _ in try read() }
    }
    
    func write(elements: [Element])
    {
        ensureCapacity(elements.count)
        
        elements.forEach{ slots[writePosition++] = Slot(element: $0) }
    }
    
    func write(elements: Element...)
    {
        write(elements)
    }
    
    // MARK: - Elements
    
    var elements : [Element] { if isEmpty { return [] } else { return slots[readPosition..<writePosition].flatMap{$0.element} } }
    
    // MARK: - CustomDebugStringConvertible
    
    var debugDescription : String { return "\(available) : \(elements)" }
}
