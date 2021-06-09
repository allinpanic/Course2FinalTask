//
//  CoreDataManager.swift
//  Course2FinalTask
//
//  Created by Rodianov on 24.03.2021.
//  Copyright © 2021 e-Legion. All rights reserved.
//

import CoreData
import UIKit

final class CoreDataManager {
  private let modelName: String
  
  init(modelName: String) {
    self.modelName = modelName
  }
  
  private lazy var persistentContainer: NSPersistentContainer = {
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
  
  func createObject<T: NSManagedObject>(from entity: T.Type, context: NSManagedObjectContext) -> T {
    let object = NSEntityDescription.insertNewObject(forEntityName: String(describing: entity), into: context) as! T
    
    return object
  }
  
  func save(context: NSManagedObjectContext) {
    if context.hasChanges {
      do {
        try context.save()
      } catch {
        let nserror = error as NSError
        fatalError("unresolved error \(nserror), \(nserror.userInfo)")
      }
    }
  }
  
  func delete(object: NSManagedObject, context: NSManagedObjectContext) {
    context.delete(object)
    save(context: context)
  }
  
  func deleteAll<T: NSManagedObject>(entity: T.Type) {
    let entityName = String(describing: entity)
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
    let batchRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
    
    do {
      try bgContext.execute(batchRequest)
    } catch {
      fatalError("Failed to execute request: \(error)")
    }
  }
  
  func fetchData<T: NSManagedObject> (for entity: T.Type, predicate: NSPredicate? = nil, sortDescriptor: NSSortDescriptor?) -> [T] {
    
    let context = getViewContext()
    
    let request: NSFetchRequest<T>
    var fetchedResult = [T]()
    
    let entityName = String(describing: entity)
    request = NSFetchRequest(entityName: entityName)
    
    request.predicate = predicate
    
    if let sortDescriptor = sortDescriptor {
      request.sortDescriptors = [sortDescriptor]
    }
    
    do {
      fetchedResult = try context.fetch(request)
    } catch {
      debugPrint("could not fetch: \(error.localizedDescription)")
    }
    
    return fetchedResult
  }
  
  func savePost(post: PostData, likesCount: Int? = nil) {
    bgContext.performAndWait {
      let postObject = createObject(from: Post.self, context: bgContext)
      
      postObject.id = post.id
      postObject.author = post.author
      postObject.authorUserName = post.authorUsername
      postObject.createdTime = post.createdTime
      postObject.currentUserLikesThisPost = post.currentUserLikesThisPost
      postObject.descript = post.description
      
      guard let avatarURL = URL(string: post.authorAvatar),
            let postImageURL = URL(string: post.image) else {return}
      
      guard let authorAvatarData = try? Data(contentsOf: avatarURL),
            let imageData = try? Data(contentsOf: postImageURL) else {return}
      
      postObject.image = imageData
      postObject.authorAvatar = authorAvatarData
      
      guard let likesCount = likesCount else {return}
      postObject.likedByCount = Int16(likesCount)
      
      save(context: bgContext)
    }
  }
  
  func saveCurrentUser(currUser: UserData) {
    bgContext.performAndWait {
      
      let userObject = createObject(from: User.self, context: bgContext)
      userObject.id = currUser.id
      userObject.currentUserFollowsThisUser = currUser.currentUserFollowsThisUser
      userObject.currentUserIsFollowedByThisUser = currUser.currentUserIsFollowedByThisUser
      userObject.followedByCount = Int16(currUser.followedByCount)
      userObject.followsCount = Int16(currUser.followsCount)
      userObject.fullName = currUser.fullName
      userObject.userName = currUser.username
      
      guard let avatarURL = URL(string: currUser.avatar),
            let avatarData = try? Data(contentsOf: avatarURL) else {return}
      
      userObject.avatar = avatarData
      
      save(context: bgContext)
    }
  }
}

