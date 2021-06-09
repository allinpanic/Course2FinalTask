//
//  ProfileViewController.swift
//  Course2FinalTask
//
//  Created by Rodianov on 07.03.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit
// MARK: - ProfileViewController

final class ProfileViewController: UIViewController {

  var user: UserData?
  var networkMode: NetworkMode = .online
  var profileModel: ProfileModelProtocol!
  // MARK: - Private properties
  
  private lazy var profileView: ProfileViewProtocol = {
    let view = ProfileView()
    view.networkMode = networkMode
    view.user = user
    
    view.userImagesCollectionView.delegate = self
    view.userImagesCollectionView.dataSource = self
    view.profileInfoView.delegate = self
    return view
  }()

  private var token: String
  private let session = URLSession.shared
  private var userPosts: [PostData]?

// MARK: - Inits
  
  init (user: UserData?, token: String) {
    self.user = user
    self.token = token
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
//MARK: - ViewDidLoad
  
  override func loadView() {
    view = profileView
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.navigationItem.title = user?.username
    
    profileModel.delegate = self
    
    showIndicator()
    getUserPosts()
    
    guard let user = user else {return}
    configureLogOutButton(userID: user.id)
    configureFollowButton(user: user)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    if networkMode == .online {
      showIndicator()
      getUserPosts()
    }
  }
}
// MARK: - CollectionViewDataSourse,Delegate

extension ProfileViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return userPosts?.count ?? 0
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: profileView.reuseIdentifier, for: indexPath) as? ImageCollectionViewCell
    else { return UICollectionViewCell()}
    
    switch networkMode {
    
    case .online:
      if let imageString = userPosts?[indexPath.item].image {
        if let imageURL = URL(string: (imageString)) {
          cell.imageView.kf.setImage(with: imageURL)
        }
      }
      
    case .offline:
      if let imageString = userPosts?[indexPath.item].image {
        if let imageData = Data(base64Encoded: imageString) {
          if let image = UIImage(data: imageData) {
            cell.imageView.image = image
          }
        }
      }
    }
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: view.frame.width/3, height: view.frame.width/3)
  }  
}
// MARK: - ProfileInfoViewDelegate

extension ProfileViewController: ProfileInfoViewDelegate {
  func followButtonTapped(user: UserData) {
    if user.currentUserFollowsThisUser {
      profileModel.unfollow(userID: user.id) { [weak self] (user) in
        self?.profileView.updateProfileInfoView(user: user, title: "Follow")
      }
    }else {
      profileModel.follow(userID: user.id) { [weak self] (user) in
        self?.profileView.updateProfileInfoView(user: user, title: "Unfollow")
      }
    }
  }
  
  func followersTapped(userID: String, title: String) {
    profileModel.getFollowers(userID: userID, completionHandler: { [weak self] (userList) in      
      self?.navigateToUserList(userList: userList, title: title)
    })
  }
  
  func followingTapped(userID: String, title: String) {
    profileModel.getFollowingUsers(userID: userID, completionHandler: { [weak self] (userList) in
      self?.navigateToUserList(userList: userList, title: title)
    })
  }
}
// MARK: - Private methods

extension ProfileViewController {
  @objc private func logOutButtonTapped() {
    profileModel.logOut()
  }
  
  private func configureLogOutButton(userID: String) {
    switch networkMode {
    
    case .online:
      guard let user = user else {return}
      
      profileModel.checkIsCurrentUser(user: user) { [weak self] isCurrentUser in
        if isCurrentUser {
          
          DispatchQueue.main.async {
            let logOutButton = UIBarButtonItem(title: "Log Out",
                                               style: .plain,
                                               target: self,
                                               action: #selector(self?.logOutButtonTapped))
            self?.navigationItem.rightBarButtonItem = logOutButton
          }
        }
      }
      
    case .offline:
      let logOutButton = UIBarButtonItem(title: "Log Out",
                                         style: .plain,
                                         target: self,
                                         action: #selector(logOutButtonTapped))
      
      navigationItem.rightBarButtonItem = logOutButton
    }
  }
  
  private func navigateToUserList(userList: [UserData], title: String) {
    
    let userListController = Builder.createUserListViewController(userList: userList,
                                                                  dataManager: profileModel.dataManager,
                                                                  networkMode: networkMode,
                                                                  token: token,
                                                                  title: title)
    
    navigationController?.pushViewController(userListController, animated: true)
  }
  
  private func configureFollowButton(user: UserData) {
    switch networkMode {
    
    case .online:
      profileModel.checkIsCurrentUser(user: user) { [weak self] (isCurrentUser) in
        if isCurrentUser {
          
          DispatchQueue.main.async {
            self?.profileView.hideFollowButton()
          }
        } else {
          DispatchQueue.main.async {
            self?.profileView.showFollowButton()
          }
        }
      }
      
    case .offline:
      profileView.hideFollowButton()
    }
  }
  
  private func getUserPosts() {
    guard let user = user else {return}
    
    profileModel.getUserPosts(user: user) { [weak self] (userPosts) in
      self?.userPosts = userPosts
      self?.profileView.userImagesCollectionView.reloadData()
      self?.hideIndicator()
    }
  }
}

// MARK: - ProfileModelDelegate

extension ProfileViewController: ProfileModelDelegate {
  func navigateToAuth() {
    let dataManager = CoreDataManager(modelName: "UserPost")
    
    let authenticationController = Builder.createAuthViewController(dataManager: dataManager)
    
    UIApplication.shared.windows.first?.rootViewController = authenticationController
  }
  
  func getError(error: NetworkError) {
    showAlert(error: error)
  }
  
  func showIndicator() {
    profileView.showIndicator()
  }
  
  func hideIndicator() {
    profileView.hideIndicator()
  }
}
