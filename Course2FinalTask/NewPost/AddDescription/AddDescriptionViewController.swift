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
  
  private var addDescView: AddDescriptionViewProtocol = {
    let view = AddDescriptionView()
    return view
  }()
  
  var addDescModel: AddDescriptionModelProtocol!
  // MARK: - Inits
  
  init(filteredImage: UIImage?) {
    self.addDescView.image = filteredImage
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  // MARK: - ViewDidLoad
  
  override func loadView() {
    super.loadView()
    view = addDescView
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    addDescModel.delegate = self
    
    addDescView.setRightBarButtonItem(viewController: self, action: #selector(sharePostButtonTapped))
  }
}
// MARK: - Button Handler

extension AddDescriptionViewController {
  @objc private func sharePostButtonTapped() {
    guard let postImage = addDescView.image,
          let text = addDescView.getDescription() else {return}
    
    addDescModel.sharePost(image: postImage, description: text)
  }
}
// MARK: - AddDescriptionModelDelegate

extension AddDescriptionViewController: AddDescriptionModelDelegate {
  func getError(error: NetworkError) {
    showAlert(error: error)
  }
  
  func navigateToFeed() {
    self.tabBarController?.selectedIndex = 0
    self.navigationController?.popToRootViewController(animated: true)
  }
}

