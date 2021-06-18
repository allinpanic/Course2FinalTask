//
//  File.swift
//  Course2FinalTask
//
//  Created by Rodianov on 05.06.2021.
//  Copyright © 2021 e-Legion. All rights reserved.
//

import UIKit

protocol BuilderProtocol {
  static func createMainViewController(currentUser: UserData?, token: String, networkMode: NetworkMode, dataManager: CoreDataManager)-> UIViewController
  static func createAuthViewController(dataManager: CoreDataManager) -> AuthoriseViewController
  static func createProfileViewController(user: UserData, dataManager: CoreDataManager, networkMode: NetworkMode, token: String) -> ProfileViewController
  static func createUserListViewController(userList: [UserData], dataManager: CoreDataManager, networkMode: NetworkMode, token: String, title: String) -> UsersListViewController
  static func createFilterImageController(image: UIImage, index: Int, networkMode: NetworkMode, token: String) -> FilterImageViewController
}

public final class Builder: BuilderProtocol {
  static func createMainViewController(currentUser: UserData?, token: String, networkMode: NetworkMode, dataManager: CoreDataManager) -> UIViewController {
    let tabBarController = UITabBarController()
    
    let feedViewController = FeedViewController(token: token)
    let feedModel = FeedModel(networkMode: networkMode, token: token)
    feedModel.dataManager = dataManager
    
    let profileViewController = ProfileViewController(user: nil, token: token)
    let profileModel = ProfileModel(networkMode: networkMode, token: token)
    profileModel.dataManager = dataManager
    
    let newPostViewController = NewPostViewController(token: token)
    
    profileViewController.user = currentUser
    profileViewController.networkMode = networkMode
    profileViewController.profileModel = profileModel
    
    feedViewController.networkMode = networkMode
    feedViewController.dataManager = dataManager
    feedViewController.feedModel = feedModel
    
    newPostViewController.networkMode = networkMode
    
    let feedNavigationController = UINavigationController(rootViewController: feedViewController)
    feedViewController.title = "Feed"
    let profileNavigationController = UINavigationController(rootViewController: profileViewController)
    profileNavigationController.title = "Profile"
    let newPostNavigationController = UINavigationController(rootViewController: newPostViewController)
    newPostNavigationController.title = "New"
    
    tabBarController.viewControllers = [feedNavigationController, newPostNavigationController, profileNavigationController]
    feedNavigationController.tabBarItem.image = #imageLiteral(resourceName: "feed")
    newPostNavigationController.tabBarItem.image = #imageLiteral(resourceName: "plus")
    profileNavigationController.tabBarItem.image = #imageLiteral(resourceName: "profile")
    
    return tabBarController
  }
  
  static func createAuthViewController(dataManager: CoreDataManager) -> AuthoriseViewController {
    let authoriseViewController = AuthoriseViewController()
    let authModel = AuthoriseModel()
    authModel.dataManager = dataManager
    authoriseViewController.authModel = authModel
    
    return authoriseViewController
  }
  
  static func createProfileViewController(user: UserData, dataManager: CoreDataManager, networkMode: NetworkMode, token: String) -> ProfileViewController {
    let profileViewController = ProfileViewController(user: user, token: token)
    let profileModel = ProfileModel(networkMode: networkMode, token: token)
    profileModel.dataManager = dataManager

    profileViewController.networkMode = networkMode
    profileViewController.profileModel = profileModel
    
    return profileViewController
  }
  
  static func createUserListViewController(userList: [UserData], dataManager: CoreDataManager, networkMode: NetworkMode, token: String, title: String) -> UsersListViewController {
    let userListController = UsersListViewController(userList: userList,
                                                     title: title,
                                                     token: token,
                                                     networkMode: networkMode)
    userListController.dataManager = dataManager
    
    return userListController
  }
  
  static func createFilterImageController(image: UIImage, index: Int, networkMode: NetworkMode, token: String) -> FilterImageViewController {
    let filterImageViewController = FilterImageViewController(image: image, index: index)
    let filterImageModel = FilterImageModel()
    filterImageViewController.token = token
    filterImageViewController.networkMode = networkMode
    filterImageViewController.filterImageModel = filterImageModel
    
    return filterImageViewController
  }
  
  static func createAddDescriptionViewController(image: UIImage?, networkMode: NetworkMode, token: String) -> AddDescriptionViewController {
    let addDescriptionViewController = AddDescriptionViewController(filteredImage: image)
    let addDescModel = AddDescriptionModel(networkMode: networkMode, token: token)
    addDescriptionViewController.addDescModel = addDescModel
    
    return addDescriptionViewController
  }
}
