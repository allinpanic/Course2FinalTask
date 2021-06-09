//
//  FeedViewController.swift
//  Course2FinalTask
//
//  Created by Rodianov on 06.03.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit
// MARK: - FeedViewController

final class FeedViewController: UIViewController {

  var networkMode: NetworkMode = .online
  var dataManager: CoreDataManager!
  var feedModel: FeedModel!
  
  private let token: String
  private lazy var feedView: FeedViewProtocol = {
    let view = FeedView()
    view.feedTableView.dataSource = self    
    return view
  }()
  private let reuseIdentifier = "postCell"
  private var posts: [PostData] = []
  
  init(token: String) {
    self.token = token
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  //MARK: - View Life Cycle methods
  
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
    cell.index = indexPath.row
    cell.post = posts[indexPath.row]
//    cell.index = indexPath.row
    cell.delegate = self
    
    return cell
  }
}
//MARK: - PostCell Delegate methods

extension FeedViewController: FeedPostCellDelegate {
  func like(postID: String, index: Int) {
    feedModel.likePost(withPostID: postID) { [weak self] (post) in
      self?.posts[index] = post
      self?.feedView.updatePost(post: post, atIndex: index)
    }
  }
  
  func dislike(postId: String, index: Int) {
    feedModel.unlikePost(withPostID: postId) { [weak self] (post) in
      self?.posts[index] = post
      self?.feedView.updatePost(post: post, atIndex: index)
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
      
      DispatchQueue.main.async {
        self?.navigateToUserList(userList: users, title: title)
      }
    }
  }
  
  func likeButtonPressed(post: PostData, index: Int) {
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

  private func navigateToUserList(userList: [UserData], title: String) {
    
    let userListController = Builder.createUserListViewController(userList: userList,
                                                                  dataManager: dataManager,
                                                                  networkMode: networkMode,
                                                                  token: token,
                                                                  title: title)
    
    navigationController?.pushViewController(userListController, animated: true)
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
// MARK: - FeedModelDelegate

extension FeedViewController: FeedModelDelegate {
  func getError(error: NetworkError) {
    showAlert(error: error)
  }

  func navigateToProfileVC(user: UserData) {
    let profileViewController = Builder.createProfileViewController(user: user,
                                                                    dataManager: dataManager,
                                                                    networkMode: networkMode,
                                                                    token: token)

    self.navigationController?.pushViewController(profileViewController, animated: true)
  }
  
  func showIndicator() {
    feedView.showIndicator()
  }
  
  func hideIndicator() {
    feedView.hideIndicator()
  }
}
