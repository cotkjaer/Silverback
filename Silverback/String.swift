//
//  String.swift
//  Silverback
//
//  Created by Christian Otkjær on 20/04/15.
//  Copyright (c) 2015 Christian Otkjær. All rights reserved.
//

import Foundation
import UIKit

//MARK: - Lorem Ipsum

public extension String
{
    init(loremIpsumLength: Int)
    {
        self = "Lorem ipsum dolor sit amet donec ut eros sapien. Tortor risus mauris. Viverra donec augue. Tortor rutrum vestibulum donec in dui. Ac consectetuer aliquet est rhoncus rutrum tellus risus curae consequat ut vestibulum sapien risus elit. Tortor eu donec. Morbi urna non ac imperdiet quisque. Etiam viverra lacinia. Faucibus in placerat. Mauris integer at a erat tempor. Aliquet sed id blandit cursus at vero sit amet venenatis mauris elit in interdum id. Auctor ullamcorper enim nulla curabitur quisque nunc quisque ac. Elit justo auctor. Vulputate scelerisque erat quis elit accumsan. Ac ipsum id. Lorem dolor tristique. Porttitor accumsan velit dui justo enim. Sapien maecenas sed. Proin ac nulla sem nisl nec sit fermentum justo at neque volutpat. Pulvinar tincidunt turpis. Ac nam venenatis. Tristique nulla sollicitudin adipiscing neque posuere vestibulum vitae purus. Mi viverra urna arcu purus metus. Ut neque praesent. Lectus morbi integer eros dignissim nec pharetra pulvinar quis."
    }
}

//MARK: - replace

public extension String
{
    mutating func replace(target: String, with optionalReplacement: String?)
    {
        self = self.with(target, replacedBy: optionalReplacement)
    }
    
    @warn_unused_result
    func with(target: String, replacedBy optionalReplacement: String?) -> String
    {
        if let replacement = optionalReplacement
        {
            return self.stringByReplacingOccurrencesOfString(target, withString: replacement)
        }
        
        return self
    }
}

public extension String
{
    init<T : UnsignedIntegerType>(_ v: T, radix: Int, uppercase: Bool = false, paddedToSize: Int)
    {
        self.init(v, radix: radix, uppercase: uppercase)
        
        let padSize = paddedToSize - self.characters.count
        
        if padSize > 0
        {
            self = String(Array<Character>(count: padSize, repeatedValue: "0")) + self
        }
    }
}

public extension String
{
    mutating func trim(forCharactersInSet characterSet: NSCharacterSet = NSCharacterSet.whitespaceAndNewlineCharacterSet())
    {
        self = trimmed(forCharactersInSet: characterSet)
    }
    
    func trimmed(forCharactersInSet characterSet: NSCharacterSet = NSCharacterSet.whitespaceAndNewlineCharacterSet()) -> String
    {
        return stringByTrimmingCharactersInSet(characterSet)
    }
    
    func trimmedAtEnd(forCharactersInSet characterSet: NSCharacterSet = NSCharacterSet.whitespaceAndNewlineCharacterSet()) -> String
    {
        var characters = self.characters
        
        while characterSet.containsCharacter(characters.last)
        {
            characters.removeLast()
        }
        
        return String(characters)
    }
    
    func trimmedAtBegining(forCharactersInSet characterSet: NSCharacterSet = NSCharacterSet.whitespaceAndNewlineCharacterSet()) -> String
    {
        var characters = self.characters
        
        while characterSet.containsCharacter(characters.first)
        {
            characters.removeFirst()
        }
        
        return String(characters)
    }
    
}

public extension String
{
    var uppercaseFirstLetter: String?
        {
        get
        { if !isEmpty
        { return self[0].uppercaseString }; return nil }
    }
}

/// Subscript
public extension String
{
    subscript (i: Int) -> Character
        {
            return self[self.startIndex.advancedBy(i)]
    }
    
    subscript (i: Int) -> String
        {
            return String(self[i] as Character)
    }
    
    subscript (r: Range<Int>) -> String
        {
            let startIndex = self.startIndex.advancedBy(r.startIndex)
            let endIndex = startIndex.advancedBy(r.endIndex - r.startIndex)
            
            return self[Range(start: startIndex, end: endIndex)]
    }
}

public extension String
{
    func reversed() -> String { return String(Array(characters.reverse())) }
}

public extension String
{
    func sizeWithFont(font: UIFont) -> CGSize
    {
        return self.sizeWithAttributes([NSFontAttributeName: font])
    }
}

public extension String
{
    func beginsWith(str: String) -> Bool
    {
        if str.isEmpty
        {
            return true
        }
        
        if let range = rangeOfString(str)
        {
            return range.startIndex == self.startIndex
        }
        
        return false
    }
    
    func endsWith(str: String) -> Bool
    {
        return reversed().beginsWith(str.reversed())
    }
}

