//
//  NewPostView.swift
//  Course2FinalTask
//
//  Created by Rodianov on 09.06.2021.
//  Copyright © 2021 e-Legion. All rights reserved.
//

import UIKit
// MARK: - NewPostViewProtocol

protocol NewPostViewProtocol: UIView {
  var imagesCollectionView: UICollectionView { get set }
  var reusableCellID: String { get }
}
// MARK: - NewPostView

final class NewPostView: UIView, NewPostViewProtocol {
  var reusableCellID = "smallImageCell"
  
  lazy var imagesCollectionView: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    layout.minimumInteritemSpacing = 0
    layout.minimumLineSpacing = 0
    let collectionView = UICollectionView(frame: .zero , collectionViewLayout: layout)
    collectionView.backgroundColor = .white
    collectionView.register(NewImageThumbnailCell.self, forCellWithReuseIdentifier: reusableCellID)
    collectionView.isScrollEnabled = true
    return collectionView
  }()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    setupLayout()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setupLayout() {
    
    backgroundColor = .white
    addSubview(imagesCollectionView)
    
    imagesCollectionView.snp.makeConstraints{
      $0.edges.equalToSuperview()
    }
  }
}
