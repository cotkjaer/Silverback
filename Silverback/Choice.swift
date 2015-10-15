//
//  Choice.swift
//  Silverback
//
//  Created by Christian Otkjær on 12/10/15.
//  Copyright © 2015 Christian Otkjær. All rights reserved.
//

class GenericChoice<Option:Hashable where Option:ByteBufferable> : ByteBufferable, CustomDebugStringConvertible
{
    private(set) var options : Set<Option> = Set()
    private(set) var chosenOption : Option? = nil
    private(set) var defaultOption : Option? = nil
    private(set) var forcedOption : Option? = nil

    private(set) var committed : Bool = false
    
    // MARK: - Derived
    
    var option : Option? { return forcedOption ?? chosenOption ?? defaultOption }
    
    var chosen : Bool { return chosenOption != nil }
    var forced : Bool { return forcedOption != nil }
    
    // MARK: - Initializer
    
    required init(options: Set<Option> = Set(), defaultOption: Option? = nil, chosenOption: Option? = nil, forcedOption: Option? = nil, committed: Bool = false)
    {
        self.options = options
        self.defaultOption = options.find{ $0 == defaultOption }
        self.chosenOption = options.find{ $0 == chosenOption }
        self.forcedOption = forcedOption
        self.committed = committed
    }
    
    // MARK: - update default
    
    func setDefaultOption(optionalOption: Option?) -> Bool
    {
        if let newDefaultOption = options.find({ $0 == optionalOption })
        {
            defaultOption = newDefaultOption
        }
        else if !options.contains({ $0 == defaultOption })
        {
            defaultOption = nil
        }
        
        return false
    }
    
    // MARK: - Update options
    
    func updateOptions<S : SequenceType where S.Generator.Element == Option>(nOptions: S, defaultOption: Option? = nil) -> Bool
    {
        let newOptions = Set(nOptions)
        
        if newOptions != self.options
        {
            self.options = newOptions
            
            if let newDefaultOption = newOptions.find({ defaultOption == $0 })
            {
                self.defaultOption = newDefaultOption
            }
            else if !newOptions.contains(self.defaultOption)
            {
                self.defaultOption = nil
            }
            
            if chosenOption?.containedIn(options) == false
            {
                return unchooseOption(chosenOption)
            }
            
            return true
        }
        
        return false
    }
    
    // MARK: - Add/Remove
    
    func addOptions<S : SequenceType where S.Generator.Element == Option>(options: S) -> Bool
    {
        return updateOptions(self.options.union(options))
    }
    
    func addOptions(options: Option...) -> Bool
    {
        return addOptions(options)
    }
    
    func removeOptions<S : SequenceType where S.Generator.Element == Option>(options: S) -> Bool
    {
        return updateOptions(self.options.subtract(options))
    }
    
    func removeOptions(options: Option...) -> Bool
    {
        return removeOptions(options)
    }
    
    // MARK: - choose
    
    func chooseOption(option: Option) -> Bool
    {
        if !committed && self.option != option && options.contains(option)
        {
            chosenOption = option
            
            return true
        }
        
        return false
    }
    
    func chooseOption(optionalOption: Option?) -> Bool
    {
        if !committed && chosenOption != optionalOption && ( options.contains(optionalOption) || (optionalOption == nil && defaultOption == nil))
        {
            chosenOption = optionalOption
            
            return true
        }
        
        return false
    }
    
    // MARK: - Unchoose
    
    func unchooseOptions<S : SequenceType where S.Generator.Element == Option>(options: S) -> Bool
    {
        if options.contains({ $0 == chosenOption })
        {
            chosenOption = defaultOption
            return true
        }
        
        return false
    }
    
    func unchooseOptions(options: Option...) -> Bool
    {
        return unchooseOptions(options)
    }

    func unchooseOption(optionalOption: Option?) -> Bool
    {
        if optionalOption == chosenOption
        {
//            if optionalOption != defaultOption
//            {
                return chooseOption(defaultOption)
//            }
//            else if let otherOption = options.filter({ $0 != defaultOption && $0 != optionalOption }).random()
//            {
//                return chooseOption(otherOption)
//            }
        }
        
        return false
    }
    
    // MARK: - Force Option
    
    func forceOption(option: Option) -> Bool
    {
        if option != forcedOption
        {
            forcedOption = option
            return true
        }
        
        return false
    }
    
    // MARK: - committed
    
    func commit() -> Bool
    {
        if option != nil && !committed
        {
            committed = true
            return true
        }
        
        return false
    }
    
    func uncommit() -> Bool
    {
        if committed
        {
            committed = false
            return true
        }
        
        return false
    }
    
    // MARK: - ByteBufferable
    
    required init(buffer: ByteBuffer) throws
    {
        do
        {
            committed = try buffer.read()
            forcedOption = try buffer.readOptional()
            options = try buffer.read()//Set<Option>(buffer)
            defaultOption = try buffer.readOptional()
            chosenOption = try buffer.readOptional()
        }
        catch let e
        {
            throw e
        }
    }
    
    func write(buffer: ByteBuffer)
    {
        buffer.write(committed)
        buffer.writeOptional(forcedOption)
        buffer.write(options)
        buffer.writeOptional(defaultOption)
        buffer.writeOptional(chosenOption)
    }

    // MARK: - CustomDebugStringConvertible

    var debugDescription : String {
        
        let optionsText = options.map{ option -> String in
        
            var text = "\(option)"
        
            if option == chosenOption { text = "[\(text)]" }
            
            if option == forcedOption { text = ">\(text)<" }
            
            return text
        }.joinWithSeparator(" ")
        
        return (committed ? "Committed ": "") + "Choice: " + optionsText
    }
}


