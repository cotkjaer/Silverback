//
//  NSFetchedResultsController.swift
//  SilverbackFramework
//
//  Created by Christian Otkjær on 21/04/15.
//  Copyright (c) 2015 Christian Otkjær. All rights reserved.
//

import CoreData

extension NSFetchedResultsController
{
    public var sectionInfos : [NSFetchedResultsSectionInfo] { return self.sections ?? [] }
    
    public var numberOfSections : Int
    {
        return sectionInfos.count
    }

    public func numberOfItemsInSection(section: Int) -> Int
    {
        return numberOfObjectsInSection(section)
    }
    
    public func numberOfRowsInSection(section: Int) -> Int
    {
        return numberOfObjectsInSection(section)
    }
    
    public func numberOfObjectsInSection(section: Int) -> Int
    {
        return sectionInfoForSection(section)?.numberOfObjects ?? 0
    }
    
    public func sectionInfoForSection(section: Int) -> NSFetchedResultsSectionInfo?
    {
        return sectionInfos.get(section)
    }
}