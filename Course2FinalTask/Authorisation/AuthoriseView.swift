//
//  AuthoriseView.swift
//  Course2FinalTask
//
//  Created by Rodianov on 06.06.2021.
//  Copyright © 2021 e-Legion. All rights reserved.
//

import UIKit

// MARK: - AuthoriseViewDelegate protocol

protocol AuthoriseViewDelegate: class, UITextFieldDelegate {
  func signIn(login: String, password: String)
}
// MARK: - AuthoriseViewProtocol

protocol AuthoriseViewProtocol: UIView {
  var dimmedView: UIView { get }
  var indicator: UIActivityIndicatorView { get }
  var loginTextField: UITextField { get }
  var passwordTextField: UITextField { get }
  func showIndicator()
  func hideIndicator()
}
// MARK: - AuthoriseView

final class AuthoriseView: UIView, AuthoriseViewProtocol {
  weak var delegate: AuthoriseViewDelegate?
  
  lazy var loginTextField: UITextField = {
    let textField = UITextField()
    textField.autocorrectionType = .no
    textField.placeholder = "Login"
    textField.keyboardType = .emailAddress
    textField.textColor = .black
    textField.font = .systemFont(ofSize: 14)
    textField.borderStyle = .roundedRect
    textField.returnKeyType = .send
    textField.delegate = self.delegate
    textField.addTarget(self, action: #selector(textChanged(_:)), for: .editingChanged)
    return textField
  }()
  
  lazy var passwordTextField: UITextField = {
    let textField = UITextField()
    textField.autocorrectionType = .no
    textField.placeholder = "Password"
    textField.keyboardType = .asciiCapable
    textField.textColor = .black
    textField.font = .systemFont(ofSize: 14)
    textField.borderStyle = .roundedRect
    textField.returnKeyType = .send
    textField.delegate = self.delegate
    textField.addTarget(self, action: #selector(textChanged(_:)), for: .editingChanged)
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
    button.addTarget(self, action: #selector(signInButtonHandler), for: .touchUpInside)
    button.isUserInteractionEnabled = true
    return button
  }()
  
  var indicator: UIActivityIndicatorView = {
    let indicator = UIActivityIndicatorView()
    indicator.style = .white
    return indicator
  }()

  var dimmedView: UIView = {
    let view = UIView()
    view.backgroundColor = .black
    view.alpha = 0.7
    return view
  }()
  // MARK: - Inits
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupLayout()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  // MARK: - Private Methods
  
  private func setupLayout() {
    addSubview(loginTextField)
    addSubview(passwordTextField)
    addSubview(signInButton)
    
    loginTextField.snp.makeConstraints {
      $0.height.equalTo(40)
      $0.leading.trailing.equalToSuperview().inset(16)
      $0.top.equalTo(safeAreaLayoutGuide.snp.top).inset(30)
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
  
  @objc private func signInButtonHandler() {
    guard let loginText = loginTextField.text,
      let passwordText = passwordTextField.text else {return}
    
    delegate?.signIn(login: loginText, password: passwordText)
  }
  
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
  
  func hideIndicator() {
    indicator.stopAnimating()
    indicator.hidesWhenStopped = true
    indicator.removeFromSuperview()
    dimmedView.removeFromSuperview()
  }
  
  func showIndicator() {
    addSubview(dimmedView)
    dimmedView.snp.makeConstraints{
      $0.edges.equalToSuperview()
    }
    
    dimmedView.addSubview(indicator)
    indicator.startAnimating()
    indicator.snp.makeConstraints{
      $0.center.equalToSuperview()
    }
  }
}
