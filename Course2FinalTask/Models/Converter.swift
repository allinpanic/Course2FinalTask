//
//  Converter.swift
//  Course2FinalTask
//
//  Created by Rodianov on 30.03.2021.
//  Copyright © 2021 e-Legion. All rights reserved.
//

import Foundation

final class Converter {
  func convertToStruct(user: User) -> UserStruct? {
    guard let id = user.id,
          let avatarData = user.avatar,
          let userName = user.userName,
          let fullName = user.fullName else {return nil}

    let avatarString = avatarData.base64EncodedString()
    let currentUserFollowsThisUser = user.currentUserFollowsThisUser
    let currentUserIsFollowedByThisUser = user.currentUserIsFollowedByThisUser
    let followsCount = Int(user.followsCount)
    let followedCount = Int(user.followedByCount)

    let userStruct = UserStruct(id: id,
                                username: userName,
                                fullName: fullName,
                                avatar: avatarString,
                                currentUserFollowsThisUser: currentUserFollowsThisUser,
                                currentUserIsFollowedByThisUser: currentUserIsFollowedByThisUser,
                                followsCount: followsCount,
                                followedByCount: followedCount)

    return userStruct
  }
  
  func convertToStruct(post: Post) -> PostStruct? {
    guard let id = post.id,
          let descript = post.descript,
          let createdTime = post.createdTime,
          let image = post.image?.base64EncodedString(),
          let authorAvatar = post.authorAvatar?.base64EncodedString(),
          let author = post.author,
          let authorUsername = post.authorUserName else {return nil}
    
    let currentUserLikesThisPost = post.currentUserLikesThisPost    
    
    let postStruct = PostStruct(id: id,
                                description: descript,
                                image: image,
                                createdTime: createdTime,
                                currentUserLikesThisPost: currentUserLikesThisPost,
                                author: author,
                                authorUsername: authorUsername,
                                authorAvatar: authorAvatar,
                                likesCount: Int(post.likedByCount))
    
    return postStruct
  }
}
