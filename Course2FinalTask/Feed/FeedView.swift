//
//  FeedView.swift
//  Course2FinalTask
//
//  Created by Rodianov on 07.06.2021.
//  Copyright © 2021 e-Legion. All rights reserved.
//

import UIKit

//protocol FeedViewDelegate: class, UITableViewDelegate, UITableViewDataSource {
//
//}
// MARK: - FeedViewProtocol

protocol FeedViewProtocol: UIView {
  var feedTableView: UITableView { get set }
  var indicator: UIActivityIndicatorView { get }
  var dimmedView: UIView { get }
//  var delegate: FeedViewDelegate? { get set }
  func updateLikesCount(likesCount: Int, index: Int)
  func updatePost(post: PostData, atIndex: Int)
  
  func showIndicator()
  func hideIndicator()
}
// MARK: - FeedView

final class FeedView: UIView, FeedViewProtocol {
//  weak var delegate: FeedViewDelegate?
  private let reuseIdentifier = "postCell"
  
  lazy var feedTableView: UITableView = {
    let tableView = UITableView()
    tableView.backgroundColor = .white
    tableView.separatorStyle = .none
    tableView.allowsSelection = false
    tableView.register(FeedPostCell.self, forCellReuseIdentifier: reuseIdentifier)
    return tableView
  }()
  
   var indicator: UIActivityIndicatorView = {
    let indicator = UIActivityIndicatorView()
    indicator.style = .white
    return indicator
  }()
  
   var dimmedView: UIView = {
    let view = UIView()
    view.backgroundColor = .black
    view.alpha = 0.7
    return view
  }()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupLayout()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setupLayout() {
    addSubview(feedTableView)
    
    feedTableView.snp.makeConstraints{
      $0.edges.equalToSuperview()
    }
  }
  
  func updateLikesCount(likesCount: Int, index: Int) {
    let indexPath = IndexPath(row: index, section: 0)
    guard let cell = feedTableView.cellForRow(at: indexPath) as? FeedPostCell else {return}
    cell.likesCount = likesCount
  }
  
  func updatePost(post: PostData, atIndex index: Int) {
    let indexPath = IndexPath(row: index, section: 0)
    guard let cell = feedTableView.cellForRow(at: indexPath) as? FeedPostCell else {return}
    cell.post = post
  }
  
  func showIndicator() {
    addSubview(dimmedView)
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
