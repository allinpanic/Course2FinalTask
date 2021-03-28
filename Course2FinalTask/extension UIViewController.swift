//
//  AlertController.swift
//  Course2FinalTask
//
//  Created by Rodianov on 27.03.2021.
//  Copyright © 2021 e-Legion. All rights reserved.
//

import UIKit

extension UIViewController {
  
  func showAlert(error: NetworkError) {
    let title: String
    let statusCode: Int
    
    switch error {
    case .badRequest(let code):
      title = "Bad Request"
      statusCode = code
      
    case .unathorized(let code):
      title = "Unathorized"
      statusCode = code
      
    case .notFound(let code):
      title = "Not Found"
      statusCode = code
      
    case .notAcceptable(let code):
      title = "Not acceptable"
      statusCode = code
      
    case .unprocessable(let code):
      title = "Unprocessable"
      statusCode = code
      
    case .transferError(let code):
      title = "Transfer Error"
      statusCode = code
      
    case .error(let description):
      title = "\(description)"
      statusCode = 0
    }
    
    let alertVC = UIAlertController(title: title, message: "\(statusCode)", preferredStyle: .alert)
    let action = UIAlertAction(title: "OK", style: .cancel) { (action) in
      alertVC.dismiss(animated: true, completion: nil)
    }
    
    alertVC.addAction(action)
    present(alertVC, animated: true, completion: nil)
  }
  
  func showAlert(handler: ( () -> Void)? = nil) {
    let alert = UIAlertController(title: "Unknokn error!",
                                  message: "Please, try again later",
                                  preferredStyle: .alert)
    
    let alertAction = UIAlertAction(title: "OK",
                                    style: .default,
                                    handler: { action in
                                      alert.dismiss(animated: true, completion: nil)
    })
    alert.addAction(alertAction)
    present(alert, animated: true, completion: nil)
  }
  
  func showOfflineAlert() {
    let alert = UIAlertController(title: "Offline Mode", message: nil, preferredStyle: .alert)
    let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
    
    alert.addAction(alertAction)
    present(alert, animated: true, completion: nil)
  }
}
