//
//  CoreDataManager.swift
//  Course2FinalTask
//
//  Created by Rodianov on 24.03.2021.
//  Copyright © 2021 e-Legion. All rights reserved.
//

import CoreData

final class CoreDataManager {
  private let modelName: String
  
  init(modelName: String) {
    self.modelName = modelName
  }
  
  lazy var persistentContainer: NSPersistentContainer = {
    let container = NSPersistentContainer(name: modelName)
    
    container.loadPersistentStores { (storeDescriptor, error) in
      if let error = error as NSError? {
        fatalError("Unresolved error \(error), \(error.userInfo)")
      }
    }
    
    return container
  }()
  
  lazy var bgContext: NSManagedObjectContext = {
    let context = persistentContainer.newBackgroundContext()
    context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    return context
  }()
  
  func getViewContext() -> NSManagedObjectContext {
    return persistentContainer.viewContext
  }
  
//  func getBackgroundContext() -> NSManagedObjectContext {
//    return persistentContainer.newBackgroundContext()
//  }
  func createObject<T: NSManagedObject>(from entity: T.Type, context: NSManagedObjectContext) -> T {
    let object = NSEntityDescription.insertNewObject(forEntityName: String(describing: entity), into: context) as! T
    
    return object
  }
  
  func save(context: NSManagedObjectContext) {
    if context.hasChanges {
      do {
        try context.save()
        print("context saved")
      } catch {
        let nserror = error as NSError
        fatalError("unresolved error \(nserror), \(nserror.userInfo)")
      }
    }
  }
  
//  func delete(object: NSManagedObject) {
//    let context = getViewContext()
//    context.delete(object)
//    save(context: context)
//  }
  
  func fetchData<T: NSManagedObject> (for entity: T.Type, predicate: NSCompoundPredicate? = nil) -> [T] {
    
    let context = getViewContext()
    
    let request: NSFetchRequest<T>
    var fetchedResult = [T]()
    
    let entityName = String(describing: entity)
    request = NSFetchRequest(entityName: entityName)
    
    //  let dateDescriptor = NSSortDescriptor(key: "date", ascending: true, selector: #selector(NSString.localizedStandardCompare(_:)))
    //
    
    request.predicate = predicate
//    request.sortDescriptors = [dateSortDescriptor]
    
    do {
      fetchedResult = try context.fetch(request)
    } catch {
      debugPrint("could not fetch: \(error.localizedDescription)")
    }
    
    return fetchedResult
  }
  

  
  
  
}

