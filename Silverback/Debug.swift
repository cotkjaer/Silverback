//
//  Debug.swift
//  Silverback
//
//  Created by Christian Otkjær on 16/09/15.
//  Copyright © 2015 Christian Otkjær. All rights reserved.
//

import UIKit

public func debugPrintIf<T>(condition: Bool?,  value: T, terminator: String = "\n")
{
    if condition == true { debugPrint(value, terminator:terminator) }
}

public func isSimulator() -> Bool { return UIDevice.currentDevice().name.hasSuffix("Simulator") }
