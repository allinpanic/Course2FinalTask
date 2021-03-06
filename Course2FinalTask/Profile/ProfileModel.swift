//
//  ProfileModel.swift
//  Course2FinalTask
//
//  Created by Rodianov on 08.06.2021.
//  Copyright © 2021 e-Legion. All rights reserved.
//

import Foundation
// MARK: - ProfileModelDelegate

protocol ProfileModelDelegate: class {
  func navigateToAuth()
  func getError(error: NetworkError)
  func showOfflineAlert()
  func showIndicator()
  func hideIndicator()
}
// MARK: - ProfileModelProtocol

protocol ProfileModelProtocol: class {
  var delegate: ProfileModelDelegate? { get set }
  var dataManager: CoreDataManager! { get set }
  func logOut()
  func follow(userID: String, completionHandler: @escaping (UserData) -> Void)
  func unfollow(userID: String, completionHandler: @escaping (UserData) -> Void)
  func getUserPosts(user: UserData, completionHandler: @escaping ([PostData]) -> Void)
  func getFollowers(userID: String, completionHandler: @escaping ([UserData]) -> Void)
  func getFollowingUsers(userID: String, completionHandler: @escaping ([UserData]) -> Void)
  func checkIsCurrentUser(user: UserData, handler: @escaping (Bool) -> Void)
}
// MARK: - ProfileModel

final class ProfileModel: ProfileModelProtocol {
  weak var delegate: ProfileModelDelegate?
  var dataManager: CoreDataManager!
  
  private var networkMode: NetworkMode
  private var token: String
  private var keychainManager = KeychainManager()
  private var session = URLSession.shared
  
  init(networkMode: NetworkMode, token: String) {
    self.networkMode = networkMode
    self.token = token
  }
  
// MARK: - LogOut
  func logOut() {
    let _ = keychainManager.deleteToken(service: "courseTask", account: nil)
    
    switch networkMode {
    
    case .online:
      let signOutRequest = NetworkManager.shared.signOutRequest(token: token)
      
      NetworkManager.shared.performRequest(request: signOutRequest,
                                           session: session)
      { [weak self] (data) in
        self?.dataManager.deleteAll(entity: Post.self)
        self?.dataManager.deleteAll(entity: User.self)
        
        DispatchQueue.main.async {
          self?.delegate?.navigateToAuth()
        }
      }
      
    case .offline:
      dataManager.deleteAll(entity: Post.self)
      dataManager.deleteAll(entity: User.self)
      
      DispatchQueue.main.async {
        self.delegate?.navigateToAuth()
      }
    }
  }
  // MARK: - Follow
  
  func follow(userID: String, completionHandler: @escaping (UserData) -> Void) {
    switch networkMode {
    
    case .online:
      let followRequest = NetworkManager.shared.followUserRequest(withUserID: userID,
                                                                  token: token)
      NetworkManager.shared.performRequest(request: followRequest,
                                           session: session)
      { [weak self] (result) in
        switch result {
        
        case .success(let data):
          guard let user = NetworkManager.shared.parseJSON(jsonData: data,
                                                           toType: UserData.self) else {return}
          DispatchQueue.main.async {
            completionHandler(user)
          }
          
        case .failure(let error):
          DispatchQueue.main.async {
            self?.delegate?.getError(error: error)
          }
        }
      }
      
    case .offline:
      delegate?.showOfflineAlert()
    }
  }
  // MARK: - Unfollow
  
  func unfollow(userID: String, completionHandler: @escaping (UserData) -> Void) {
    switch networkMode {
    
    case .online:
      let unfollowRequest = NetworkManager.shared.unfollowUserRequest(withUserID: userID,
                                                                      token: token)
      NetworkManager.shared.performRequest(request: unfollowRequest,
                                           session: session)
      { [weak self] (result) in
        switch result {
        
        case .success(let data):
          guard let user = NetworkManager.shared.parseJSON(jsonData: data,
                                                           toType: UserData.self) else {return}
          DispatchQueue.main.async {
            completionHandler(user)
          }
          
        case .failure(let error):
          DispatchQueue.main.async {
            self?.delegate?.getError(error: error)
          }
        }
      }
      
    case .offline:
      delegate?.showOfflineAlert()
    }
  }
  // MARK: - Get followers
  
  func getFollowers(userID: String, completionHandler: @escaping ([UserData]) -> Void) {
    switch networkMode {
    
    case .online:
      delegate?.showIndicator()
      
      let followersRequest = NetworkManager.shared.getFollowingUsersForUserRequest(withUserID: userID,
                                                                                   token: token)
      NetworkManager.shared.performRequest(request: followersRequest,
                                           session: session)
      { [weak self](result) in
        switch result {
        
        case .success(let data):
          guard let usersArray = NetworkManager.shared.parseJSON(jsonData: data,
                                                                 toType: [UserData].self) else {return}
          DispatchQueue.main.async{
            completionHandler(usersArray)
          }
          
        case .failure(let error):
          DispatchQueue.main.async {
            self?.delegate?.getError(error: error)
          }
        }
      }
      
    case .offline:
      delegate?.showOfflineAlert()
    }
  }
  // MARK: - Get following
  
  func getFollowingUsers(userID: String, completionHandler: @escaping ([UserData]) -> Void) {
    switch networkMode {
    
    case .online:
      delegate?.showIndicator()
      
      let followersRequest = NetworkManager.shared.getUsersFollowedByUserRequest(withUserID: userID,
                                                                                 token: token)
      NetworkManager.shared.performRequest(request: followersRequest,
                                           session: session)
      { [weak self](result) in
        switch result {
        
        case .success(let data):
          guard let usersArray = NetworkManager.shared.parseJSON(jsonData: data,
                                                                 toType: [UserData].self) else {return}
          DispatchQueue.main.async{
            completionHandler(usersArray)
          }
          
        case .failure(let error):
          DispatchQueue.main.async {
            self?.delegate?.getError(error: error)
          }
        }
      }
      
    case .offline:
      delegate?.showOfflineAlert()
    }
  }
  // MARK: - Check is current user
  
  func checkIsCurrentUser(user: UserData, handler: @escaping (Bool) -> Void) {
    let currentUserRequest = NetworkManager.shared.currentUserRequest(token: token)
    
    NetworkManager.shared.performRequest(request: currentUserRequest,
                                         session: session)
    { [weak self] (result) in
      switch result {
      
      case .success(let data):
        guard let currenUser = NetworkManager.shared.parseJSON(jsonData: data,
                                                               toType: UserData.self) else {return}
        if user.id == currenUser.id  {
          DispatchQueue.main.async {
            handler(true)
          }
        } else {
          DispatchQueue.main.async {
            handler(false)
          }          
        }
        
      case .failure(let error):
        DispatchQueue.main.async {
          self?.delegate?.getError(error: error)
        }
      }
    }
  }
  // MARK: - Get user posts
  
  func getUserPosts(user: UserData, completionHandler: @escaping ([PostData]) -> Void) {
    switch networkMode {
    
    case .online:
      let userPostsRequest = NetworkManager.shared.getPostsByUserRequest(withUserID: user.id,
                                                                         token: token)
      NetworkManager.shared.performRequest(request: userPostsRequest,
                                           session: session)
      { [weak self] (result) in
        switch result {
        
        case .success(let data):
          guard let posts = NetworkManager.shared.parseJSON(jsonData: data,
                                                            toType: [PostData].self) else {return}
          let userPosts: [PostData] = posts.reversed()
          
          DispatchQueue.main.async {
            completionHandler(userPosts)
          }
          
          self?.checkIsCurrentUser(user: user, handler: { [weak self] (isCurrentUser) in
            if isCurrentUser {
              self?.dataManager.saveCurrentUser(currUser: user)
              for post in posts {
                self?.dataManager.savePost(post: post)
              }
            }
          })
          
        case .failure(let error):
          DispatchQueue.main.async {
            self?.delegate?.getError(error: error)
          }
        }
      }
      
    case .offline:
      var userPosts = [PostData]()
      
      let predicate = NSPredicate(format: "author == %@", user.id)
      let sortDescriptor = NSSortDescriptor(key: #keyPath(Post.createdTime), ascending: false)
      
      let fetchedPosts = dataManager.fetchData(for: Post.self,
                                               predicate: predicate,
                                               sortDescriptor: sortDescriptor)
      let converter = Converter()
      
      for post in fetchedPosts {
        guard let postStruct = converter.convertToStruct(post: post) else {return}
        userPosts.append(postStruct)
      }
      
      DispatchQueue.main.async {
        completionHandler(userPosts)
      }
    }
  }
}
