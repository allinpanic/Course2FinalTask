//
//  ProfileViewController.swift
//  Course2FinalTask
//
//  Created by Rodianov on 07.03.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit

final class ProfileViewController: UIViewController {

  var user: UserStruct?
  var networkMode: NetworkMode = .online
  var dataManager: CoreDataManager!
  
// MARK: - Private properties
  
  private var token: String
  private let session = URLSession.shared
  private var userPosts: [PostStruct]?
  private var userAvatar: UIImage?
  
  private let keychainManager = KeychainManager()
  
  private var reuseIdentifier = "imageCell"
  
  private lazy var profileScrollView: UIScrollView = {
    let scrollView = UIScrollView()
    scrollView.backgroundColor = .white
    scrollView.isScrollEnabled = true
    return scrollView
  }()
  
  private lazy var userImagesCollectionView: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    layout.minimumInteritemSpacing = 0
    layout.minimumLineSpacing = 0
    let collectionView = UICollectionView(frame: .zero , collectionViewLayout: layout)
    collectionView.backgroundColor = .white
    collectionView.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
    collectionView.isScrollEnabled = false
    return collectionView
  }()
  
  private lazy var profileInfoView: ProfileInfoView = {
    let profileInfo = ProfileInfoView()
    profileInfo.backgroundColor = .white
    profileInfo.delegate = self
    profileInfo.networkMode = self.networkMode
    return profileInfo
  }()
  
  private var indicator: UIActivityIndicatorView = {
    let indicator = UIActivityIndicatorView()
    indicator.style = .white
    return indicator
  }()
  
  private var dimmedView: UIView = {
    let view = UIView()
    view.backgroundColor = .black
    view.alpha = 0.7
    return view
  }()
// MARK: - Inits
  
  init (user: UserStruct?, token: String) {
    self.user = user
    self.token = token
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
//MARK: - ViewDidLoad
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    userImagesCollectionView.dataSource = self
    userImagesCollectionView.delegate = self
    setupLayout()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    if networkMode == .online {
      showIndicator()
      getUserPosts()
    }
    
    profileInfoView.user = user
    profileInfoView.token = token
    profileInfoView.networkMode = networkMode
    profileInfoView.fillProfileInfo(completionHandler: {[weak self] avatar in
      self?.userAvatar = avatar
    })
  }
}
//MARK: - Layout

extension ProfileViewController {
  private func setupLayout() {
    view.addSubview(profileScrollView)
    profileScrollView.addSubview(profileInfoView)
    profileScrollView.addSubview(userImagesCollectionView)
    
    self.navigationItem.title = user?.username
    
    showIndicator()
    getUserPosts()
    
    profileInfoView.user = user
    profileInfoView.token = token
    profileInfoView.fillProfileInfo{ _ in}
    
    configureLogOutButton()
    
    profileScrollView.snp.makeConstraints{
      $0.edges.equalToSuperview()
    }
    
    profileInfoView.snp.makeConstraints{
      $0.leading.trailing.top.equalToSuperview()
      $0.width.equalToSuperview()
      $0.height.equalTo(86)
    }
    
    userImagesCollectionView.snp.makeConstraints{
      $0.top.equalTo(profileInfoView.snp.bottom)
      $0.leading.trailing.equalToSuperview()
      $0.bottom.equalToSuperview()
      $0.height.equalTo(view.bounds.height + 100)
    }
  }
}

// MARK: - CollectionViewDataSourse,Delegate

extension ProfileViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return userPosts?.count ?? 0
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? ImageCollectionViewCell
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
  
  func followersTapped(userList: [UserStruct], title: String) {
    self.navigationController?.pushViewController(UsersListViewController(userList: userList, title: title, token: token), animated: true)
  }
  
  func followingTapped(userList: [UserStruct], title: String) {
    self.navigationController?.pushViewController(UsersListViewController(userList: userList, title: title, token: token), animated: true)
  }
}
//MARK: - Activity indicator methods

extension ProfileViewController {
  func showIndicator() {
    view.addSubview(dimmedView)
    dimmedView.snp.makeConstraints{
      $0.edges.equalToSuperview()
    }
    
    dimmedView.addSubview(indicator)
    indicator.startAnimating()
    indicator.snp.makeConstraints{
      $0.center.equalToSuperview()
    }
  }
  
  func hideIndicator() {
    indicator.stopAnimating()
    indicator.hidesWhenStopped = true
    indicator.removeFromSuperview()
    dimmedView.removeFromSuperview()
  }
}
// MARK: - LogOutButton handler

extension ProfileViewController {
  @objc private func logOutButtonTapped() {
    
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
          let authenticationController = AuthoriseViewController()
          UIApplication.shared.windows.first?.rootViewController = authenticationController
        }
      }
      
    case .offline:
      dataManager.deleteAll(entity: Post.self)
      dataManager.deleteAll(entity: User.self)
      
      DispatchQueue.main.async {
        let authenticationController = AuthoriseViewController()
        UIApplication.shared.windows.first?.rootViewController = authenticationController
      }
    }
  }
  
  private func configureLogOutButton() {
    switch networkMode {
    
    case .online:
      guard let user = user else {return}
      
      checkIsCurrentUser(user: user) { [weak self] isCurrentUser in
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
  
  private func checkIsCurrentUser(user: UserStruct, handler: @escaping (Bool) -> Void) {
    let currentUserRequest = NetworkManager.shared.currentUserRequest(token: token)
    
    NetworkManager.shared.performRequest(request: currentUserRequest,
                                         session: session)
    { [weak self] (result) in
      switch result {
      
      case .success(let data):
        guard let currenUser = NetworkManager.shared.parseJSON(jsonData: data,
                                                               toType: UserStruct.self) else {return}
        if self?.user?.id == currenUser.id  {
          handler(true)
        }
        
      case .failure(let error):
        DispatchQueue.main.async {
          self?.showAlert(error: error)
        }
      }
    }
  }
}
// MARK: - Get Posts

extension ProfileViewController {
  private func getUserPosts() {
    switch networkMode {
    
    case .online:
      guard let user = user else {return}
      
      let userPostsRequest = NetworkManager.shared.getPostsByUserRequest(withUserID: user.id,
                                                                         token: token)
      NetworkManager.shared.performRequest(request: userPostsRequest,
                                           session: session) {
        [weak self] (result) in
        switch result {
        
        case .success(let data):
          guard let posts = NetworkManager.shared.parseJSON(jsonData: data,
                                                            toType: [PostStruct].self) else {return}
          self?.userPosts = posts.reversed()
          
          DispatchQueue.main.async {
            self?.userImagesCollectionView.reloadData()
            self?.hideIndicator()
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
            self?.showAlert(error: error)
          }
        }
      }
      
    case .offline:
      guard let user = user else {return}
      userPosts = []
      
      let predicate = NSPredicate(format: "author == %@", user.id)
      let sortDescriptor = NSSortDescriptor(key: #keyPath(Post.createdTime), ascending: false)
      
      let fetchedPosts = dataManager.fetchData(for: Post.self,
                                               predicate: predicate,
                                               sortDescriptor: sortDescriptor)
      let converter = Converter()
      
      for post in fetchedPosts {
        guard let postStruct = converter.convertToStruct(post: post) else {return}
        userPosts?.append(postStruct)
      }
      
      userImagesCollectionView.reloadData()
      hideIndicator()
    }
  }
}
