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
    let currentUserRequest = NetworkManager.shared.currentUserRequest(token: token)
    
    NetworkManager.shared.performRequest(request: currentUserRequest,
                                         session: session)
    { [weak self] (result) in
      switch result {
        
      case .success(let data):
        guard let currentUser = NetworkManager.shared.parseJSON(jsonData: data,
                                                                toType: UserStruct.self) else {return}
        
        DispatchQueue.main.async {
          self?.hideIndicator()
          
          let tabBarController = self?.instansiateMainViewController(currentUser: currentUser,
                                                                     token: token,
                                                                     networkMode: .online)
          UIApplication.shared.windows.first?.rootViewController = tabBarController
        }
        
      case .failure(let error):
        switch error {
        
        case .unathorized(_):
          let deletingResult = self?.keychainManager.deleteToken(service: "courseTask", account: nil)
          if deletingResult! {
            print("token deleted")
          }
          
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
            
            let tabBarController = self?.instansiateMainViewController(currentUser: currentUser,
                                                                       token: token,
                                                                       networkMode: .offline)

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
    
    guard let signInRequest = NetworkManager.shared.signinRequest(userName: loginText,
                                                                  password: passwordText) else {return}
    
    NetworkManager.shared.performRequest(request: signInRequest, session: session) {
      [weak self] (result) in
      
      switch result {
        
      case .success(let data):
        guard let tokenSelf = NetworkManager.shared.parseJSON(jsonData: data, toType: Token.self) else {return}
        
        let savingResult = self?.keychainManager.saveToken(service: "courseTask", token: tokenSelf.token, account: loginText)
        
        if savingResult! {
          print("token saved")
        } else {
          print("token not saved")
        }
        
        let currentUserRequest = NetworkManager.shared.currentUserRequest(token: tokenSelf.token)
        guard let session = self?.session else {return}
        
        NetworkManager.shared.performRequest(request: currentUserRequest,
                                             session: session)
        { [weak self] (result) in
          
          switch result {
            
          case .success(let data):
            guard let currentUser = NetworkManager.shared.parseJSON(jsonData: data, toType: UserStruct.self) else {return}
            
            DispatchQueue.main.async {
              let tabBarController = self?.instansiateMainViewController(currentUser: currentUser, token: tokenSelf.token, networkMode: .online)
              UIApplication.shared.windows.first?.rootViewController = tabBarController
            }
            
          case .failure(let error):
            DispatchQueue.main.async {
              self?.showAlert(error: error)
            }
          }
        }
        
      case .failure(let error):
        DispatchQueue.main.async {
          self?.showAlert(error: error)
        }
      }
    }
  }
}
// MARK: - Make main view cotrollers

extension AuthoriseViewController {
  private func instansiateMainViewController(currentUser: UserStruct?, token: String, networkMode: NetworkMode) -> UIViewController {
    
    let tabBarController = UITabBarController()
    
    let feedViewController = FeedViewController(token: token)
    let profileViewController = ProfileViewController(user: nil, token: token)
    let newPostViewController = NewPostViewController(token: token)
    
    profileViewController.user = currentUser
    profileViewController.networkMode = networkMode
    profileViewController.dataManager = dataManager
    
    feedViewController.networkMode = networkMode
    feedViewController.dataManager = dataManager
    
    newPostViewController.networkMode = networkMode
    
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
