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
  private var posts: [Post] = []
  
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
  }
//MARK: - ViewWillAppear
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    showIndicator()
    getPosts()
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
    cell.post = posts[indexPath.row]
    cell.delegate = self
    
    return cell
  }
}
//MARK: - PostCell Delegate methods

extension FeedViewController: FeedPostCellDelegate {
  func showAlert() {
    let alert = UIAlertController(title: "Unknokn error!",
                                  message: "Please, try again later",
                                  preferredStyle: .alert)
    
    let alertAction = UIAlertAction(title: "OK",
                                    style: .default,
                                    handler: { action in
                                      alert.dismiss(animated: true, completion: nil)
    })
    alert.addAction(alertAction)
    present(alert, animated: true, completion: nil)
  }
  
  func postHeaderViewTapped(user: User) {
    self.navigationController?.pushViewController(ProfileViewController(user: user, token: token), animated: true)
  }
  
  func postImageDoubleTapped(imageView: UIImageView) {
    imageView.isHidden = false
    animateImage(imageView: imageView)
  }
  
  func likesLabelTapped(users: [User], title: String) {
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

extension FeedViewController {
  private func getPosts() {
    
    let postsRequest = NetworkManager.shared.getFeedRequest(token: token)
    
    NetworkManager.shared.performRequest(request: postsRequest, session: session) {
      [weak self] (result) in
      
      switch result {
        
      case .success(let data):
        guard let posts = NetworkManager.shared.parseJSON(jsonData: data, toType: [Post].self) else {return}
        
        self?.posts = posts
        
        DispatchQueue.main.async {
          self?.feedTableView.reloadData()
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
// MARK: - Show alert

extension FeedViewController {
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
