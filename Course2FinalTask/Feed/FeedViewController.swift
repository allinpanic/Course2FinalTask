//
//  FeedViewController.swift
//  Course2FinalTask
//
//  Created by Rodianov on 06.03.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit

final class FeedViewController: UIViewController {
  var networkMode: NetworkMode = .online
  var dataManager: CoreDataManager!
  
//MARK: - Properties
  private let session = URLSession.shared
  private let token: String
  
  private lazy var feedTableView: UITableView = {
    let tableView = UITableView()
    tableView.backgroundColor = .white
    tableView.separatorStyle = .none
    tableView.allowsSelection = false
    tableView.register(FeedPostCell.self, forCellReuseIdentifier: reuseIdentifier)
    return tableView
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
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    feedTableView.dataSource = self
    setupLayout()
    
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

extension FeedViewController {
  func setupLayout() {
    view.addSubview(feedTableView)
    
    feedTableView.snp.makeConstraints{
      $0.edges.equalToSuperview()
    }
  }
}
//MARK: - TableView DataSource

extension FeedViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return posts.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = feedTableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as? FeedPostCell
      else { return UITableViewCell() }
    
    cell.token = token
    cell.networkMode = networkMode
    cell.post = posts[indexPath.row]
    cell.index = indexPath.row
    cell.delegate = self
    
    return cell
  }
}
//MARK: - PostCell Delegate methods

extension FeedViewController: FeedPostCellDelegate {
  func likeButtonPressed(post: PostStruct, index: Int) {
    posts[index] = post
  }
  
  func postHeaderViewTapped(user: UserStruct) {
    let profileViewController = ProfileViewController(user: user, token: token)
    profileViewController.dataManager = dataManager
    profileViewController.networkMode = networkMode
    self.navigationController?.pushViewController(profileViewController, animated: true)
  }
  
  func postImageDoubleTapped(imageView: UIImageView) {
    imageView.isHidden = false
    animateImage(imageView: imageView)
  }
  
  func likesLabelTapped(users: [UserStruct], title: String) {
    self.navigationController?.pushViewController(UsersListViewController(userList: users, title: title, token: token), animated: true)
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
}
// MARK: - Activity Indicator

extension FeedViewController {
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
// MARK: - Get Posts

extension FeedViewController {
  private func getPosts() {
    
    switch networkMode {
    
    case .online:
      let postsRequest = NetworkManager.shared.getFeedRequest(token: token)
      
      NetworkManager.shared.performRequest(request: postsRequest, session: session) {
        [weak self] (result) in
        
        switch result {
        
        case .success(let data):
          guard let posts = NetworkManager.shared.parseJSON(jsonData: data, toType: [PostStruct].self) else {return}
          
          self?.posts = posts
          
          DispatchQueue.main.async {
            self?.feedTableView.reloadData()
            self?.hideIndicator()
          }
          
          for  post in posts {            
            self?.getLikesCount(post: post) { (likes) in
              self?.dataManager.savePost(post: post, likesCount: likes)
            }
          }
          
        case .failure(let error):
          DispatchQueue.main.async {
            self?.showAlert(error: error)
          }
        }
      }
      
    case .offline:
      let sortDescriptor = NSSortDescriptor(key: #keyPath(Post.createdTime), ascending: false)
      let converter = Converter()
      
      let fetchedPosts = dataManager.fetchData(for: Post.self, sortDescriptor: sortDescriptor)
      
      for post in fetchedPosts {
        guard let postStruct = converter.convertToStruct(post: post) else {return}
        
        posts.append(postStruct)
      }
      
      feedTableView.reloadData()
      hideIndicator()
    }
  }
  
  private func getLikesCount(post: PostStruct, handler: @escaping (Int) -> Void) {
    let usersLikedRequest = NetworkManager.shared.getUsersLikedPostRequest(withPostID: post.id,
                                                                           token: token)
    
    NetworkManager.shared.performRequest(request: usersLikedRequest,
                                         session: URLSession.shared)
    { [weak self] (result) in
      switch result {
      
      case .success(let data):
        guard let users = NetworkManager.shared.parseJSON(jsonData: data,
                                                          toType: [UserStruct].self) else {return}
        
        handler(users.count)
        
      case .failure(let error):
        DispatchQueue.main.async {
          self?.showAlert(error: error)
        }
      }
    }
  }
}
