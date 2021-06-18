//
//  FilterImageModel.swift
//  Course2FinalTask
//
//  Created by Rodianov on 09.06.2021.
//  Copyright © 2021 e-Legion. All rights reserved.
//

import UIKit
// MARK: - FilterImageModelDelegate

protocol FilterImageModelDelegate: class {
  func showIndicator()
  func hideIndicator()
  func updateCollectionView(withImage: UIImage, atIndex: Int)
}
// MARK: - FilterImageModelProtocol

protocol FilterImageModelProtocol: class {
  var delegate: FilterImageModelDelegate? { get set }
  func generateThumbnails(image: UIImage) -> [UIImage]
  func filtersCount() -> Int
  func filterName(withIndex index: Int) -> String
  func filterImage(image: UIImage, filterIndex: Int, completionHandler: @escaping (UIImage) -> Void)
  func filterCollectionView(thumbnails: [UIImage])
}
// MARK: - FilterImageModel

final class FilterImageModel: FilterImageModelProtocol {
  weak var delegate: FilterImageModelDelegate?
  
  private let filters = Filters()
  
  // MARK: - GenerateThimbnails
  
  func generateThumbnails(image: UIImage) -> [UIImage] {
    var thumbnails = [UIImage]()
    
    let options = [
      kCGImageSourceCreateThumbnailWithTransform: true,
      kCGImageSourceCreateThumbnailFromImageAlways: true,
      kCGImageSourceThumbnailMaxPixelSize: 60] as CFDictionary
    
    guard let imageData = image.pngData(),
      let imageSource = CGImageSourceCreateWithData(imageData as NSData, nil),
      let image = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, options)
      else { return []}
    
    let thumbnail = UIImage(cgImage: image)
    let count = filters.filterNamesArray.count
    
    for _ in 0...count - 1 {
      thumbnails.append(thumbnail)
    }
    
    return thumbnails
  }
  // MARK: - Filter Methods
  
  func filtersCount() -> Int {
    return filters.filterNamesArray.count
  }
  
  func filterName(withIndex index: Int) -> String {
    return filters.filterNamesArray[index]
  }
  
  func filterImage(image: UIImage, filterIndex: Int, completionHandler: @escaping (UIImage) -> Void) {
    guard let ciImage = CIImage(image: image) else {return}
    
    delegate?.showIndicator()
    
    DispatchQueue.global(qos: .userInteractive).async { [weak self] in
      guard let filterName = self?.filters.filterNamesArray[filterIndex] else {return}
      
      let parameters = self?.filters.getParameters(filter: filterName,
                                                   image: image)
      guard let filteredImage = self?.filters.applyFilter(name: filterName,
                                                    parameters: parameters ?? [kCIInputImageKey: ciImage])
      else {return}
      
      DispatchQueue.main.async {
        self?.delegate?.hideIndicator()
        
        completionHandler(filteredImage)
      }
    }
  }
  
  func filterCollectionView(thumbnails: [UIImage]) {
    let globalQueue = DispatchQueue.global(qos: .background)
    
    for (index, filter) in filters.filterNamesArray.enumerated() {
      
      let parameters = filters.getParameters(filter: filter, image: thumbnails[index])
      
      globalQueue.async { [weak self] in
          guard    let image = self?.filters.applyFilter(name: filter, parameters: parameters) else {return}
        
        DispatchQueue.main.async {
          self?.delegate?.updateCollectionView(withImage: image, atIndex: index)
        }
      }
    }
  }
}
