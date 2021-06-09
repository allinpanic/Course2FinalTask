//
//  FilterImageView.swift
//  Course2FinalTask
//
//  Created by Rodianov on 09.06.2021.
//  Copyright © 2021 e-Legion. All rights reserved.
//

import UIKit

protocol FilterImageViewProtocol: UIView {
  var imageViewToFilter: UIImageView { get set }
  var reuseIdentifier: String { get }
  var filtersPreviewCollectionView: UICollectionView { get set }
  var image: UIImage! { get set }
  var dimmedView: UIView { get }
  var indicator: UIActivityIndicatorView { get }
}

final class FilterImageView: UIView, FilterImageViewProtocol {
  var reuseIdentifier = "filterThumbnail"
  
  var image: UIImage! {
    didSet {
      imageViewToFilter.image = image
    }
  }
  
  lazy var imageViewToFilter: UIImageView = {
    let imageView = UIImageView()
//    imageView.image = selectedImage
    imageView.contentMode = .scaleAspectFill
    return imageView
  }()
  
  lazy var filtersPreviewCollectionView: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .horizontal
    layout.minimumInteritemSpacing = 16
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    collectionView.backgroundColor = .white
    collectionView.register(FilteredThumbnailCell.self, forCellWithReuseIdentifier: reuseIdentifier)
//    collectionView.dataSource = self
//    collectionView.delegate = self
    return collectionView
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
    backgroundColor = .white
    addSubview(imageViewToFilter)
    addSubview(filtersPreviewCollectionView)
    
//    self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next",
//                                                             style: .plain,
//                                                             target: self,
//                                                             action: #selector(showAddDescriptionToPost))
    
    imageViewToFilter.snp.makeConstraints{
      $0.top.leading.trailing.equalTo(safeAreaLayoutGuide)
    }
    
    filtersPreviewCollectionView.snp.makeConstraints{
      $0.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).inset(16)
      $0.leading.trailing.equalToSuperview()
      $0.height.equalTo(120)
    }
  }
}
