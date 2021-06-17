//
//  FilterImageViewController.swift
//  Course2FinalTask
//
//  Created by Rodianov on 13.05.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit

final class FilterImageViewController: UIViewController {
// MARK: - Properties
  var token: String = ""
  var networkMode: NetworkMode = .online
  var filterImageModel: FilterImageModelProtocol!
  
  lazy var filterImageView: FilterImageViewProtocol = {
    let view = FilterImageView()
    view.image = selectedImage
    view.filtersPreviewCollectionView.delegate = self
    view.filtersPreviewCollectionView.dataSource = self
    return view
  }()
  
  private var selectedImage: UIImage
  private var index: Int
//  private let filterNames: [String] = []
  private var thumbnails: [UIImage] = []
// MARK: - Inits
  
  init(image: UIImage, index: Int) {
    self.selectedImage = image
    self.index = index
    super.init(nibName: nil, bundle: nil)
    self.navigationItem.title = "Filters"
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
// MARK: - ViewDidLoad
  
  override func loadView() {
    super.loadView()
    view = filterImageView
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    filterImageModel.delegate = self
    
    filterImageView.setRightBarButtonItem(viewController: self, action: #selector(showAddDescriptionToPost))
    
    thumbnails = filterImageModel.generateThumbnails(image: selectedImage)
    filterCollectionView()
  }
}
//MARK: - CollectionView Datasource, Delegate

extension FilterImageViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return filterImageModel.filtersCount()
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: filterImageView.reuseIdentifier, for: indexPath) as? FilteredThumbnailCell else {return UICollectionViewCell()}
    
    cell.image = thumbnails[indexPath.row]
    cell.filterName = filterImageModel.filterName(withIndex: indexPath.row)
    
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: 120, height: 120)
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let imageToFilter = self.selectedImage
    
    filterImageModel.filterImage(image: imageToFilter, filterIndex: indexPath.row) { [weak self] (filteredImage) in
      self?.filterImageView.image = filteredImage
    }
  }
}
// MARK: - ButtonHandler

extension FilterImageViewController {
  @objc private func showAddDescriptionToPost() {
    let addDescriptionViewController = Builder.createAddDescriptionViewController(image: filterImageView.imageViewToFilter.image,
                                                                                  networkMode: networkMode,
                                                                                  token: token)
    
    self.navigationController?.pushViewController(addDescriptionViewController, animated: true)
  }
}
// MARK: - Filter images

extension FilterImageViewController {
  
  private func filterCollectionView() {    
    filterImageModel.filterCollectionView(thumbnails: thumbnails)
  }
}
//MARK: - FilterImageModelDelegate

extension FilterImageViewController: FilterImageModelDelegate {
  func updateCollectionView(withImage image: UIImage, atIndex: Int) {
    thumbnails[atIndex] = image
    filterImageView.filtersPreviewCollectionView.reloadData()
  }
  
  func showIndicator() {
    filterImageView.showIndicator()
  }
  
  func hideIndicator() {
    filterImageView.hideIndicator()
  }
}
