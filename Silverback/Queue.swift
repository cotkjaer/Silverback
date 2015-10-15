//
//  Queue.swift
//  Silverback
//
//  Created by Christian Otkjær on 08/10/15.
//  Copyright © 2015 Christian Otkjær. All rights reserved.
//

class Queue<Element>
{
    var linkedList = LinkedList<Element>()
    
    func enqueue(element: Element)
    {
        linkedList.append(element)
    }
    
    func dequeue() -> Element?
    {
        return linkedList.popFirst()
    }

}