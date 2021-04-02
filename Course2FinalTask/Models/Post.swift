//
//  Post.swift
//  Course2FinalTask
//
//  Created by Rodianov on 28.01.2021.
//  Copyright © 2021 e-Legion. All rights reserved.
//

import Foundation

struct PostStruct: Codable {
  var id: String
  var description: String
  var image: String
  var createdTime: String
  var currentUserLikesThisPost: Bool
  var author: String
  var authorUsername: String
  var authorAvatar: String
  
  var likesCount: Int?
}
