//
//  AuthorizeViewController.swift
//  Course2FinalTask
//
//  Created by Rodianov on 05.10.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit

final class AuthoriseViewController: UIViewController {
  // MARK: - Private Properties
  
  private let session = URLSession.shared
  private var keychainManager = KeychainManager()
  private var dataManager = CoreDataManager(modelName: "UserPost")
  
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
  
  private var indicator: UIActivityIndicatorView = {
    let indicator = UIActivityIndicatorView()
    indicator.style = .white
    return indicator
  }()

  private var dimmedView: UIView = {
    let view = UIView()
    view.backgroundColor = .black
    view.alpha = 0.7
    return view
  }()
  // MARK: - ViewDidLoad
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = .white
    
    setupLayout()
    
    if let token = keychainManager.readToken(service: "courseTask", account: nil)  {
      showIndicator()
      checkToken(token: token)
    }
    
    handleKeyboard()
    
    loginTextField.addTarget(self, action: #selector(textChanged(_:)), for: .editingChanged)
    passwordTextField.addTarget(self, action: #selector(textChanged(_:)), for: .editingChanged)
  }
}
// MARK: - Check Token

extension AuthoriseViewController {
  private func checkToken(token: String) {
    
    NetworkManager.shared.getCurrentUser(token: token,
                                         session: session)
    { [weak self] (result) in
      switch result {
        
      case .success(let currentUser):

        guard let dataManager = self?.dataManager else {return}
        
        DispatchQueue.main.async {
          self?.hideIndicator()
          
          let tabBarController = MainVCBuilder.createMainViewController(currentUser: currentUser,
                                                                        token: token,
                                                                        networkMode: .online,
                                                                        dataManager: dataManager)
          
          UIApplication.shared.windows.first?.rootViewController = tabBarController
        }
        
      case .failure(let error):
        switch error {
        
        case .unathorized(_):
          _ = self?.keychainManager.deleteToken(service: "courseTask", account: nil)
          
          self?.dataManager.deleteAll(entity: Post.self)
          self?.dataManager.deleteAll(entity: User.self)
          
          DispatchQueue.main.async {
            self?.hideIndicator()
          }
          
        default:          
          DispatchQueue.main.async {
            self?.hideIndicator()
            let converter = Converter()
            
            guard let currUser = (self?.dataManager.fetchData(for: User.self, sortDescriptor: nil))?.first else {return}
            guard let currentUser = converter.convertToStruct(user: currUser) else {return}
            guard let dataManager = self?.dataManager else {return}

            let tabBarController = MainVCBuilder.createMainViewController(currentUser: currentUser,
                                                                          token: token,
                                                                          networkMode: .offline,
                                                                          dataManager: dataManager)

            UIApplication.shared.windows.first?.rootViewController = tabBarController
          }
        }
      }
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
    
    NetworkManager.shared.signIn(userName: loginText,
                                 password: passwordText,
                                 session: session) { [weak self] (result, token) in
      guard let token = token else {return}
      
      switch result {
      
      case .success(let currentUser):
        let _ = self?.keychainManager.saveToken(service: "courseTask",
                                                           token: token,
                                                           account: loginText)
        
        DispatchQueue.main.async {
          guard let dataManager = self?.dataManager else {return}
          
          let tabBarController = MainVCBuilder.createMainViewController(currentUser: currentUser,
                                                                        token: token,
                                                                        networkMode: .online,
                                                                        dataManager: dataManager)
          UIApplication.shared.windows.first?.rootViewController = tabBarController
        }
        
      case .failure(let error):
        DispatchQueue.main.async {
          self?.showAlert(error: error)
        }
      }
    }
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
// MARK: - Activity Indicator

extension AuthoriseViewController {
  private func showIndicator() {
    view.addSubview(dimmedView)
    dimmedView.snp.makeConstraints{
      $0.edges.equalToSuperview()
    }
    
    dimmedView.addSubview(indicator)
    indicator.startAnimating()
    indicator.snp.makeConstraints{
      $0.center.equalToSuperview()
    }
  }
  
  private func hideIndicator() {
    indicator.stopAnimating()
    indicator.hidesWhenStopped = true
    indicator.removeFromSuperview()
    dimmedView.removeFromSuperview()
  }
}
// MARK: Layout

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
