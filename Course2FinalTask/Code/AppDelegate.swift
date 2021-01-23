//
//  AppDelegate.swift
//  Course2FinalTask
//
//  Copyright © 2018 e-Legion. All rights reserved.
//

import UIKit
import DataProvider

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    
    window = UIWindow(frame: UIScreen.main.bounds)
    
//    let tabBarController = UITabBarController()
//
//    let feedViewController = FeedViewController()
//    let profileViewController = ProfileViewController(user: nil)
//    let newPostViewController = NewPostViewController()
    
    
    let authoriseViewController = AuthoriseViewController()
    
//    DataProviders.shared.usersDataProvider.currentUser(queue: DispatchQueue.global(qos: .userInteractive)){
//      user in
//      if let currentUser = user {
//        DispatchQueue.main.async {
//          profileViewController.user = currentUser
//        }
//      } else {
//        DispatchQueue.main.async {
//          let alert = UIAlertController(title: "Unknown error", message: "Please, try again later", preferredStyle: .alert)
//          alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
//          profileViewController.present(alert, animated: true, completion: nil)
//        }
//      }
//    }
//    
//    let feedNavigationController = UINavigationController(rootViewController: feedViewController)
//    feedViewController.title = "Feed"
//    let profileNavigationController = UINavigationController(rootViewController: profileViewController)
//    profileNavigationController.title = "Profile"
//    let newPostNavigationController = UINavigationController(rootViewController: newPostViewController)
//    newPostNavigationController.title = "New"
//    
//    tabBarController.viewControllers = [feedNavigationController, newPostNavigationController, profileNavigationController]
//    feedNavigationController.tabBarItem.image = #imageLiteral(resourceName: "feed")
//    newPostNavigationController.tabBarItem.image = #imageLiteral(resourceName: "plus")
//    profileNavigationController.tabBarItem.image = #imageLiteral(resourceName: "profile")
    
    //window?.rootViewController = tabBarController
    window?.rootViewController = authoriseViewController
    window?.makeKeyAndVisible()
    
    return true
  }
}
