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
  var filteredImageView: UIImageView { get set }
  var descriptionTextField: UITextField { get set }
}
// MARK: - AddDescriptionView

final class AddDescriptionView: UIView, AddDescriptionViewProtocol {
  
  var image: UIImage! {
    didSet {
      filteredImageView.image = image
    }
  }
  
  var filteredImageView: UIImageView = {
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
  
  lazy var descriptionTextField: UITextField = {
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
}
