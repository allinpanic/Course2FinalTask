//
//  AddDescriptionView.swift
//  Course2FinalTask
//
//  Created by Rodianov on 09.06.2021.
//  Copyright © 2021 e-Legion. All rights reserved.
//

import UIKit
// MARK: - AddDescriptionViewProtocol

protocol AddDescriptionViewProtocol: UIView {
  var image: UIImage! { get set }
  func setRightBarButtonItem(viewController: UIViewController, action: Selector)
  func getDescription() -> String?
}
// MARK: - AddDescriptionView

final class AddDescriptionView: UIView, AddDescriptionViewProtocol {
  
  var image: UIImage! {
    didSet {
      filteredImageView.image = image
    }
  }
  
  private var filteredImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFill
    return imageView
  }()
  
  private var addLabel: UILabel = {
    let label = UILabel()
    label.font = .systemFont(ofSize: 17)
    label.textColor = .black
    label.text = "Add description:"
    return label
  }()
  
  private lazy var descriptionTextField: UITextField = {
    let textField = UITextField()
    textField.borderStyle = .roundedRect
    return textField
  }()
  // MARK: - Inits
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    setupLayout()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  // MARK: - SetupLayout
  
  private func setupLayout() {
    backgroundColor = .white
    addSubview(filteredImageView)
    addSubview(addLabel)
    addSubview(descriptionTextField)
    
    handleKeyboard()
    
    filteredImageView.snp.makeConstraints {
      $0.top.equalTo(safeAreaLayoutGuide.snp.top).inset(16)
      $0.leading.equalToSuperview().inset(16)
      $0.width.height.equalTo(100)
    }
    
    addLabel.snp.makeConstraints {
      $0.top.equalTo(filteredImageView.snp.bottom).offset(32)
      $0.leading.equalToSuperview().inset(16)
    }
    
    descriptionTextField.snp.makeConstraints {
      $0.trailing.leading.equalToSuperview().inset(16)
      $0.top.equalTo(addLabel.snp.bottom).offset(8)
    }
  }
  // MARK: - Handle keyboard
  
  private func handleKeyboard() {
    let tap = UITapGestureRecognizer(target: self, action: #selector(dissmissKeyBoard))
    addGestureRecognizer(tap)
  }
  
  @objc private func dissmissKeyBoard() {
    endEditing(true)
  }
  // MARK: - Protocol methods
  
  func setRightBarButtonItem(viewController: UIViewController, action: Selector) {
    viewController.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Share",
                                                             style: .plain,
                                                             target: viewController,
                                                             action: action)
  }
  
  func getDescription() -> String? {
    return descriptionTextField.text
  }
}
