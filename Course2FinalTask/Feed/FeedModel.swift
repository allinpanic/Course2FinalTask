//
//  FeedModel.swift
//  Course2FinalTask
//
//  Created by Rodianov on 07.06.2021.
//  Copyright © 2021 e-Legion. All rights reserved.
//

import Foundation
// MARK: - FeedModelDelegate protocol

protocol FeedModelDelegate: class {
  func getError(error: NetworkError)
  func showIndicator()
  func hideIndicator()
  func navigateToProfileVC(user: UserStruct)
  func showOfflineAlert()
}
// MARK: - FeedModelProtocol

protocol FeedModelProtocol: class {
  var delegate: FeedModelDelegate? { get set }
  var dataManager: CoreDataManager! { get set }
  func getUser(withUserID userID: String, completionHandler: @escaping (UserStruct) -> Void) 
  func getFeed(token: String, completionHandler: @escaping ([PostStruct]) -> Void)
  func likePost(withPostID: String, completionHandler: @escaping (PostStruct) -> Void)
  func unlikePost(withPostID: String, completionHandler: @escaping (PostStruct) -> Void)
  func getLikes(withPostID: String, completionHandler: @escaping ([UserStruct]) -> Void)
}
// MARK: - FeedModel class

final class FeedModel: FeedModelProtocol {
  
  var dataManager: CoreDataManager!
  weak var delegate: FeedModelDelegate?
  
  private var networkMode: NetworkMode
  private var token: String
  private let session = URLSession.shared
  
// MARK: - Init
  init(networkMode: NetworkMode, token: String) {
    self.networkMode = networkMode
    self.token = token
  }
// MARK: - Methods - getUser
  
  func getUser(withUserID userID: String, completionHandler: @escaping (UserStruct) -> Void) /*-> UserStruct*/ {
    switch networkMode {
    
    case .online:
        
        let userRequest = NetworkManager.shared.getUserRequest(withUserID: userID,
                                                               token: token)
        NetworkManager.shared.performRequest(request: userRequest,
                                             session: URLSession.shared)
        { [weak self] (result) in
          switch result {
          
          case .success(let data):
            guard let user = NetworkManager.shared.parseJSON(jsonData: data,
                                                             toType: UserStruct.self) else {return}
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
// MARK: - getFeed
  
  func getFeed(token: String, completionHandler: @escaping ([PostStruct]) -> Void) {
    switch networkMode {
    case .online:
      let postsRequest = NetworkManager.shared.getFeedRequest(token: token)
      
      NetworkManager.shared.performRequest(request: postsRequest, session: session) {
        [weak self] (result) in
        
        switch result {
        
        case .success(let data):
          guard let posts = NetworkManager.shared.parseJSON(jsonData: data, toType: [PostStruct].self) else {return}

          DispatchQueue.main.async {
            completionHandler(posts)
          }
          
          for post in posts {
            self?.getLikes(withPostID: post.id, completionHandler: { (users) in
              let likes = users.count
              
              self?.dataManager.savePost(post: post, likesCount: likes)
            })
          }
          
        case .failure(let error):
          DispatchQueue.main.async {
            self?.delegate?.getError(error: error)
          }
        }
      }
      
    case .offline:
      let sortDescriptor = NSSortDescriptor(key: #keyPath(Post.createdTime), ascending: false)
      let converter = Converter()
      
      let fetchedPosts = dataManager.fetchData(for: Post.self, sortDescriptor: sortDescriptor)
      var posts = [PostStruct]()
      
      for post in fetchedPosts {
        guard let postStruct = converter.convertToStruct(post: post) else {return}        
        posts.append(postStruct)
      }
      
      DispatchQueue.main.async {
        completionHandler(posts)
      }
    }
  }
// MARK: - like - unlike
  
  func likePost(withPostID postID: String, completionHandler: @escaping (PostStruct) -> Void) {
    switch networkMode {
    
    case .online:
      let likeRequest = NetworkManager.shared.likePostRequest(withPostID: postID,
                                                              token: token)
      NetworkManager.shared.performRequest(request: likeRequest,
                                           session: URLSession.shared)
      { [weak self] (result) in
        switch result {
        
        case .success(let data):
          guard let post = NetworkManager.shared.parseJSON(jsonData: data,
                                                           toType: PostStruct.self) else {return}
          DispatchQueue.main.async {
            completionHandler(post)
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
  
  func unlikePost(withPostID postID: String, completionHandler: @escaping (PostStruct) -> Void) {
    switch networkMode {
    
    case .online:
      let unlikeRequest = NetworkManager.shared.unlikePostRequest(withPostID: postID,
                                                                  token: token)
      NetworkManager.shared.performRequest(request: unlikeRequest,
                                           session: URLSession.shared)
      { [weak self] (result) in
        switch result {
        
        case .success(let data):
          guard let post = NetworkManager.shared.parseJSON(jsonData: data,
                                                           toType: PostStruct.self) else {return}
          DispatchQueue.main.async {
            completionHandler(post)
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

  // MARK: - getLikes
  
  func getLikes(withPostID postID: String, completionHandler: @escaping ([UserStruct]) -> Void) {
    switch networkMode {
    
    case .online:
      let usersLikedRequest = NetworkManager.shared.getUsersLikedPostRequest(withPostID: postID,
                                                                             token: token)
      
      NetworkManager.shared.performRequest(request: usersLikedRequest,
                                           session: URLSession.shared)
      { [weak self] (result) in
        switch result {
        
        case .success(let data):
          guard let users = NetworkManager.shared.parseJSON(jsonData: data,
                                                            toType: [UserStruct].self) else {return}
          completionHandler(users)
          
        case .failure(let error):
          DispatchQueue.main.async {
            self?.delegate?.getError(error: error)
          }
        }
      }
      
    case .offline:
      DispatchQueue.main.async {
        self.delegate?.showOfflineAlert()
      }
    }
  }
}
