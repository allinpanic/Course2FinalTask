//
//  AuthorizeViewController.swift
//  Course2FinalTask
//
//  Created by Rodianov on 05.10.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import Foundation
import UIKit


final class AuthoriseViewController: UIViewController {
  // MARK: - Private Properties
  
  private let session = URLSession.shared
  
  private lazy var loginTextField: UITextField = {
    let textField = UITextField()
    textField.autocorrectionType = .no
    textField.placeholder = "Login"
    textField.keyboardType = .emailAddress
    textField.textColor = .black
    textField.font = .systemFont(ofSize: 14)
    textField.borderStyle = .roundedRect
    textField.returnKeyType = .send
    textField.delegate = self
    return textField
  }()
  
  private lazy var passwordTextField: UITextField = {
    let textField = UITextField()
    textField.autocorrectionType = .no
    textField.placeholder = "Password"
    textField.keyboardType = .asciiCapable
    textField.textColor = .black
    textField.font = .systemFont(ofSize: 14)
    textField.borderStyle = .roundedRect
    textField.returnKeyType = .send
    textField.delegate = self
    return textField
  }()
  
  private lazy var signInButton: UIButton = {
    let button = UIButton()
    button.setTitle("Sign in", for: .normal)
    button.setTitleColor(.white, for: .normal)
    button.backgroundColor = UIColor(named: "SignInButtonColor")
    button.titleLabel?.font = .systemFont(ofSize: 14)
    button.isEnabled = false
    button.alpha = 0.3
    button.addTarget(self, action: #selector(signInButtonPressed), for: .touchUpInside)
    button.isUserInteractionEnabled = true
    return button
  }()
  // MARK: - ViewDidLoad
  
  override func viewDidLoad() {
    super.viewDidLoad()
    NetworkManager.shared.delegate = self
    
    view.backgroundColor = .white
    
    setupLayout()
    
    handleKeyboard()
    
    loginTextField.addTarget(self, action: #selector(textChanged(_:)), for: .editingChanged)
    passwordTextField.addTarget(self, action: #selector(textChanged(_:)), for: .editingChanged)
  }
}

extension AuthoriseViewController {
  private func setupLayout() {
    view.addSubview(loginTextField)
    view.addSubview(passwordTextField)
    view.addSubview(signInButton)
    
    loginTextField.snp.makeConstraints {
      $0.height.equalTo(40)
      $0.leading.trailing.equalToSuperview().inset(16)
      $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(30)
    }
    
    passwordTextField.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview().inset(16)
      $0.height.equalTo(40)
      $0.top.equalTo(loginTextField.snp.bottom).offset(8)
    }
    
    signInButton.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview().inset(16)
      $0.top.equalTo(passwordTextField.snp.bottom).offset(100)
      $0.height.equalTo(50)
    }
  }
}
// MARK: - Button Handler

extension AuthoriseViewController {
  @objc private func textChanged(_ textField: UITextField) {
    guard let loginText = loginTextField.text,
      let passwordText = passwordTextField.text else {return}
    
    if !loginText.isEmpty && !passwordText.isEmpty {
      signInButton.isEnabled = true
      signInButton.alpha = 1
    } else {
      signInButton.isEnabled = false
      signInButton.alpha = 0.3
    }
  }
  
  @objc private func signInButtonPressed() {
    
    guard let loginText = loginTextField.text,
      let passwordText = passwordTextField.text else {return}
    
    guard let signInRequest = NetworkManager.shared.signinRequest(userName: loginText,
                                                                  password: passwordText) else {return}
    
    NetworkManager.shared.performRequest(request: signInRequest, session: session) {
      [weak self] (data) in
      
      guard let tokenSelf = NetworkManager.shared.parseJSON(jsonData: data, toType: Token.self) else {return}
      
      guard let currentUserRequest = NetworkManager.shared.currentUserRequest(token: tokenSelf.token) else {return}
      guard let session = self?.session else {return}
      
      NetworkManager.shared.performRequest(request: currentUserRequest,
                                           session: session)
      { [weak self] (data) in
        guard let currenUser = NetworkManager.shared.parseJSON(jsonData: data, toType: User.self) else {return}
        
        DispatchQueue.main.async {
          let tabBarController = self?.instansiateMainViewController(currentUser: currenUser, token: tokenSelf.token)
          UIApplication.shared.windows.first?.rootViewController = tabBarController
        }
      }
    }
  }
}
// MARK: - Make main view cotrollers

extension AuthoriseViewController {
  private func instansiateMainViewController(currentUser: User?, token: String) -> UIViewController {
    let tabBarController = UITabBarController()
    
    let feedViewController = FeedViewController(token: token)
    let profileViewController = ProfileViewController(user: nil, token: token)
    let newPostViewController = NewPostViewController(token: token)
    
    profileViewController.user = currentUser
    
    let feedNavigationController = UINavigationController(rootViewController: feedViewController)
    feedViewController.title = "Feed"
    let profileNavigationController = UINavigationController(rootViewController: profileViewController)
    profileNavigationController.title = "Profile"
    let newPostNavigationController = UINavigationController(rootViewController: newPostViewController)
    newPostNavigationController.title = "New"
    
    tabBarController.viewControllers = [feedNavigationController, newPostNavigationController, profileNavigationController]
    feedNavigationController.tabBarItem.image = #imageLiteral(resourceName: "feed")
    newPostNavigationController.tabBarItem.image = #imageLiteral(resourceName: "plus")
    profileNavigationController.tabBarItem.image = #imageLiteral(resourceName: "profile")
    
    return tabBarController
  }
}
// MARK: - NetworkMAnagerDelegate

extension AuthoriseViewController: NetworkManagerDelegate {
  func showAlert(statusCode: Int) {
    let title: String
    
    switch statusCode {
    case 400: title = "Bad Request"
    case 401: title = "Unathorized"
    case 404: title = "Not Found"
    case 406: title = "Not acceptable"
    case 422: title = "Unprocessable"
    default: title = "Transfer Error"
    }
    
    let alertVC = UIAlertController(title: title, message: "\(statusCode)", preferredStyle: .alert)
    let action = UIAlertAction(title: "OK", style: .cancel) { (action) in
      alertVC.dismiss(animated: true, completion: nil)
    }

    alertVC.addAction(action)
    present(alertVC, animated: true, completion: nil)
  }
}
// MARK: - TextFieldDelegate

extension AuthoriseViewController: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    
    textField.resignFirstResponder()
    
    if let loginText = loginTextField.text,
      let passwordText = passwordTextField.text {
      
      if !loginText.isEmpty && !passwordText.isEmpty {
        signInButtonPressed()
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
