//
//  UserCell.swift
//  Course2FinalTask
//
//  Created by Rodianov on 13.03.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit

final class UserTableViewCell: UITableViewCell {
  var user: UserData?
  
  private var userAvatarImageView: UIImageView = {
    let imageView = UIImageView()
    return imageView
  }()
  
  private var userNameLabel: UILabel = {
    let label = UILabel()
    label.font = .systemFont(ofSize: 17)
    label.textColor = .black
    return label
  }()
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setupLayout()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }  
}

extension UserTableViewCell {
  private func setupLayout() {
    contentView.addSubview(userAvatarImageView)
    contentView.addSubview(userNameLabel)
    
    userAvatarImageView.snp.makeConstraints{
      $0.leading.equalToSuperview().offset(15)      
      $0.top.bottom.equalTo(contentView)
      $0.width.equalTo(contentView.snp.height)
    }
    
    userNameLabel.snp.makeConstraints{
      $0.leading.equalTo(userAvatarImageView.snp.trailing).offset(16)
      $0.centerY.equalTo(userAvatarImageView)
    }
  }
  
  func configureCell() {
    if let user = user {
      guard let imageURL = URL(string: user.avatar) else {return}
      userAvatarImageView.kf.setImage(with: imageURL)
      userNameLabel.text = user.fullName
    }
  }
}
