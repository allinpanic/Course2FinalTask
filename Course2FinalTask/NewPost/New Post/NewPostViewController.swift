//
//  NewPostViewController.swift
//  Course2FinalTask
//
//  Created by Rodianov on 12.05.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit
// MARK: - NewPostViewController

final class NewPostViewController: UIViewController {
  var networkMode: NetworkMode = .online
  
  private var minImages: [UIImage?] = []
  private var token: String
  
  private lazy var newPostView: NewPostViewProtocol = {
    let view = NewPostView()
    view.imagesCollectionView.delegate = self
    view.imagesCollectionView.dataSource = self
    return view
  }()
  
  init(token: String) {
    self.token = token
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func loadView() {
    super.loadView()
    view = newPostView
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.navigationItem.title = "New Post"
    
    minImages = [UIImage(named: "new1"), UIImage(named: "new2"), UIImage(named: "new3"), UIImage(named: "new4"), UIImage(named: "new5"), UIImage(named: "new6"), UIImage(named: "new7"), UIImage(named: "new8")]
  }
}
//MARK: - CollectionView DataSource Delegate

extension NewPostViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    minImages.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: newPostView.reusableCellID, for: indexPath) as? NewImageThumbnailCell else {return UICollectionViewCell()}
    cell.imageView.image = minImages[indexPath.row]
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: view.frame.width/3, height: view.frame.width/3)
  }
 
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    if let image = minImages[indexPath.row] {
      let filterImageViewController = Builder.createFilterImageController(image: image,
                                                                          index: indexPath.row,
                                                                          networkMode: networkMode,
                                                                          token: token)

      self.navigationController?.pushViewController(filterImageViewController, animated: true)
    }
  }
}
