//
//  AuthoriseModel.swift
//  Course2FinalTask
//
//  Created by Rodianov on 06.06.2021.
//  Copyright © 2021 e-Legion. All rights reserved.
//

import UIKit

// MARK: - AuthoriseModelDelegate Protocol

protocol AuthoriseModelDelegate: class {
  func getError(error: NetworkError)
  func showIndicator()
  func hideIndicator()
  func navigateToMainViewController(currentUser: UserData, token: String, networkMode: NetworkMode, dataManager: CoreDataManager)
}
// MARK: - AuthoriseModelProtocol

protocol AuthoriseModelProtocol: class {
  var dataManager: CoreDataManager! { get set }
  var delegate: AuthoriseModelDelegate? { get set }
  func checkToken(token: String)
  func signIn(login: String, password: String)
  func getTokenFromKeychain() -> String?
}
// MARK: - AuthoriseModel

final class AuthoriseModel: AuthoriseModelProtocol {
  
  var dataManager: CoreDataManager!
  
  private var keychainManager = KeychainManager()
  private let session = URLSession.shared
  
  weak var delegate: AuthoriseModelDelegate?
// MARK: Check Token
  
  func checkToken(token: String) {    
    NetworkManager.shared.getCurrentUser(token: token,
                                         session: session)
    { [weak self] (result) in
      switch result {
      
      case .success(let currentUser):
        
        guard let dataManager = self?.dataManager else {return}
        
        DispatchQueue.main.async {
          self?.delegate?.hideIndicator()
          
          self?.delegate?.navigateToMainViewController(currentUser: currentUser,
                                                       token: token,
                                                       networkMode: .online,
                                                       dataManager: dataManager)
        }
        
      case .failure(let error):
        switch error {
        
        case .unathorized(_):
          _ = self?.keychainManager.deleteToken(service: "courseTask", account: nil)
          
          self?.dataManager.deleteAll(entity: Post.self)
          self?.dataManager.deleteAll(entity: User.self)
          
          DispatchQueue.main.async {
            self?.delegate?.hideIndicator()
          }
          
        default:
          DispatchQueue.main.async {
            self?.delegate?.hideIndicator()
            let converter = Converter()
            
            guard let currUser = (self?.dataManager.fetchData(for: User.self, sortDescriptor: nil))?.first else {return}
            guard let currentUser = converter.convertToStruct(user: currUser) else {return}
            guard let dataManager = self?.dataManager else {return}
            
            self?.delegate?.navigateToMainViewController(currentUser: currentUser,
                                                         token: token,
                                                         networkMode: .offline,
                                                         dataManager: dataManager)
          }
        }
      }
    }
  }
  // MARK: SignIn
  
  func signIn(login: String, password: String) {
    NetworkManager.shared.signIn(userName: login,
                                 password: password,
                                 session: session) { [weak self] (result, token) in
      
      switch result {
      
      case .success(let currentUser):
        guard let token = token else {return}
        
        let _ = self?.keychainManager.saveToken(service: "courseTask",
                                                           token: token,
                                                           account: login)
        
        DispatchQueue.main.async {
          guard let dataManager = self?.dataManager else {return}
          
          let tabBarController = Builder.createMainViewController(currentUser: currentUser,
                                                                        token: token,
                                                                        networkMode: .online,
                                                                        dataManager: dataManager)
          UIApplication.shared.windows.first?.rootViewController = tabBarController
        }
        
      case .failure(let error):
        DispatchQueue.main.async {
          self?.delegate?.getError(error: error)
        }
      }
    }
  }
  
  func getTokenFromKeychain() -> String? {
    if let token = keychainManager.readToken(service: "courseTask", account: nil)  {
      
      DispatchQueue.main.async {
        self.delegate?.showIndicator()
      }
      delegate?.showIndicator()
      return token
    }
    return nil
  }
}
