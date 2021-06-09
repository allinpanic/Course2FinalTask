//
//  AddDescriptionModel.swift
//  Course2FinalTask
//
//  Created by Rodianov on 09.06.2021.
//  Copyright © 2021 e-Legion. All rights reserved.
//

import UIKit
// MARK: - AddDescriptionModelDelegate

protocol AddDescriptionModelDelegate: class {
  func showOfflineAlert()
  func getError(error: NetworkError)
  func navigateToFeed()
}
// MARK: - AddDescriptionModelProtocol

protocol AddDescriptionModelProtocol: class {
  var delegate: AddDescriptionModelDelegate? { get set }
  func sharePost(image: UIImage, description: String)
}
// MARK: - AddDescriptionModel

final class AddDescriptionModel: AddDescriptionModelProtocol {
  private var token: String
  private var networkMode: NetworkMode
  private var session = URLSession.shared
  
  var delegate: AddDescriptionModelDelegate?
  
  init(networkMode: NetworkMode, token: String) {
    self.networkMode = networkMode
    self.token = token
  }
  // MARK: SharePost
  
  func sharePost(image: UIImage, description: String) {
    switch networkMode {
    
    case .online:
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
