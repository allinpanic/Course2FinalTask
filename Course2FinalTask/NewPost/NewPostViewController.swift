//
//  NewPostViewController.swift
//  Course2FinalTask
//
//  Created by Rodianov on 12.05.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit

final class NewPostViewController: UIViewController {
  var minImages: [UIImage?] = []
  let reusableCellID = "smallImageCell"
  
  private lazy var imagesCollectionView: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    layout.minimumInteritemSpacing = 0
    layout.minimumLineSpacing = 0
    let collectionView = UICollectionView(frame: .zero , collectionViewLayout: layout)
    collectionView.backgroundColor = .white
    collectionView.register(NewImageThumbnailCell.self, forCellWithReuseIdentifier: reusableCellID)
    collectionView.isScrollEnabled = true
    return collectionView
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupLayout()
    
    imagesCollectionView.dataSource = self
    imagesCollectionView.delegate = self
    
    minImages = [UIImage(named: "new1"), UIImage(named: "new2"), UIImage(named: "new3" ), UIImage(named: "new4"), UIImage(named: "new5"), UIImage(named: "new6"), UIImage(named: "new7"), UIImage(named: "new8")]
  }
}

extension NewPostViewController {
  private func setupLayout() {
    self.navigationItem.title = "New Post"
    view.backgroundColor = .white
    view.addSubview(imagesCollectionView)
    
    imagesCollectionView.snp.makeConstraints{
      $0.edges.equalToSuperview()
    }
  }
}
//MARK: - CollectionView DataSource Delegate

extension NewPostViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    minImages.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reusableCellID, for: indexPath) as? NewImageThumbnailCell else {return UICollectionViewCell()}
    cell.imageView.image = minImages[indexPath.row]
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: view.frame.width/3, height: view.frame.width/3)
  }
 
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    if let image = minImages[indexPath.row] {
      self.navigationController?.pushViewController(FilterImageViewController(image: image, index: indexPath.row), animated: true)
    }
  }
}
