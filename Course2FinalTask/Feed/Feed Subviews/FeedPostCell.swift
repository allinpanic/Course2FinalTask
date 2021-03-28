//
//  FeedPostCell.swift
//  Course2FinalTask
//
//  Created by Rodianov on 06.03.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit
import SnapKit
import Kingfisher

protocol FeedPostCellDelegate: UIViewController {
  func postHeaderViewTapped(user: UserStruct)
  func postImageDoubleTapped(imageView: UIImageView)
  func likesLabelTapped(users: [UserStruct], title: String)
}

final class FeedPostCell: UITableViewCell {
  
  var token: String?
  var networkMode: NetworkMode = .online
  weak var delegate: FeedPostCellDelegate?
  
  var post: PostStruct? {
    didSet {
      guard let post = post,
        let imageURL = URL(string: post.image),
        let avatarURL = URL(string: post.authorAvatar)
        else {return}
      
      getLikesCount()
      
      let date = convertDate(dateString: post.createdTime)

      postImageView.kf.setImage(with: imageURL)
      postHeader.avatarImageView.kf.setImage(with: avatarURL)
      postHeader.authorNameLabel.text = post.authorUsername
      postHeader.dateLabel.text = "\(date)"
      postFooter.postTextLabel.text = post.description
      
      if post.currentUserLikesThisPost == false {
        postFooter.likeButton.tintColor = .lightGray
      } else {
        postFooter.likeButton.tintColor = .systemBlue
      }
    }
  }
  
// MARK: - Private properties
  private var likesCount: Int = 0 {
    didSet {
      postFooter.likesLabel.text = "Likes: \(likesCount)"
    }
  }
  
  private lazy var postHeader: PostHeader = {
    let header = PostHeader()
    header.addGestureRecognizer(tapGestureRecognizer)
    return header
  }()
  
  private lazy var postImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.isUserInteractionEnabled = true
    imageView.addGestureRecognizer(doubleTapRecognizer)
    return imageView
  }()
  
  private var bigLikeImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.image = #imageLiteral(resourceName: "bigLike")
    imageView.isHidden = true
    return imageView
  }()
  
  private lazy var postFooter: PostFooterView = {
    let footer = PostFooterView()
    footer.likesLabel.addGestureRecognizer(likesTapRecognizer)
    return footer
  }()
  
  private lazy var tapGestureRecognizer: UITapGestureRecognizer = {
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(postHeaderTapped))
    return tapGesture
  }()
  
  private lazy var doubleTapRecognizer: UITapGestureRecognizer = {
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(postImageTapped(_:)))
    tapGesture.numberOfTapsRequired = 2
    return tapGesture
  }()
  
  private lazy var likesTapRecognizer: UITapGestureRecognizer = {
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(likesCountTapped(_:)))
    return tapGesture
  }()
// MARK: - Inits
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setupLayout()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

// MARK: - Fill In Cell

extension FeedPostCell {
  private func setupLayout() {
    contentView.addSubview(postHeader)
    contentView.addSubview(postImageView)
    contentView.addSubview(bigLikeImageView)
    contentView.addSubview(postFooter)
    
    postHeader.snp.makeConstraints{
      $0.top.leading.trailing.equalToSuperview()
      $0.height.equalTo(51)
    }
    
    postImageView.snp.makeConstraints{
      $0.top.equalTo(postHeader.snp.bottom)
      $0.leading.trailing.equalToSuperview()
      $0.height.equalTo(postImageView.snp.width)
    }
    
    postFooter.snp.makeConstraints{
      $0.leading.trailing.equalToSuperview()
      $0.top.equalTo(postImageView.snp.bottom)
      $0.bottom.equalToSuperview()
    }
    
    bigLikeImageView.snp.makeConstraints{
      $0.centerX.centerY.equalToSuperview()
    }
    
    postFooter.likeButton.addTarget(self, action: #selector(likeButtonPressed), for: .touchUpInside)
  }
}

// MARK: - Gesture Handlers

extension FeedPostCell {
  
  @objc private func postHeaderTapped(_ recognizer: UITapGestureRecognizer) {
    
    switch networkMode {
    
    case .online:
      if let userID = post?.author {
        
        guard let token = token else {return}
        
        let userRequest = NetworkManager.shared.getUserRequest(withUserID: userID, token: token)
        
        NetworkManager.shared.performRequest(request: userRequest,
                                             session: URLSession.shared)
        { [weak self] (result) in
          
          switch result {
            
          case .success(let data):
            guard let user = NetworkManager.shared.parseJSON(jsonData: data, toType: UserStruct.self) else {return}
            DispatchQueue.main.async {
              self?.delegate?.postHeaderViewTapped(user: user)
            }
            
          case .failure(let error):
            DispatchQueue.main.async {
              self?.delegate?.showAlert(error: error)
            }
          }
        }
      }
      
      
    case .offline:
      delegate?.showOfflineAlert()
      
      
      
    }
    
    
    
//    if let userID = post?.author {
//
//      guard let token = token else {return}
//
//      let userRequest = NetworkManager.shared.getUserRequest(withUserID: userID, token: token)
//
//      NetworkManager.shared.performRequest(request: userRequest,
//                                           session: URLSession.shared)
//      { [weak self] (result) in
//
//        switch result {
//
//        case .success(let data):
//          guard let user = NetworkManager.shared.parseJSON(jsonData: data, toType: UserStruct.self) else {return}
//          DispatchQueue.main.async {
//            self?.delegate?.postHeaderViewTapped(user: user)
//          }
//
//        case .failure(let error):
//          DispatchQueue.main.async {
//            self?.delegate?.showAlert(error: error)
//          }
//        }
//      }
//    }
  }
 

  
  @objc private func postImageTapped (_ gestureRecognizer: UITapGestureRecognizer) {
    delegate?.postImageDoubleTapped(imageView: bigLikeImageView)
    if post?.currentUserLikesThisPost == false {
      likeButtonPressed()
    }
  }
  
  @objc private func likesCountTapped (_ gestureRecognizer: UITapGestureRecognizer) {
    
    switch networkMode {
    
    case .online:
      if let postID = post?.id {
        
        guard let token = token else {return}
        
        let usersLikedRequest = NetworkManager.shared.getUsersLikedPostRequest(withPostID: postID,
                                                                               token: token)
        
        NetworkManager.shared.performRequest(request: usersLikedRequest,
                                             session: URLSession.shared)
        { [weak self] (result) in
          
          switch result {
            
          case .success(let data):
            guard let users = NetworkManager.shared.parseJSON(jsonData: data, toType: [UserStruct].self) else {return}
            
            DispatchQueue.main.async {
              self?.delegate?.likesLabelTapped(users: users, title: "Likes")
            }
            
          case .failure(let error):
            DispatchQueue.main.async {
              self?.delegate?.showAlert(error: error)
            }
          }
        }
      }
      
      
      
      
    case .offline:
      delegate?.showOfflineAlert()
      
      
    }
    
    
    
//    if let postID = post?.id {
//
//      guard let token = token else {return}
//
//      let usersLikedRequest = NetworkManager.shared.getUsersLikedPostRequest(withPostID: postID,
//                                                                             token: token)
//
//      NetworkManager.shared.performRequest(request: usersLikedRequest,
//                                           session: URLSession.shared)
//      { [weak self] (result) in
//
//        switch result {
//
//        case .success(let data):
//          guard let users = NetworkManager.shared.parseJSON(jsonData: data, toType: [UserStruct].self) else {return}
//
//          DispatchQueue.main.async {
//            self?.delegate?.likesLabelTapped(users: users, title: "Likes")
//          }
//
//        case .failure(let error):
//          DispatchQueue.main.async {
//            self?.delegate?.showAlert(error: error)
//          }
//        }
//      }
//    }
  }
  
  @objc private func likeButtonPressed () {
    
    switch  networkMode {
    case .online:
      if let postID = post?.id {
        if post?.currentUserLikesThisPost == true {
          
          guard let token = token else {return}
          
          let unlikeRequest = NetworkManager.shared.unlikePostRequest(withPostID: postID,
          token: token)
          
          NetworkManager.shared.performRequest(request: unlikeRequest,
                                               session: URLSession.shared)
          { [weak self] (result) in
            
            switch result {
              
            case .success(let data):
              guard let post = NetworkManager.shared.parseJSON(jsonData: data, toType: PostStruct.self) else {return}
              
              DispatchQueue.main.async {
                self?.post = post
                self?.postFooter.likeButton.tintColor = .lightGray
              }
              
            case .failure(let error):
              DispatchQueue.main.async {
                self?.delegate?.showAlert(error: error)
              }
            }
          }
        } else {
          guard let token = token else {return}
          
          let likeRequest = NetworkManager.shared.likePostRequest(withPostID: postID,
                                                                  token: token)
          
          NetworkManager.shared.performRequest(request: likeRequest,
                                               session: URLSession.shared)
          { [weak self] (result) in
            
            switch result {
              
            case .success(let data):
              guard let post = NetworkManager.shared.parseJSON(jsonData: data, toType: PostStruct.self) else {return}
              
              DispatchQueue.main.async {
                self?.post = post
                self?.postFooter.likeButton.tintColor = .systemBlue
              }
              
            case .failure(let error):
              DispatchQueue.main.async {
                self?.delegate?.showAlert(error: error)
              }
            }
          }
        }
      }
      
      
      
      
    case .offline:
      
      delegate?.showOfflineAlert()
      
      
      
      
      
    }
    
    
    
//    if let postID = post?.id {
//      if post?.currentUserLikesThisPost == true {
//
//        guard let token = token else {return}
//
//        let unlikeRequest = NetworkManager.shared.unlikePostRequest(withPostID: postID,
//        token: token)
//
//        NetworkManager.shared.performRequest(request: unlikeRequest,
//                                             session: URLSession.shared)
//        { [weak self] (result) in
//
//          switch result {
//
//          case .success(let data):
//            guard let post = NetworkManager.shared.parseJSON(jsonData: data, toType: PostStruct.self) else {return}
//
//            DispatchQueue.main.async {
//              self?.post = post
//              self?.postFooter.likeButton.tintColor = .lightGray
//            }
//
//          case .failure(let error):
//            DispatchQueue.main.async {
//              self?.delegate?.showAlert(error: error)
//            }
//          }
//        }
//      } else {
//        guard let token = token else {return}
//
//        let likeRequest = NetworkManager.shared.likePostRequest(withPostID: postID,
//                                                                token: token)
//
//        NetworkManager.shared.performRequest(request: likeRequest,
//                                             session: URLSession.shared)
//        { [weak self] (result) in
//
//          switch result {
//
//          case .success(let data):
//            guard let post = NetworkManager.shared.parseJSON(jsonData: data, toType: PostStruct.self) else {return}
//
//            DispatchQueue.main.async {
//              self?.post = post
//              self?.postFooter.likeButton.tintColor = .systemBlue
//            }
//
//          case .failure(let error):
//            DispatchQueue.main.async {
//              self?.delegate?.showAlert(error: error)
//            }
//          }
//        }
//      }
//    }
  }
}
// MARK: - Private functions

extension FeedPostCell {
  
  private func convertDate(dateString: String) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
    if let date = formatter.date(from: dateString) {
      
      formatter.timeStyle = .medium
      formatter.dateStyle = .medium
      formatter.doesRelativeDateFormatting = true
      
      return formatter.string(from: date)
    }
    
    return ""
  }
  
  private func getLikesCount() {
    switch networkMode {
    
    case .online:
      guard let post = post else {return}
      
      guard let token = token else {return}
      
      let usersLikedRequest = NetworkManager.shared.getUsersLikedPostRequest(withPostID: post.id, token: token)
      
      NetworkManager.shared.performRequest(request: usersLikedRequest, session: URLSession.shared)
      { [weak self] (result) in
        
        switch result {
          
        case .success(let data):
          guard let users = NetworkManager.shared.parseJSON(jsonData: data, toType: [UserStruct].self) else {return}
          
          DispatchQueue.main.async {
            self?.likesCount = users.count
          }
          
        case .failure(let error):
          DispatchQueue.main.async {
            self?.delegate?.showAlert(error: error)
          }
        }
      }
      
      
    case .offline:
      
      // get likes from coreData
      print("get likes")
    }
    
    
    
//    guard let post = post else {return}
//
//    guard let token = token else {return}
//
//    let usersLikedRequest = NetworkManager.shared.getUsersLikedPostRequest(withPostID: post.id, token: token)
//
//    NetworkManager.shared.performRequest(request: usersLikedRequest, session: URLSession.shared)
//    { [weak self] (result) in
//
//      switch result {
//
//      case .success(let data):
//        guard let users = NetworkManager.shared.parseJSON(jsonData: data, toType: [UserStruct].self) else {return}
//
//        DispatchQueue.main.async {
//          self?.likesCount = users.count
//        }
//
//      case .failure(let error):
//        DispatchQueue.main.async {
//          self?.delegate?.showAlert(error: error)
//        }
//      }
//    }
  }
}
