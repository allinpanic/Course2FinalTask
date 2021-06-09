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
    
    handleKeyboard()
  }
}
// MARK: - TextFieldDelegate

extension AuthoriseViewController: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    
    textField.resignFirstResponder()
    
    if let loginText = authView.loginTextField.text,
       let passwordText = authView.passwordTextField.text {
      
      if !loginText.isEmpty && !passwordText.isEmpty {
        signIn(login: loginText, password: passwordText)
        return true
      } else {
        let alertVC = UIAlertController(title: "Empty Field", message: "Specify Login or Password ", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel) { (action) in
          alertVC.dismiss(animated: true, completion: nil)
        }
        
        alertVC.addAction(action)
        present(alertVC, animated: true, completion: nil)
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
// MARK: - Handle Keyboard

extension AuthoriseViewController {
  private func handleKeyboard() {
    let tap = UITapGestureRecognizer(target: self, action: #selector(dissmissKeyBoard))
    view.addGestureRecognizer(tap)
  }
  
  @objc private func dissmissKeyBoard() {
    view.endEditing(true)
  }
}
