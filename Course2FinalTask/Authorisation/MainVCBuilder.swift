//
//  File.swift
//  Course2FinalTask
//
//  Created by Rodianov on 05.06.2021.
//  Copyright © 2021 e-Legion. All rights reserved.
//

import UIKit

protocol Builder {
  static func createMainViewController(currentUser: UserStruct?, token: String, networkMode: NetworkMode, dataManager: CoreDataManager)-> UIViewController
}

final class MainVCBuilder: Builder {
  static func createMainViewController(currentUser: UserStruct?, token: String, networkMode: NetworkMode, dataManager: CoreDataManager) -> UIViewController {
    let tabBarController = UITabBarController()
    
    let feedViewController = FeedViewController(token: token)
    let profileViewController = ProfileViewController(user: nil, token: token)
    let newPostViewController = NewPostViewController(token: token)
    
    profileViewController.user = currentUser
    profileViewController.networkMode = networkMode
    profileViewController.dataManager = dataManager
    
    feedViewController.networkMode = networkMode
    feedViewController.dataManager = dataManager
    
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
}
