//
//  UsersListViewController.swift
//  Course2FinalTask
//
//  Created by Rodianov on 13.03.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit

final class UsersListViewController: UIViewController {
  
  //var networkMode: NetworkMode = .online

  private let token: String
  
  private lazy var usersTableView: UITableView = {
    let tableView = UITableView()
    tableView.register(UserTableViewCell.self, forCellReuseIdentifier: "userCell")
    tableView.dataSource = self
    tableView.delegate = self
    return tableView
  }()
  
  private var userList: [UserStruct]
  
  init(userList: [UserStruct], title: String, token: String) {
    self.userList = userList
    self.token = token
    super.init(nibName: nil, bundle: nil)
    self.navigationItem.title = title
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupLayout()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    if let indexPath = usersTableView.indexPathForSelectedRow {
      usersTableView.deselectRow(at: indexPath , animated: true)
    }
  }
}

extension UsersListViewController {
  private func setupLayout() {
    view.addSubview(usersTableView)
    
    usersTableView.snp.makeConstraints{
      $0.edges.equalToSuperview()
    }
  }
}

// MARK: - TableView DataSource, Delegate

extension UsersListViewController: UITableViewDataSource, UITableViewDelegate {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    userList.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as? UserTableViewCell
      else {return UITableViewCell()}
    let user = userList[indexPath.row]
    cell.user = user
    cell.configureCell()
    return cell
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 45
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
     let user = userList[indexPath.row]
      self.navigationController?.pushViewController(ProfileViewController(user: user, token: token), animated: true)
  }
}
