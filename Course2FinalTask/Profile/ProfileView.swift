//
//  ProfileView.swift
//  Course2FinalTask
//
//  Created by Rodianov on 08.06.2021.
//  Copyright © 2021 e-Legion. All rights reserved.
//

import UIKit

protocol ProfileViewDelegate: AnyObject, ProfileInfoViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate {
  <#requirements#>
}

protocol ProfileViewProtocol: class {
  var user: UserStruct! { get set }
  var delegate: ProfileViewDelegate! { get set }
}

final class ProfileView: UIView, ProfileViewProtocol {
  var user: UserStruct!
  weak var delegate: ProfileViewDelegate!
  
  private var reuseIdentifier = "imageCell"
  
  private lazy var profileScrollView: UIScrollView = {
    let scrollView = UIScrollView()
    scrollView.backgroundColor = .white
    scrollView.isScrollEnabled = true
    return scrollView
  }()
  
  private lazy var userImagesCollectionView: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    layout.minimumInteritemSpacing = 0
    layout.minimumLineSpacing = 0
    let collectionView = UICollectionView(frame: .zero , collectionViewLayout: layout)
    collectionView.backgroundColor = .white
    collectionView.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
    collectionView.isScrollEnabled = false
    collectionView.delegate = self.delegate
    collectionView.dataSource = self.delegate
    return collectionView
  }()
  
  private lazy var profileInfoView: ProfileInfoView = {
    let profileInfo = ProfileInfoView()
    profileInfo.backgroundColor = .white
    profileInfo.delegate = self.delegate
//    profileInfo.networkMode = self.networkMode
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
    
//    self.navigationItem.title = user?.username
//
//    showIndicator()
//    getUserPosts()
    
    profileInfoView.user = user
//    profileInfoView.token = token
    profileInfoView.fillProfileInfo{ _ in}
    
    configureLogOutButton()
    
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
      $0.height.equalTo(bounds.height + 100)
    }
  }
  
  private func configureLogOutButton() {
    
  }
}
