//
//  NSManagedObjectContext.swift
//  SilverbackFramework
//
//  Created by Christian Otkjær on 21/04/15.
//  Copyright (c) 2015 Christian Otkjær. All rights reserved.
//

import CoreData

extension NSManagedObjectContext
{
    public convenience init(modelName: String, inBundle: NSBundle? = nil, storeType: NSPersistentStoreType = .SQLite) throws
    {
        let coordinator = try NSPersistentStoreCoordinator(modelName:modelName, inBundle: inBundle ?? NSBundle.mainBundle(), storeType: storeType)
        
        self.init(persistentStoreCoordinator: coordinator)
    }
    
    public convenience init(
        persistentStoreCoordinator: NSPersistentStoreCoordinator,
        concurrencyType: NSManagedObjectContextConcurrencyType = .MainQueueConcurrencyType)
    {
        self.init(concurrencyType: concurrencyType)
        self.persistentStoreCoordinator = persistentStoreCoordinator
    }
    
    public convenience init(
        parentContext: NSManagedObjectContext,
        concurrencyType: NSManagedObjectContextConcurrencyType? = nil)
    {
        let ct = concurrencyType ?? parentContext.concurrencyType
        
        self.init(concurrencyType: ct)
        self.parentContext = parentContext
    }
    
    public func childContext(concurrencyType: NSManagedObjectContextConcurrencyType = .MainQueueConcurrencyType) -> NSManagedObjectContext
    {
        return NSManagedObjectContext(parentContext: self, concurrencyType: concurrencyType)
    }
    
    public func objectInChildContext<T: NSManagedObject>(object: T, concurrencyType: NSManagedObjectContextConcurrencyType? = nil) -> (NSManagedObjectContext, T)?
    {
        if let /*registeredObject*/ _ = objectRegisteredForID(object.objectID)
        {
            let context = NSManagedObjectContext(parentContext: self, concurrencyType: concurrencyType)
            
            if let childObject = context.objectWithID(object.objectID) as? T
            {
                return (context, childObject)
            }
        }
        
        return nil
    }
    
    private func entityDescriptionFor<T: NSManagedObject>(type: T.Type) -> NSEntityDescription?
    {
        if let entityDescription = NSEntityDescription.entityForName(type.baseName(), inManagedObjectContext: self)
        {
            return entityDescription
        }
        
        return nil
    }
    
    public func insert<T: NSManagedObject>(type: T.Type) -> T?
    {
        if let entityDescription = self.entityDescriptionFor(type)
        {
            return T(entity: entityDescription, insertIntoManagedObjectContext: self)
        }
        
        return nil
    }
    
    private func executeFetchRequestLogErrors(request: NSFetchRequest) -> [AnyObject]?
    {
        do
        {
            return try self.executeFetchRequest(request)
        }
        catch let error
        {
            debugPrint("Error: \(error)")
            
        }
        
        return nil
    }
    
    public func fetch<T: NSManagedObject>(type: T.Type, predicate:NSPredicate? = nil) -> [T]?
    {
        let fetchRequest = NSFetchRequest(entityName: type.baseName())
        
        fetchRequest.predicate = predicate ?? NSPredicate(value: true)
        
        if let result = self.executeFetchRequestLogErrors(fetchRequest) as? [T]
        {
            return result
        }
        
        return nil
    }
    
    
    /// returns all entities with the given type
    public func all<T: NSManagedObject>(type: T.Type) -> [T]?
    {
        return fetch(T.self, predicate: NSPredicate(value: true))
    }
    
    /// counts all entities with the given type
    public func count<T: NSManagedObject>(type: T.Type, predicate:NSPredicate? = nil) -> Int
    {
        let fetchRequest = NSFetchRequest(entityName: type.baseName())
        
        fetchRequest.predicate = predicate ?? NSPredicate(value: true)
        
        var error: NSError? = nil
        
        let count = countForFetchRequest(fetchRequest, error: &error)
        
        if let e = error
        {
            debugPrint("Error: \(e)")
        }
        
        return count
    }
    
    public func any<T: NSManagedObject>(type: T.Type, predicate: NSPredicate? = nil) -> T?
    {
        let fetchRequest = NSFetchRequest()
        fetchRequest.entity = entityDescriptionFor(type)
        fetchRequest.predicate = predicate //NSPredicate(value: true)
        fetchRequest.fetchLimit = 1
        
        return executeFetchRequestLogErrors(fetchRequest)?.last as? T
    }
    
    public func first<T: NSManagedObject>(type: T.Type, sortDescriptors: [NSSortDescriptor], predicate:NSPredicate? = nil) -> T?
    {
        let fetchRequest = NSFetchRequest()
        
        fetchRequest.entity = entityDescriptionFor(type)
        fetchRequest.predicate = predicate // ?? NSPredicate(value: true)
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.fetchLimit = 1
        
        return executeFetchRequestLogErrors(fetchRequest)?.first as? T
    }
}


// MARK: - Save

extension NSManagedObjectContext
{
    public func saveSafely() -> (Bool, NSError?)
    {
        if hasChanges
        {
            do
            {
                try save()
                return (true, nil)
            }
            catch let error as NSError
            {
                return (false, error)
            }
        }
        
        return (false, nil)
    }
    
    public func saveWithAlert() -> Bool
    {
        let (saved, error) = saveSafely()
        
        error?.presentAsAlert()
        
        return saved
    }


}
