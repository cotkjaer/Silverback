//
//  NSManagedObjectModel.swift
//  SilverbackFramework
//
//  Created by Christian Otkjær on 22/04/15.
//  Copyright (c) 2015 Christian Otkjær. All rights reserved.
//

import CoreData

extension NSManagedObjectModel
{
    public convenience init?(modelName: String, inBundle bundle: NSBundle)
    {
        if let modelURL = bundle.URLForResource(modelName, withExtension: "momd")
        {
            self.init(contentsOfURL: modelURL)
        }
        else
        {
            self.init()
            
            return nil
        }
    }
    
}
