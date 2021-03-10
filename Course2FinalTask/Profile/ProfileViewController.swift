//
//  ProfileViewController.swift
//  Course2FinalTask
//
//  Created by Rodianov on 07.03.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit

final class ProfileViewController: UIViewController {

  var user: User?
// MARK: - Private properties
  
  private var token: String
  private let session = URLSession.shared
  private var userPosts: [Post]?
  
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
  
  init (user: User?, token: String) {
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
    
    showIndicator()
    getUserPosts()
    
    profileInfoView.user = user
    profileInfoView.token = token
    profileInfoView.fillProfileInfo()
  }
}
//MARK: - Layout

extension ProfileViewController {
  private func setupLayout() {
    view.addSubview(profileScrollView)
    profileScrollView.addSubview(profileInfoView)
    profileScrollView.addSubview(userImagesCollectionView)
    
    self.navigationItem.title = user?.username
    configureLogOutButton()
    
    showIndicator()
    getUserPosts()
    
    profileInfoView.user = user
    profileInfoView.token = token
    profileInfoView.fillProfileInfo()
    
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
    
    if let imageString = userPosts?[indexPath.item].image {
      if let imageURL = URL(string: (imageString)) {
        cell.imageView.kf.setImage(with: imageURL)
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
  
  func followersTapped(userList: [User], title: String) {
    self.navigationController?.pushViewController(UsersListViewController(userList: userList, title: title, token: token), animated: true)
  }
  
  func followingTapped(userList: [User], title: String) {
    self.navigationController?.pushViewController(UsersListViewController(userList: userList, title: title, token: token), animated: true)
  }
  
  func showAlert() {
    let alert = UIAlertController(title: "Unknown Error", message: "Please, try again later", preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
      [weak self] action in
      alert.dismiss(animated: true, completion: nil)
      self?.navigationController?.popViewController(animated: true)
    }))
    self.present(alert, animated: true, completion: nil)
  }
  
  func showAlert(error: NetworkError) {
    let title: String
    let statusCode: Int
    
    switch error {
    case .badRequest(let code):
      title = "Bad Request"
      statusCode = code
      
    case .unathorized(let code):
      title = "Unathorized"
      statusCode = code
      
    case .notFound(let code):
      title = "Not Found"
      statusCode = code
      
    case .notAcceptable(let code):
      title = "Not acceptable"
      statusCode = code
      
    case .unprocessable(let code):
      title = "Unprocessable"
      statusCode = code
      
    case .transferError(let code):
      title = "Transfer Error"
      statusCode = code
    }
    
    let alertVC = UIAlertController(title: title, message: "\(statusCode)", preferredStyle: .alert)
    let action = UIAlertAction(title: "OK", style: .cancel) { (action) in
      alertVC.dismiss(animated: true, completion: nil)
    }
    
    alertVC.addAction(action)
    present(alertVC, animated: true, completion: nil)
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
    
    let signOutRequest = NetworkManager.shared.signOutRequest(token: token)
    
    NetworkManager.shared.performRequest(request: signOutRequest,
                                         session: session)
    { (data) in
      DispatchQueue.main.async {
        let authenticationController = AuthoriseViewController()
        UIApplication.shared.windows.first?.rootViewController = authenticationController
      }
    }
  }
  
  private func configureLogOutButton() {
    let currentUserRequest = NetworkManager.shared.currentUserRequest(token: token)
    
    NetworkManager.shared.performRequest(request: currentUserRequest,
                                         session: session)
    { [weak self] (result) in
      
      switch result {
      case .success(let data):
        guard let currenUser = NetworkManager.shared.parseJSON(jsonData: data, toType: User.self) else {return}
        
        if self?.user?.id == currenUser.id  {
          DispatchQueue.main.async {
            let logOutButton = UIBarButtonItem(title: "Log Out",
                                               style: .plain,
                                               target: self,
                                               action: #selector(self?.logOutButtonTapped))
            
            self?.navigationItem.rightBarButtonItem = logOutButton
          }
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
    
    guard let user = user else {return}
    
   let userPostsRequest = NetworkManager.shared.getPostsByUserRequest(withUserID: user.id, token: token)
    
    NetworkManager.shared.performRequest(request: userPostsRequest, session: session) {
      [weak self] (result) in
      
      switch result {
        
      case .success(let data):
        guard let posts = NetworkManager.shared.parseJSON(jsonData: data, toType: [Post].self) else {return}
        
        self?.userPosts = posts.reversed()
        DispatchQueue.main.async {
          self?.userImagesCollectionView.reloadData()
          self?.hideIndicator()
        }
        
      case .failure(let error):
        DispatchQueue.main.async {
          self?.showAlert(error: error)
        }
      }
    }
  }
}
