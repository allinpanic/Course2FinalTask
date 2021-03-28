//
//  User.swift
//  Course2FinalTask
//
//  Created by Rodianov on 26.01.2021.
//  Copyright © 2021 e-Legion. All rights reserved.
//

import Foundation

class UserStruct: Codable {
  var id: String
  var username: String
  var fullName: String
  var avatar: String
  var currentUserFollowsThisUser: Bool
  var currentUserIsFollowedByThisUser: Bool
  var followsCount: Int
  var followedByCount: Int
}
