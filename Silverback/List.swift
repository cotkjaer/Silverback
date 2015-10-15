//
//  List.swift
//  Silverback
//
//  Created by Christian Otkjær on 08/10/15.
//  Copyright © 2015 Christian Otkjær. All rights reserved.
//

private class Link<E>
{
    var element: E

    var next: Link<E>?
    var previous: Link<E>?

    init(element: E)
    {
        self.element = element
    }
    
    func append(element: E) -> Link<E>
    {
        let link = Link(element: element)
        
        self.next = link
        link.previous = self
        
        return link
    }
    
    func prepend(element: E) -> Link<E>
    {
        let link = Link(element: element)
        
        self.previous = link
        link.next = self
        
        return link
    }
}

struct LinkedList<Element>
{
    private var array = Array<Element>()
    
    private var head: Link<Element>?
    private var tail: Link<Element>?
    
    var isEmpty : Bool { return head == nil && tail == nil }
    
    mutating func popFirst() -> Element?
    {
        if let element = head?.element
        {
            head = head?.next
            
            if head == nil
            {
                tail = nil
            }
            
            return element
        }
        
        return nil
    }
    
    mutating func popLast() -> Element?
    {
        if let element = tail?.element
        {
            tail = tail?.previous
            
            if tail == nil
            {
                head = nil
            }
            
            return element
        }
        
        return nil
    }
    
    
    mutating func append(element: Element)
    {
        if isEmpty
        {
            let link = Link(element: element)
            
            head = link
            tail = link
        }
        else
        {
            tail = tail?.append(element)
        }
    }
    
    mutating func prepend(element: Element)
    {
        if isEmpty
        {
            let link = Link(element: element)
            
            head = link
            tail = link
        }
        else
        {
            head = head?.prepend(element)
        }
    }
}

