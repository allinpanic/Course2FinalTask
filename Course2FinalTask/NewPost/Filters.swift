//
//  Filters.swift
//  Course2FinalTask
//
//  Created by Rodianov on 13.05.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit

class Filters {
  private let context = CIContext()
  
  let filterNamesArray = ["CIPhotoEffectChrome", "CIColorPosterize", "CIColorMonochrome", "CIGaussianBlur", "CIMotionBlur", "CIColorInvert", "CISepiaTone", "CIBloom",  "CIVignetteEffect"]
  
  func getParameters(filter: String, image: UIImage) -> [String: Any] {
    var parameters: [String: Any] = [:]
    guard let ciimage = CIImage(image: image) else {return parameters}
    
    switch filter {
    case "CIGaussianBlur":
      parameters = [kCIInputImageKey: ciimage, kCIInputRadiusKey: 3.0]
    case "CIMotionBlur":
      parameters = [kCIInputImageKey: ciimage, kCIInputRadiusKey: 2.0]
    case "CIBloom":
      parameters = [kCIInputImageKey: ciimage, kCIInputIntensityKey: 1.0]
    case "CIColorMonochrome":
      parameters = [kCIInputImageKey: ciimage, kCIInputColorKey: CIColor.white, kCIInputIntensityKey: 0.6]
    case "CIVignetteEffect":
      parameters = [kCIInputImageKey: ciimage, kCIInputIntensityKey: 0.2, kCIInputRadiusKey: 0.5]
    default:
      parameters = [kCIInputImageKey: ciimage]
    }
    
    return parameters
  }
  
   func applyFilter(name: String, parameters: [String: Any]) -> UIImage? {

    guard let filter = CIFilter(name: name, parameters: parameters),
      let outputImage = filter.outputImage,
      let cgiimage = context.createCGImage(outputImage, from: outputImage.extent) else {return nil}

    return UIImage(cgImage: cgiimage)
  }
}
