//
//  UserListView.swift
//  Course2FinalTask
//
//  Created by Rodianov on 09.06.2021.
//  Copyright © 2021 e-Legion. All rights reserved.
//

import UIKit
// MARK: - UserListViewProtocol

protocol UserListViewProtocol: UIView {
  var usersTableView: UITableView { get set }
  func deselectCurrentRow()
}
// MARK: - UserListView

final class UserListView: UIView, UserListViewProtocol {
  
  lazy var usersTableView: UITableView = {
    let tableView = UITableView()
    tableView.register(UserTableViewCell.self, forCellReuseIdentifier: "userCell")
    return tableView
  }()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupLayout()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setupLayout() {
    addSubview(usersTableView)
    
    usersTableView.snp.makeConstraints{
      $0.edges.equalToSuperview()
    }
  }
  
  func deselectCurrentRow() {
    if let indexPath = usersTableView.indexPathForSelectedRow {
      usersTableView.deselectRow(at: indexPath , animated: true)
    }
  }
}
