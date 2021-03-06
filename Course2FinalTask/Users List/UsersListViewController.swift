//
//  UsersListViewController.swift
//  Course2FinalTask
//
//  Created by Rodianov on 13.03.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit
// MARK: - UsersListViewController

final class UsersListViewController: UIViewController {

  var dataManager: CoreDataManager!
  
  lazy var userListView: UserListViewProtocol = {
    let view = UserListView()
    view.usersTableView.delegate = self
    view.usersTableView.dataSource = self
    return view
  }()
  
  private let token: String
  private var networkMode: NetworkMode
  private var userList: [UserData]
  // MARK: - Inits
  
  init(userList: [UserData], title: String, token: String, networkMode: NetworkMode) {
    self.userList = userList
    self.token = token
    self.networkMode = networkMode
    super.init(nibName: nil, bundle: nil)
    self.navigationItem.title = title
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func loadView() {
    super.loadView()
    view = userListView
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    userListView.deselectCurrentRow()
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
    
    let profileViewController = Builder.createProfileViewController(user: user,
                                                                    dataManager: dataManager,
                                                                    networkMode: networkMode,
                                                                    token: token)
    
    self.navigationController?.pushViewController(profileViewController, animated: true)
  }
}
