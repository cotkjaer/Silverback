//
//  Hashable.swift
//  Silverback
//
//  Created by Christian Otkjær on 12/10/15.
//  Copyright © 2015 Christian Otkjær. All rights reserved.
//

//MARK: - ContainedIn

extension Hashable
{
    func containedIn<S : SequenceType where S.Generator.Element == Self>(sequence: S?) -> Bool
    {
        return sequence?.contains(self) == true
    }
}
