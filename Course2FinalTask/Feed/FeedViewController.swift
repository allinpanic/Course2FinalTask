//
//  FeedViewController.swift
//  Course2FinalTask
//
//  Created by Rodianov on 06.03.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit

final class FeedViewController: UIViewController {
  //MARK: - Properties
  var networkMode: NetworkMode = .online
  var dataManager: CoreDataManager!
  var feedModel: FeedModel!
  
  private let token: String
  private var feedView: FeedViewProtocol = FeedView()
  private let reuseIdentifier = "postCell"
  private var posts: [PostStruct] = []
  
  init(token: String) {
    self.token = token
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  //MARK: - ViewDidLoad
  
  override func loadView() {
    super.loadView()
    
    view = feedView
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    feedView.feedTableView.dataSource = self
    feedModel.delegate = self
    
    showIndicator()
    getPosts()
  }
//MARK: - ViewWillAppear
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    if networkMode == .online {
      showIndicator()
      getPosts()
    }
  }
}
//MARK: - TableView DataSource

extension FeedViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return posts.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = feedView.feedTableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as? FeedPostCell
      else { return UITableViewCell() }
    
    cell.networkMode = networkMode
    cell.post = posts[indexPath.row]
    cell.index = indexPath.row
    cell.delegate = self
    
    return cell
  }
}
//MARK: - PostCell Delegate methods

extension FeedViewController: FeedPostCellDelegate {
  func like(postID: String, index: Int) {
    feedModel.likePost(withPostID: postID) { [weak self] (post) in
      self?.posts[index] = post
    }
  }
  
  func dislike(postId: String, index: Int) {
    feedModel.unlikePost(withPostID: postId) { [weak self] (post) in
      self?.posts[index] = post
    }
  }
  
  func postHeaderViewTapped(userID: String) {
    feedModel.getUser(withUserID: userID) { [weak self] (user) in
      self?.navigateToProfileVC(user: user)
    }
  }
  
  func getLikesCount(postID: String, index: Int) {
    feedModel.getLikes(withPostID: postID) { [weak self] (users) in
      let likesCount = users.count
      
      DispatchQueue.main.async {
        self?.feedView.updateLikesCount(likesCount: likesCount, index: index) //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
      }
    }
  }
  
  func likesLabelTapped(postID: String, title: String) {
    feedModel.getLikes(withPostID: postID) { [weak self] (users) in
//      guard let token = self?.token else {return}
      
      DispatchQueue.main.async {
        self?.navigateToUserList(userList: users, title: title)
//        let userListController = UsersListViewController(userList: users, title: title, token: token, networkMode: networkMode)
//        userListController.dataManager = dataManager
//
//        self?.navigationController?.pushViewController(UsersListViewController(userList: users,
//                                                                               title: title,
//                                                                               token: token, networkMode: self?.networkMode),
//                                                       animated: true)
      }
    }
  }
  
  func likeButtonPressed(post: PostStruct, index: Int) {
    posts[index] = post
  }
  
  func postImageDoubleTapped(imageView: UIImageView) {
    imageView.isHidden = false
    animateImage(imageView: imageView)
  }
}
//MARK: - Animation

extension FeedViewController {
  private func animateImage (imageView: UIImageView) {
    let animation = CAKeyframeAnimation(keyPath: #keyPath(CALayer.opacity))
    animation.values = [0, 1, 1, 0]
    animation.keyTimes = [0, 0.17, 0.7, 1]
    animation.duration = 0.6
    animation.timingFunctions = [CAMediaTimingFunction(name: .linear),
                                 CAMediaTimingFunction(name: .linear),
                                 CAMediaTimingFunction(name: .easeOut)]
    imageView.layer.add(animation, forKey: "opacity")
    imageView.layer.opacity = 0
  }
  
  
  
  
  
  
  private func navigateToUserList(userList: [UserStruct], title: String) {
    let userListController = UsersListViewController(userList: userList, title: title, token: token, networkMode: networkMode)
    userListController.dataManager = dataManager
    
    navigationController?.pushViewController(userListController, animated: true)
  }
}
// MARK: - Activity Indicator

extension FeedViewController {
  func showIndicator() {
    view.addSubview(feedView.dimmedView)
    feedView.dimmedView.snp.makeConstraints{
      $0.edges.equalToSuperview()
    }
    
    feedView.dimmedView.addSubview(feedView.indicator)
    feedView.indicator.startAnimating()
    feedView.indicator.snp.makeConstraints{
      $0.center.equalToSuperview()
    }
  }
  
  func hideIndicator() {
    feedView.indicator.stopAnimating()
    feedView.indicator.hidesWhenStopped = true
    feedView.indicator.removeFromSuperview()
    feedView.dimmedView.removeFromSuperview()
  }
}
// MARK: - Get Posts

extension FeedViewController {
  private func getPosts() {
    
    feedModel.getFeed(token: token) { [weak self] (posts) in
      self?.posts = posts
      self?.feedView.feedTableView.reloadData()
      self?.hideIndicator()
    }
  }
  
//  private func getLikesCount(post: PostStruct, handler: @escaping (Int) -> Void) {
//    let usersLikedRequest = NetworkManager.shared.getUsersLikedPostRequest(withPostID: post.id,
//                                                                           token: token)
//
//    NetworkManager.shared.performRequest(request: usersLikedRequest,
//                                         session: URLSession.shared)
//    { [weak self] (result) in
//      switch result {
//
//      case .success(let data):
//        guard let users = NetworkManager.shared.parseJSON(jsonData: data,
//                                                          toType: [UserStruct].self) else {return}
//
//        handler(users.count)
//
//      case .failure(let error):
//        DispatchQueue.main.async {
//          self?.showAlert(error: error)
//        }
//      }
//    }
//  }
}

extension FeedViewController: FeedModelDelegate {
  func getError(error: NetworkError) {
    showAlert(error: error)
  }

  func navigateToProfileVC(user: UserStruct) {
    let profileViewController = ProfileViewController(user: user, token: token)
    let profileModel = ProfileModel(networkMode: networkMode, token: token)
    profileModel.dataManager = dataManager
//    profileViewController.dataManager = dataManager
    profileViewController.networkMode = networkMode
    profileViewController.profileModel = profileModel
    self.navigationController?.pushViewController(profileViewController, animated: true)
  }
}
