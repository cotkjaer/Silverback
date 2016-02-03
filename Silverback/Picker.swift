//
//  Picker.swift
//  Silverback
//
//  Created by Christian Otkjær on 27/01/16.
//  Copyright © 2016 Christian Otkjær. All rights reserved.
//

import Foundation

public protocol PickerDelegate
{
    func picker(picker: Picker, didPick item: Any?)
}

public protocol Picker: class
{
    var pickedObject: Any? { get set }
    
    var pickerDelegate : PickerDelegate? { get set }
}

