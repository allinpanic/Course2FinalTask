//
//  ProfileView.swift
//  Course2FinalTask
//
//  Created by Rodianov on 08.06.2021.
//  Copyright © 2021 e-Legion. All rights reserved.
//

import UIKit
// MARK: - ProfileViewProtocol

protocol ProfileViewProtocol: UIView {
  var user: UserData! { get set }
  var userImagesCollectionView: UICollectionView { get set }
  var reuseIdentifier: String { get }
  func showFollowButton()
  func hideFollowButton()
  func updateProfileInfoView(user: UserData, title: String)
  func setLogOutButton(viewController: UIViewController?, action: Selector)
  func showIndicator()
  func hideIndicator()
}
// MARK: - ProfileView

final class ProfileView: UIView, ProfileViewProtocol {
  var user: UserData! {
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
  // MARK: - Inits
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupLayout()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  // MARK: - SetupLayout
  
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
  // MARK: - Protocol Methods
  
  func showFollowButton() {
    profileInfoView.followButton.isHidden = false
  }
  
  func hideFollowButton() {
    profileInfoView.followButton.isHidden = true
  }
  
  func updateProfileInfoView(user: UserData, title: String) {
    profileInfoView.user = user
    profileInfoView.followersLabel.text = "Followers: \(user.followedByCount)"
    profileInfoView.followButton.setTitle("\(title)", for: .normal)
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
  
  func setLogOutButton(viewController: UIViewController?, action: Selector) {
    let logOutButton = UIBarButtonItem(title: "Log Out",
                                       style: .plain,
                                       target: viewController,
                                       action: action)
    viewController?.navigationItem.rightBarButtonItem = logOutButton
  }
}
