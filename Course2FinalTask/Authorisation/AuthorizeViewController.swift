//
//  AuthorizeViewController.swift
//  Course2FinalTask
//
//  Created by Rodianov on 05.10.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit
// MARK: - AuthoriseViewController

final class AuthoriseViewController: UIViewController {
  
  private lazy var authView: AuthoriseViewProtocol = {
    let view = AuthoriseView()
    view.delegate = self
    view.setTextFieldsDelegate(delegate: self)
//    view.passwordTextField.delegate = self
//    view.loginTextField.delegate = self
    return view
  }()
  
  var authModel: AuthoriseModelProtocol!

  // MARK: - ViewDidLoad
  
  override func loadView() {
    super.loadView()
    view = authView
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = .white
    
    authModel.delegate = self
      
    if let token = authModel.getTokenFromKeychain() {
      authModel.checkToken(token: token)
    }
  }
}
// MARK: - TextFieldDelegate

extension AuthoriseViewController: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {    
    textField.resignFirstResponder()
    
    if let login = authView.getLogin(),
       let password = authView.getPassword() {
      
      if !login.isEmpty && !password.isEmpty {
        signIn(login: login, password: password)
        return true
      } else {
        showAlert(title: "Empty Field", message: "Specify Login or Password")
      }
    }
    return true
  }
}
// MARK: - AuthViewDelegate

extension AuthoriseViewController: AuthoriseViewDelegate {
  func signIn(login: String, password: String) {
    authModel.signIn(login: login, password: password)
  }
}
// MARK: - AuthoriseModelDelegate

extension AuthoriseViewController: AuthoriseModelDelegate {
  func getError(error: NetworkError) {
    showAlert(error: error)
  }
  
  func navigateToMainViewController(currentUser: UserData, token: String, networkMode: NetworkMode, dataManager: CoreDataManager) {
    let tabBarController = Builder.createMainViewController(currentUser: currentUser,
                                                                  token: token,
                                                                  networkMode: networkMode,
                                                                  dataManager: dataManager)
    
    UIApplication.shared.windows.first?.rootViewController = tabBarController
  }
  
  func hideIndicator() {
    authView.hideIndicator()
  }
  
  func showIndicator() {
    authView.showIndicator()
  }
}
