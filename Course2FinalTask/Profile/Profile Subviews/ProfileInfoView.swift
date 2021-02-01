//
//  ProfileInfoView.swift
//  Course2FinalTask
//
//  Created by Rodianov on 07.03.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit

protocol ProfileInfoViewDelegate: NetworkManagerDelegate{
  func followersTapped(userList: [User], title: String)
  func followingTapped(userList: [User], title: String)
  func showAlert()
  func showIndicator()
  func hideIndicator()
}

final class ProfileInfoView: UIView {
  weak var delegate: ProfileInfoViewDelegate?
  var user: User?
  var token: String?
  let session = URLSession.shared
//MARK: - Private properties
  
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
    NetworkManager.shared.delegate = delegate
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
  
  func fillProfileInfo() {
    if let user = user {
      guard let avatarURL = URL(string: user.avatar) else {return}
      userAvatarImageView.kf.setImage(with: avatarURL)
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
    guard let token = token,
      let currentUserRequest = NetworkManager.shared.currentUserRequest(token: token) else {
        delegate?.showAlert()
      return}

    NetworkManager.shared.performRequest(request: currentUserRequest,
                                         session: session)
    { [weak self] (data) in
      guard let currenUser = NetworkManager.shared.parseJSON(jsonData: data, toType: User.self) else {return}
      
      if self?.user?.id != currenUser.id  {
        DispatchQueue.main.async {
          self?.followButton.isHidden = false
        }
      }
    }
  }
}
//MARK: - Gesture Handlers

extension ProfileInfoView {
  @objc private func followersLabelTapped (_ recognizer: UITapGestureRecognizer) {
    
    delegate?.showIndicator()
    
    if let userID = user?.id {
      
      guard let token = token,
        let followersRequest = NetworkManager.shared.getFollowingUsersForUserRequest(withUserID: userID,
                                                                                     token: token) else {return}
      
      NetworkManager.shared.performRequest(request: followersRequest, session: session) {
        [weak self](data) in
        guard let usersArray = NetworkManager.shared.parseJSON(jsonData: data,
                                                               toType: [User].self) else {return}
        
        DispatchQueue.main.async{
          self?.delegate?.hideIndicator()
          self?.delegate?.followersTapped(userList: usersArray, title: "Followers")
        }
      }
    }
  }
  
  @objc private func followinLabelTapped (_ recognizer: UITapGestureRecognizer) {
    
    delegate?.showIndicator()
    
    if let userID = user?.id {
      guard let token = token,
        let followersRequest = NetworkManager.shared.getUsersFollowedByUserRequest(withUserID: userID,
                                                                                   token: token) else {return}
      
      NetworkManager.shared.performRequest(request: followersRequest,
                                           session: session)
      { [weak self](data) in
        guard let usersArray = NetworkManager.shared.parseJSON(jsonData: data,
                                                               toType: [User].self) else {return}
        
        DispatchQueue.main.async{
          self?.delegate?.hideIndicator()
          self?.delegate?.followingTapped(userList: usersArray, title: "Following")
        }
      }
    }
  }
  
  @objc private func followButtonTapped () {
    if let user = user {
      if user.currentUserFollowsThisUser {
        
        guard let token = token,
          let unfollowRequest = NetworkManager.shared.unfollowUserRequest(withUserID: user.id,
                                                                          token: token) else {return}
        
        NetworkManager.shared.performRequest(request: unfollowRequest,
                                             session: session)
        { [weak self] (data) in
          guard let user = NetworkManager.shared.parseJSON(jsonData: data,
                                                           toType: User.self) else {return}
          
          self?.user = user
          
          DispatchQueue.main.async {
            self?.followersLabel.text = "Followers: \(user.followedByCount)"
            self?.followButton.setTitle("Follow", for: .normal)
          }
        }
      } else {
        guard let token = token,
          let followRequest = NetworkManager.shared.followUserRequest(withUserID: user.id,
                                                                      token: token) else {return}
        
        NetworkManager.shared.performRequest(request: followRequest,
                                             session: session)
        { [weak self] (data) in
          guard let user = NetworkManager.shared.parseJSON(jsonData: data,
                                                           toType: User.self) else {
                                                            self?.delegate?.showAlert()
                                                            return
          }
          
          self?.user = user
          
          DispatchQueue.main.async {
            self?.followersLabel.text = "Followers: \(user.followedByCount)"
            self?.followButton.setTitle("Unfollow", for: .normal)
          }
        }
      }
    }
  }
}

