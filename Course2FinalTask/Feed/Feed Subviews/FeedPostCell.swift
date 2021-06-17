//
//  FeedPostCell.swift
//  Course2FinalTask
//
//  Created by Rodianov on 06.03.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit
import SnapKit
import Kingfisher
// MARK: - FeedPostCellDelegate

protocol FeedPostCellDelegate: UIViewController {
  func postHeaderViewTapped(userID: String)
  func like(postID: String, index: Int)
  func dislike(postId: String, index: Int)
  func getLikesCount(postID: String, index: Int)
  func likesLabelTapped(postID: String, title: String)
  func postImageDoubleTapped(imageView: UIImageView)
}
// MARK: - FeedPostCell

final class FeedPostCell: UITableViewCell {
  
  var networkMode: NetworkMode = .online
  var index: Int = 0
  weak var delegate: FeedPostCellDelegate?
  
  var post: PostData? {
    didSet {
      guard let post = post else {return}
      
      fillViews(post: post)
    }
  }
  
   var likesCount: Int = 0 {
    didSet {
      postFooter.likesLabel.text = "Likes: \(likesCount)"
    }
  }
  // MARK: - Private properties
  
  private lazy var postHeader: PostHeader = {
    let header = PostHeader()
    header.addGestureRecognizer(tapGestureRecognizer)
    return header
  }()
  
  private lazy var postImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.isUserInteractionEnabled = true
    imageView.addGestureRecognizer(doubleTapRecognizer)
    return imageView
  }()
  
  private var bigLikeImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.image = #imageLiteral(resourceName: "bigLike")
    imageView.isHidden = true
    return imageView
  }()
  
  private lazy var postFooter: PostFooterView = {
    let footer = PostFooterView()
    footer.likesLabel.addGestureRecognizer(likesTapRecognizer)
    return footer
  }()
  
  private lazy var tapGestureRecognizer: UITapGestureRecognizer = {
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(postHeaderTapped))
    return tapGesture
  }()
  
  private lazy var doubleTapRecognizer: UITapGestureRecognizer = {
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(postImageTapped(_:)))
    tapGesture.numberOfTapsRequired = 2
    return tapGesture
  }()
  
  private lazy var likesTapRecognizer: UITapGestureRecognizer = {
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(likesCountTapped(_:)))
    return tapGesture
  }()
  // MARK: - Inits
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setupLayout()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
// MARK: - Layout

extension FeedPostCell {
  private func setupLayout() {
    contentView.addSubview(postHeader)
    contentView.addSubview(postImageView)
    contentView.addSubview(bigLikeImageView)
    contentView.addSubview(postFooter)
    
    postHeader.snp.makeConstraints{
      $0.top.leading.trailing.equalToSuperview()
      $0.height.equalTo(51)
    }
    
    postImageView.snp.makeConstraints{
      $0.top.equalTo(postHeader.snp.bottom)
      $0.leading.trailing.equalToSuperview()
      $0.height.equalTo(postImageView.snp.width)
    }
    
    postFooter.snp.makeConstraints{
      $0.leading.trailing.equalToSuperview()
      $0.top.equalTo(postImageView.snp.bottom)
      $0.bottom.equalToSuperview()
    }
    
    bigLikeImageView.snp.makeConstraints{
      $0.centerX.centerY.equalToSuperview()
    }
    
    postFooter.likeButton.addTarget(self, action: #selector(likeButtonPressed), for: .touchUpInside)
  }
  
  private func fillViews(post: PostData) {
    let date = convertDate(dateString: post.createdTime)
    
    postHeader.authorNameLabel.text = post.authorUsername
    postHeader.dateLabel.text = "\(date)"
    postFooter.postTextLabel.text = post.description
    
    if post.currentUserLikesThisPost == false {
      postFooter.likeButton.tintColor = .lightGray
    } else {
      postFooter.likeButton.tintColor = .systemBlue
    }
    
    switch networkMode {
    
    case .online:
      delegate?.getLikesCount(postID: post.id, index: index)
      
      guard let imageURL = URL(string: post.image),
            let avatarURL = URL(string: post.authorAvatar) else {return}
      
      postImageView.kf.setImage(with: imageURL)
      postHeader.avatarImageView.kf.setImage(with: avatarURL)
      
    case .offline:
      guard let authorImageData = Data(base64Encoded: post.authorAvatar),
            let postImageData = Data(base64Encoded: post.image),
            let authorImage = UIImage(data: authorImageData),
            let postImage = UIImage(data: postImageData),
            let likedByCount = post.likesCount
      else {return}
      
      postImageView.image = postImage
      postHeader.avatarImageView.image = authorImage
      likesCount = likedByCount
    }
  }
}

// MARK: - Gesture Handlers

extension FeedPostCell {
  @objc private func postHeaderTapped(_ recognizer: UITapGestureRecognizer) {
    if let userID = post?.author {
      delegate?.postHeaderViewTapped(userID: userID)
    }
  }
  
  @objc private func postImageTapped (_ gestureRecognizer: UITapGestureRecognizer) {
    delegate?.postImageDoubleTapped(imageView: bigLikeImageView)
    
    if post?.currentUserLikesThisPost == false {
      likeButtonPressed()
    }
  }
  
  @objc private func likesCountTapped (_ gestureRecognizer: UITapGestureRecognizer) {
    if let postID = post?.id {
      delegate?.likesLabelTapped(postID: postID, title: "Likes")
    }
  }
  
  @objc private func likeButtonPressed () {
    if let postID = post?.id {
      if post?.currentUserLikesThisPost == true {
        delegate?.dislike(postId: postID, index: index)
      } else {
        delegate?.like(postID: postID, index: index)
      }
    }
  }
}
// MARK: - Private functions

extension FeedPostCell {
  private func convertDate(dateString: String) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
    if let date = formatter.date(from: dateString) {
      
      formatter.timeStyle = .medium
      formatter.dateStyle = .medium
      formatter.doesRelativeDateFormatting = true
      
      return formatter.string(from: date)
    }
    return ""
  }
}
