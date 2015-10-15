//
//  DiscreteValue.swift
//  Silverback
//
//  Created by Christian Otkjær on 14/10/15.
//  Copyright © 2015 Christian Otkjær. All rights reserved.
//

class DiscreteValue<Value:Hashable where Value:ByteBufferable> : ByteBufferable, CustomDebugStringConvertible
{
    private(set) var values : Set<Value> = Set()
    private(set) var chosenValue : Value? = nil
    private(set) var defaultValue : Value
    private(set) var forcedValue : Value? = nil
    
    private(set) var committed : Bool = false
    
    // MARK: - Derived
    
    var value : Value { return forcedValue ?? chosenValue ?? defaultValue }
    
    var chosen : Bool { return chosenValue != nil }
    var forced : Bool { return forcedValue != nil }
    
    // MARK: - Initializer
    
    required init?(values: Set<Value> = Set(), defaultValue: Value? = nil, chosenValue: Value? = nil, forcedValue: Value? = nil, committed: Bool = false)
    {
        guard !values.isEmpty else { return nil }
        
        self.values = values
        
        if let realDefaultValue = values.find({ $0 == defaultValue })
        {
            self.defaultValue = realDefaultValue
        }
        else
        {
            return nil
        }
        
        self.chosenValue = values.find{ $0 == chosenValue }
        self.forcedValue = values.find{ $0 == forcedValue }
        self.committed = committed
    }
    
    // MARK: - Update values
    
    func updateValues<S : SequenceType where S.Generator.Element == Value>(nValues: S) -> Bool
    {
        let newValues = Set(nValues)

        guard !newValues.isEmpty else { return false }
        
        if newValues != self.values
        {
            self.values = newValues
            
            if !defaultValue.containedIn(values)
            {
                defaultValue = values.first!
            }
            
            if chosenValue?.containedIn(values) == false
            {
                return unchooseValue(chosenValue)
            }
            
            return true
        }
        
        return false
    }
    
    // MARK: - Add/Remove
    
    func addValues<S : SequenceType where S.Generator.Element == Value>(values: S) -> Bool
    {
        return updateValues(self.values.union(values))
    }
    
    func addValues(values: Value...) -> Bool
    {
        return addValues(values)
    }
    
    func removeValues<S : SequenceType where S.Generator.Element == Value>(values: S) -> Bool
    {
        return updateValues(self.values.subtract(values))
    }
    
    func removeValues(values: Value...) -> Bool
    {
        return removeValues(values)
    }
    
    // MARK: - choose
    
    func chooseValue(value: Value) -> Bool
    {
        if !committed && self.value != value && values.contains(value)
        {
            chosenValue = value
            
            return true
        }
        
        return false
    }
    
    func chooseValue(optionalValue: Value?) -> Bool
    {
        if let value = optionalValue
        {
            return chooseValue(value)
        }
        
        return false
    }
    
    // MARK: - Unchoose
    
    func unchooseValues<S : SequenceType where S.Generator.Element == Value>(values: S) -> Bool
    {
        if values.contains({ $0 == chosenValue })
        {
            let valueBefore = value
            
            chosenValue = nil
            
            return valueBefore != value
        }
        
        return false
    }
    
    func unchooseValues(values: Value...) -> Bool
    {
        return unchooseValues(values)
    }

    
    func unchooseValue(value: Value) -> Bool
    {
        return unchooseValues([value])
    }
    
    func unchooseValue() -> Bool
    {
        return unchooseValue(value)
    }
    
    func unchooseValue(optionalValue: Value?) -> Bool
    {
        if let value = optionalValue
        {
            return unchooseValue(value)
        }
        
        return false
    }
    
    // MARK: - Force Value
    
    func forceValue(value: Value) -> Bool
    {
        if value != forcedValue
        {
            let valueBefore = value

            forcedValue = value
            
            return valueBefore != value
        }
        
        return false
    }
    
    // MARK: - committed
    
    func commit() -> Bool
    {
        if !committed
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
            forcedValue = try buffer.readOptional()
            values = try buffer.read()//Set<Value>(buffer)
            defaultValue = try buffer.read()
            chosenValue = try buffer.readOptional()
        }
        catch let e
        {
            throw e
        }
    }
    
    func write(buffer: ByteBuffer)
    {
        buffer.write(committed)
        buffer.writeOptional(forcedValue)
        buffer.write(values)
        buffer.write(defaultValue)
        buffer.writeOptional(chosenValue)
    }
    
    // MARK: - CustomDebugStringConvertible
    
    var debugDescription : String {
        
        let valuesText = values.map{ value -> String in
            
            var text = "\(value)"
            
            if value == chosenValue { text = "[\(text)]" }
            
            if value == forcedValue { text = ">\(text)<" }
            
            return text
            }.joinWithSeparator(" ")
        
        return (committed ? "Committed ": "") + "Choice: " + valuesText
    }
}
