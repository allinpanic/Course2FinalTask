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
  
  private var selectedImage: UIImage
  private var index: Int
//  private var filters = Filters()
  
//  private let reuseIdentifier = "filterThumbnail"
  private let filterNames: [String] = []
  private var thumbnails: [UIImage] = []
  
  var filterImageModel: FilterImageModelProtocol!
  lazy var filterImageView: FilterImageViewProtocol = {
    let view = FilterImageView()
    view.image = selectedImage
    view.filtersPreviewCollectionView.delegate = self
    view.filtersPreviewCollectionView.dataSource = self
    return view
  }()
  
//  private lazy var imageViewToFilter: UIImageView = {
//    let imageView = UIImageView()
//    imageView.image = selectedImage
//    imageView.contentMode = .scaleAspectFill
//    return imageView
//  }()
//
//  private lazy var filtersPreviewCollectionView: UICollectionView = {
//    let layout = UICollectionViewFlowLayout()
//    layout.scrollDirection = .horizontal
//    layout.minimumInteritemSpacing = 16
//    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
//    collectionView.backgroundColor = .white
//    collectionView.register(FilteredThumbnailCell.self, forCellWithReuseIdentifier: reuseIdentifier)
//    collectionView.dataSource = self
//    collectionView.delegate = self
//    return collectionView
//  }()
//
//  private var indicator: UIActivityIndicatorView = {
//    let indicator = UIActivityIndicatorView()
//    indicator.style = .white
//    return indicator
//  }()
//
//  private var dimmedView: UIView = {
//    let view = UIView()
//    view.backgroundColor = .black
//    view.alpha = 0.7
//    return view
//  }()
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
    
//    setupLayout()
    self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next",
                                                             style: .plain,
                                                             target: self,
                                                             action: #selector(showAddDescriptionToPost))
    
    thumbnails = filterImageModel.generateThumbnail(image: selectedImage)
    
    
    filterCollectionView()
  }
}
//MARK: - CollectionView Datasource, Delegate

extension FilterImageViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return filterImageModel.filtersCount() //filters.filterNamesArray.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: filterImageView.reuseIdentifier, for: indexPath) as? FilteredThumbnailCell else {return UICollectionViewCell()}
    
    cell.image = thumbnails[indexPath.row]
    cell.filterName = filterImageModel.filterName(withIndex: indexPath.row)//filters.filterNamesArray[indexPath.row]
    
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
    
    
    
    
    
    
    
    
//    let imageToFilter = self.selectedImage
//    guard let ciImage = CIImage(image: imageToFilter) else {return}
//
//    showIndicator()
//    DispatchQueue.global(qos: .userInteractive).async { [weak self] in
//      guard let filterName = self?.filters.filterNamesArray[indexPath.row] else {return}
//
//      let parameters = self?.filters.getParameters(filter: filterName,
//                                                   image: imageToFilter)
//      let filteredImage = self?.filters.applyFilter(name: filterName,
//                                                    parameters: parameters ?? [kCIInputImageKey: ciImage])
//      DispatchQueue.main.async {
//        self?.hideIndicator()
//        self?.imageViewToFilter.image = filteredImage
//      }
//    }
  }
}
//MARK: - Layout

extension FilterImageViewController {
//  private func setupLayout() {
//    view.backgroundColor = .white
//    view.addSubview(imageViewToFilter)
//    view.addSubview(filtersPreviewCollectionView)
//    
//    self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next",
//                                                             style: .plain,
//                                                             target: self,
//                                                             action: #selector(showAddDescriptionToPost))
//    
//    imageViewToFilter.snp.makeConstraints{
//      $0.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
//    }
//    
//    filtersPreviewCollectionView.snp.makeConstraints{
//      $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(16)
//      $0.leading.trailing.equalToSuperview()
//      $0.height.equalTo(120)
//    }
//  }
}

extension FilterImageViewController {
  @objc private func showAddDescriptionToPost() {
    let addDescriptionViewController = AddDescriptionViewController(filteredImage: filterImageView.imageViewToFilter.image)
    
    let addDescModel = AddDescriptionModel(networkMode: networkMode, token: token)
//    addDescriptionViewController.token = token
//    addDescriptionViewController.networkMode = networkMode
    
    addDescriptionViewController.addDescModel = addDescModel
    
    self.navigationController?.pushViewController(addDescriptionViewController, animated: true)
  }
}
// MARK: - Filter images

extension FilterImageViewController {
  
//  private func generateThumbnails() {
//    thumbnails = []
//
//    let uiimage = selectedImage
//
//    let options = [
//      kCGImageSourceCreateThumbnailWithTransform: true,
//      kCGImageSourceCreateThumbnailFromImageAlways: true,
//      kCGImageSourceThumbnailMaxPixelSize: 60] as CFDictionary
//
//    guard let imageData = uiimage.pngData(),
//      let imageSource = CGImageSourceCreateWithData(imageData as NSData, nil),
//      let image = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, options)
//      else { return }
//
//    let thumbnail = UIImage(cgImage: image)
//    let count = filters.filterNamesArray.count
//
//    for _ in 0...count - 1 {
//      thumbnails?.append(thumbnail)
//    }
//  }
  
  private func filterCollectionView() {
    //guard let thumbnails = thumbnails else {return}
    filterImageModel.filterCollectionView(thumbnails: thumbnails)
    
    
    
    
    
    
//    let globalQueue = DispatchQueue.global(qos: .background)
//    
//    for (index, filter) in filters.filterNamesArray.enumerated() {
//      guard let thumbnails = thumbnails else {continue}
//      
//      globalQueue.async { [weak self] in
//        guard let parameters = self?.filters.getParameters(filter: filter, image: thumbnails[index]),
//              let image = self?.filters.applyFilter(name: filter, parameters: parameters) else {return}
//        
//        self?.thumbnails?[index] = image
//        
//        DispatchQueue.main.async {
//          self?.filtersPreviewCollectionView.reloadData()
//        }
//      }
//    }
  }
}
//MARK: - Indicator

extension FilterImageViewController {
  func showIndicator() {
    view.addSubview(filterImageView.dimmedView)
    filterImageView.dimmedView.snp.makeConstraints{
      $0.edges.equalToSuperview()
    }

    filterImageView.dimmedView.addSubview(filterImageView.indicator)
    filterImageView.indicator.startAnimating()
    filterImageView.indicator.snp.makeConstraints{
      $0.center.equalToSuperview()
    }
  }

  func hideIndicator() {
    filterImageView.indicator.stopAnimating()
    filterImageView.indicator.hidesWhenStopped = true
    filterImageView.indicator.removeFromSuperview()
    filterImageView.dimmedView.removeFromSuperview()
  }
}

extension FilterImageViewController: FilterImageModelDelegate {
  func updateCollectionView(withImage image: UIImage, atIndex: Int) {
    thumbnails[index] = image
    filterImageView.filtersPreviewCollectionView.reloadData()
  }
  
  
}


