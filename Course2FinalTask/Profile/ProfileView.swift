//
//  ProfileView.swift
//  Course2FinalTask
//
//  Created by Rodianov on 08.06.2021.
//  Copyright © 2021 e-Legion. All rights reserved.
//

import UIKit

protocol ProfileViewProtocol: UIView {
  var user: UserStruct! { get set }
  var indicator: UIActivityIndicatorView { get }
  var dimmedView: UIView { get }
  var userImagesCollectionView: UICollectionView { get set }
  var reuseIdentifier: String { get }
  func showFollowButton()
  func hideFollowButton()
  func updateProfileInfoView(user: UserStruct, title: String)
}

final class ProfileView: UIView, ProfileViewProtocol {
  var user: UserStruct! {
    didSet {
      profileInfoView.user = user
      profileInfoView.fillProfileInfo(networkMode: networkMode) { (_) in }
    }
  }
  
  var networkMode: NetworkMode = .online  
  var reuseIdentifier = "imageCell"
  
  private lazy var profileScrollView: UIScrollView = {
    let scrollView = UIScrollView()
    scrollView.backgroundColor = .white
    scrollView.isScrollEnabled = true
    return scrollView
  }()
  
  lazy var userImagesCollectionView: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    layout.minimumInteritemSpacing = 0
    layout.minimumLineSpacing = 0
    let collectionView = UICollectionView(frame: .zero , collectionViewLayout: layout)
    collectionView.backgroundColor = .white
    collectionView.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
    collectionView.isScrollEnabled = false
    return collectionView
  }()
  
  lazy var profileInfoView: ProfileInfoView = {
    let profileInfo = ProfileInfoView()
    profileInfo.backgroundColor = .white
    return profileInfo
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
    addSubview(profileScrollView)
    profileScrollView.addSubview(profileInfoView)
    profileScrollView.addSubview(userImagesCollectionView)
    
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
      $0.height.equalTo(UIScreen.main.bounds.height + 100)
    }
  }
  
  func showFollowButton() {
    profileInfoView.followButton.isHidden = false
  }
  
  func hideFollowButton() {
    profileInfoView.followButton.isHidden = true
  }
  
  func updateProfileInfoView(user: UserStruct, title: String) {
    profileInfoView.user = user
    profileInfoView.followersLabel.text = "Followers: \(user.followedByCount)"
    profileInfoView.followButton.setTitle("\(title)", for: .normal)
  }
}
