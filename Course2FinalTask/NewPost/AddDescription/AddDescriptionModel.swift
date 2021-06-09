//
//  AddDescriptionModel.swift
//  Course2FinalTask
//
//  Created by Rodianov on 09.06.2021.
//  Copyright © 2021 e-Legion. All rights reserved.
//

import UIKit

protocol AddDescriptionModelDelegate: class {
  func showOfflineAlert()
  func getError(error: NetworkError)
  func navigateToFeed()
}

protocol AddDescriptionModelProtocol: class {
  var delegate: AddDescriptionModelDelegate? { get set }
  func sharePost(image: UIImage, description: String)
}

final class AddDescriptionModel: AddDescriptionModelProtocol {
  private var token: String
  private var networkMode: NetworkMode
  private var session = URLSession.shared
  
  var delegate: AddDescriptionModelDelegate?
  
  init(networkMode: NetworkMode, token: String) {
    self.networkMode = networkMode
    self.token = token
  }
  
  func sharePost(image: UIImage, description: String) {
    switch networkMode {
    
    case .online:
//      guard let postImage = filteredImageView.image,
//            let text = descriptionTextField.text else {return}
      
      guard let addPostRequest = NetworkManager.shared.newPostRequest(image: image,
                                                                      description: description,
                                                                      token: token) else {return}
      
      NetworkManager.shared.performRequest(request: addPostRequest,
                                           session: URLSession.shared)
      { [weak self] (result) in
        switch result {
        
        case .success(_):
          DispatchQueue.main.async {
            self?.delegate?.navigateToFeed()
//            self?.tabBarController?.selectedIndex = 0
//            self?.navigationController?.popToRootViewController(animated: true)
          }
          
        case .failure(let error):
          DispatchQueue.main.async {
            self?.delegate?.getError(error: error)
          }
        }
      }
      
    case .offline:
      DispatchQueue.main.async {
        self.delegate?.showOfflineAlert()
      }
    }
  }
}
