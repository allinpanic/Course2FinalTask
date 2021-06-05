//
//  AddDescriptionViewController.swift
//  Course2FinalTask
//
//  Created by Rodianov on 13.05.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit

final class AddDescriptionViewController: UIViewController {
// MARK: - Properties
  var token: String = ""
  var networkMode: NetworkMode = .online
  
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
  
  init(filteredImage: UIImage?) {
    self.filteredImageView.image = filteredImage
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  // MARK: - ViewDidLoad
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Share", style: .plain, target: self, action: #selector(sharePost))
    
    setupLayout()
    handleKeyboard()
  }
}
// MARK: - Extensions

extension AddDescriptionViewController {
  private func setupLayout() {
    view.backgroundColor = .white
    view.addSubview(filteredImageView)
    view.addSubview(addLabel)
    view.addSubview(descriptionTextField)
    
    filteredImageView.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(16)
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

extension AddDescriptionViewController {
  @objc private func sharePost() {
    switch networkMode {
    
    case .online:
      guard let postImage = filteredImageView.image,
            let text = descriptionTextField.text else {return}
      
      guard let addPostRequest = NetworkManager.shared.newPostRequest(image: postImage,
                                                                      description: text,
                                                                      token: token) else {return}
      
      NetworkManager.shared.performRequest(request: addPostRequest,
                                           session: URLSession.shared)
      { [weak self] (result) in        
        switch result {
        
        case .success(_):
          DispatchQueue.main.async {
            self?.tabBarController?.selectedIndex = 0
            self?.navigationController?.popToRootViewController(animated: true)
          }
          
        case .failure(let error):
          DispatchQueue.main.async {
            self?.showAlert(error: error)
          }
        }
      }
      
    case .offline:
      showOfflineAlert()
    }
  }
}
// MARK: - Handle Keyboard

extension AddDescriptionViewController {
  private func handleKeyboard() {
    let tap = UITapGestureRecognizer(target: self, action: #selector(dissmissKeyBoard))    
    view.addGestureRecognizer(tap)
  }
  
  @objc private func dissmissKeyBoard() {
    view.endEditing(true)
  }
}

