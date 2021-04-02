//
//  ProfileInfoView.swift
//  Course2FinalTask
//
//  Created by Rodianov on 07.03.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit

protocol ProfileInfoViewDelegate: UIViewController {
  func followersTapped(userList: [UserStruct], title: String)
  func followingTapped(userList: [UserStruct], title: String)
  func showIndicator()
  func hideIndicator()
}

final class ProfileInfoView: UIView {
  weak var delegate: ProfileInfoViewDelegate?
  var user: UserStruct?
  var token: String?
  var networkMode: NetworkMode = .online
//MARK: - Private properties
  
  private let session = URLSession.shared
  
  private var userAvatarImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.layer.cornerRadius = 35
    imageView.layer.masksToBounds = true
    return imageView
  }()
  
  private var userNameLabel: UILabel = {
    let label = UILabel()
    label.font = .systemFont(ofSize: 14)
    label.textColor = .black
    return label
  }()
  
  private lazy var followersLabel: UILabel = {
    let label = UILabel()
    label.font = .systemFont(ofSize: 14, weight: .semibold)
    label.textColor = .black
    label.isUserInteractionEnabled = true
    label.addGestureRecognizer(followersTapRecognizer)
    return label
  }()
  
  private lazy var followingLabel: UILabel = {
    let label = UILabel()
    label.font = .systemFont(ofSize: 14, weight: .semibold)
    label.textColor = .black
    label.isUserInteractionEnabled = true
    label.addGestureRecognizer(followingTapRecognizer)
    return label
  }()
  
  private lazy var followButton: FollowButton = {
    let button = FollowButton()
    button.backgroundColor = UIColor(named: "ButtonBlue")
    button.titleLabel?.textColor = .white
    button.titleLabel?.font = .systemFont(ofSize: 15)
    button.titleEdgeInsets.left = 6
    button.titleEdgeInsets.right = 6
    button.layer.cornerRadius = 4
    button.addTarget(self, action: #selector(followButtonTapped), for: .touchUpInside)
    button.isHidden = true
    return button
  }()
  
  private lazy var followersTapRecognizer: UITapGestureRecognizer = {
    let gesture = UITapGestureRecognizer(target: self, action: #selector(followersLabelTapped(_:)))
    return gesture
  }()
  
  private lazy var followingTapRecognizer: UITapGestureRecognizer = {
    let gesture = UITapGestureRecognizer(target: self, action: #selector(followinLabelTapped(_:)))
    return gesture
  }()
//MARK: - Inits
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupLayout()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
//MARK: - Fill in the View methods

extension ProfileInfoView {
  private func setupLayout() {
    addSubview(userAvatarImageView)
    addSubview(userNameLabel)
    addSubview(followersLabel)
    addSubview(followingLabel)
    addSubview(followButton)
    
    userAvatarImageView.snp.makeConstraints{
      $0.height.width.equalTo(70)
      $0.top.equalToSuperview().offset(8)
      $0.leading.equalToSuperview().offset(8)
      $0.bottom.equalToSuperview().inset(8)
    }
    
    userNameLabel.snp.makeConstraints{
      $0.leading.equalTo(userAvatarImageView.snp.trailing).offset(8)
      $0.top.equalToSuperview().offset(8)
    }
    
    followersLabel.snp.makeConstraints{
      $0.leading.equalTo(userAvatarImageView.snp.trailing).offset(8)
      $0.bottom.equalToSuperview().inset(8)
    }
    
    followingLabel.snp.makeConstraints{
      $0.bottom.equalToSuperview().inset(8)
      $0.trailing.equalToSuperview().inset(8)
    }
    
    followButton.snp.makeConstraints{
      $0.top.equalToSuperview().inset(8)
      $0.trailing.equalTo(followingLabel)
      $0.width.greaterThanOrEqualTo(60).priority(750)
    }
  }
  
  func fillProfileInfo(completionHandler: @escaping (UIImage?) -> Void) {
    if let user = user {
      switch networkMode {
      
      case .online:
        guard let avatarURL = URL(string: user.avatar) else {return}
        userAvatarImageView.kf.setImage(with: avatarURL)
        
        let avatar = userAvatarImageView.image
        completionHandler(avatar)
        
      case .offline:
        guard let avatarData = Data(base64Encoded: user.avatar),
              let avatarImage = UIImage(data: avatarData) else {return}
        
        userAvatarImageView.image = avatarImage
      }
      
      userNameLabel.text = user.fullName
      followersLabel.text = "Followers: \(user.followedByCount)"
      followersLabel.sizeToFit()
      followingLabel.text = "Following: \(user.followsCount)"
      
      if user.currentUserFollowsThisUser == true {
        followButton.setTitle("Unfollow", for: .normal)
        followButton.sizeToFit()
      } else {
        followButton.setTitle("Follow", for: .normal)
        followButton.sizeToFit()
      }
    }
    configureFollowButton()
  }
  
  private func configureFollowButton() {
    guard let token = token else {return}
    
    switch networkMode {
    
    case .online:
      let currentUserRequest = NetworkManager.shared.currentUserRequest(token: token)
      
      NetworkManager.shared.performRequest(request: currentUserRequest,
                                           session: session)
      { [weak self] (result) in
        switch result {
          
        case .success(let data):
          guard let currentUser = NetworkManager.shared.parseJSON(jsonData: data,
                                                                  toType: UserStruct.self) else {return}
          
          if self?.user?.id != currentUser.id  {
            DispatchQueue.main.async {
              self?.followButton.isHidden = false
            }
          }
          
        case .failure(let error):
          DispatchQueue.main.async {
            self?.delegate?.showAlert(error: error)
          }
        }
      }
      
    case .offline:
      followButton.isHidden = true
    }
  }
}
//MARK: - Gesture Handlers

extension ProfileInfoView {
  @objc private func followersLabelTapped (_ recognizer: UITapGestureRecognizer) {
    switch networkMode {
    
    case .online:
      delegate?.showIndicator()
      
      if let userID = user?.id {
        guard let token = token else {return}
        
        let followersRequest = NetworkManager.shared.getFollowingUsersForUserRequest(withUserID: userID,
                                                                                     token: token)
        NetworkManager.shared.performRequest(request: followersRequest,
                                             session: session) {
          [weak self](result) in
          switch result {
            
          case .success(let data):
            guard let usersArray = NetworkManager.shared.parseJSON(jsonData: data,
                                                                   toType: [UserStruct].self) else {return}
            DispatchQueue.main.async{
              self?.delegate?.hideIndicator()
              self?.delegate?.followersTapped(userList: usersArray, title: "Followers")
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
  }
  
  @objc private func followinLabelTapped (_ recognizer: UITapGestureRecognizer) {
    switch networkMode {
    
    case .online:
      delegate?.showIndicator()
      
      if let userID = user?.id {
        guard let token = token else {return}
        
        let followersRequest = NetworkManager.shared.getUsersFollowedByUserRequest(withUserID: userID,
                                                                                   token: token)
        NetworkManager.shared.performRequest(request: followersRequest,
                                             session: session)
        { [weak self](result) in
          switch result {
            
          case .success(let data):
            guard let usersArray = NetworkManager.shared.parseJSON(jsonData: data,
                                                                   toType: [UserStruct].self) else {return}
            
            DispatchQueue.main.async{
              self?.delegate?.hideIndicator()
              self?.delegate?.followingTapped(userList: usersArray, title: "Following")
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
  }
  
  @objc private func followButtonTapped () {
    switch networkMode {
    
    case .online:
      if let user = user {
        if user.currentUserFollowsThisUser {
          guard let token = token else {return}
          
          let unfollowRequest = NetworkManager.shared.unfollowUserRequest(withUserID: user.id,
                                                                          token: token)
          NetworkManager.shared.performRequest(request: unfollowRequest,
                                               session: session)
          { [weak self] (result) in
            switch result {
              
            case .success(let data):
              guard let user = NetworkManager.shared.parseJSON(jsonData: data,
                                                               toType: UserStruct.self) else {return}
              
              self?.user = user
              
              DispatchQueue.main.async {
                self?.followersLabel.text = "Followers: \(user.followedByCount)"
                self?.followButton.setTitle("Follow", for: .normal)
              }
              
            case .failure(let error):
              DispatchQueue.main.async {
                self?.delegate?.showAlert(error: error)
              }
            }
          }
        } else {
          guard let token = token else {return}
          
          let followRequest = NetworkManager.shared.followUserRequest(withUserID: user.id,
                                                                      token: token)
          NetworkManager.shared.performRequest(request: followRequest,
                                               session: session)
          { [weak self] (result) in            
            switch result {
            
            case .success(let data):
              guard let user = NetworkManager.shared.parseJSON(jsonData: data,
                                                               toType: UserStruct.self) else {
                                                                self?.delegate?.showAlert()
                                                                return}
              self?.user = user
              
              DispatchQueue.main.async {
                self?.followersLabel.text = "Followers: \(user.followedByCount)"
                self?.followButton.setTitle("Unfollow", for: .normal)
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
  }
}

