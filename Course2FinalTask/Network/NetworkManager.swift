//
//  NetworkManagerService.swift
//  Course2FinalTask
//
//  Created by Rodianov on 28.01.2021.
//  Copyright © 2021 e-Legion. All rights reserved.
//

import Foundation
import UIKit

final class NetworkManager {
  // MARK: - Properties
  private let hostPath = "http://localhost:8080"
  
  static let shared = NetworkManager()
  
  private init() {}
  
// MARK: - Make GET Requests
  
  func currentUserRequest(token: String) -> URLRequest {
    return makeURLRequest(withURLPath: "/users/me", token: token)
  }
  
  func getUserRequest(withUserID userID: String, token: String) -> URLRequest {
    return makeURLRequest(withURLPath: "/users/\(userID)", token: token)
  }
  
  func getFollowingUsersForUserRequest(withUserID userID: String, token: String) -> URLRequest {
    return makeURLRequest(withURLPath: "/users/\(userID)/followers", token: token)
  }
  
  func getUsersFollowedByUserRequest(withUserID userID: String, token: String) -> URLRequest {
    return makeURLRequest(withURLPath: "/users/\(userID)/following", token: token)
  }
  
  func getPostsByUserRequest(withUserID userID: String, token: String) -> URLRequest {
    return makeURLRequest(withURLPath: "/users/\(userID)/posts", token: token)
  }
  
  func getFeedRequest(token: String) -> URLRequest {
    return makeURLRequest(withURLPath: "/posts/feed", token: token)
  }
  
  func getPostRequest(withPostID postID: String, token: String) -> URLRequest {
    return makeURLRequest(withURLPath: "/posts/\(postID)", token: token)
  }
  
  
  func getUsersLikedPostRequest(withPostID postID: String, token: String) -> URLRequest {
    return makeURLRequest(withURLPath: "/posts/\(postID)/likes", token: token)
  }
  // MARK: - Make POST Requests
  
  func signinRequest(userName: String, password: String) -> URLRequest? {
    
    guard let url = makeURL(path: "/signin") else {return nil}
    
    let authInfo = "{ \"login\" : \"\(userName)\", \"password\" : \"\(password)\" }"
    let authInfoData = authInfo.data(using: .utf8)
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.httpBody = authInfoData
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    
    return request
  }
  
  func signOutRequest(token: String) -> URLRequest {
    
    var request = makeURLRequest(withURLPath: "/signout", token: token)
    request.httpMethod = "POST"
    
    return request
  }
  
  func followUserRequest(withUserID userID: String, token: String) -> URLRequest {
    let userInfo = "{ \"userID\" : \"\(userID)\" }"
    let userIDData = userInfo.data(using: .utf8)
    
    var request = makeURLRequest(withURLPath: "/users/follow", token: token)
    
    request.httpMethod = "POST"
    request.httpBody = userIDData
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    
    return request
  }
  
  func unfollowUserRequest(withUserID userID: String, token: String) -> URLRequest {
    let userInfo = "{ \"userID\" : \"\(userID)\" }"
    let userIDData = userInfo.data(using: .utf8)
    
    var request = makeURLRequest(withURLPath: "/users/unfollow", token: token)
    
    request.httpMethod = "POST"
    request.httpBody = userIDData
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    
    return request
  }
  
  func likePostRequest(withPostID postID: String, token: String) -> URLRequest {
    
    let postInfo = "{ \"postID\" : \"\(postID)\" }"
    let postIDData = postInfo.data(using: .utf8)
    
    var request = makeURLRequest(withURLPath: "/posts/like", token: token)
    
    request.httpMethod = "POST"
    request.httpBody = postIDData
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    
    return request
  }
  
  func unlikePostRequest(withPostID postID: String, token: String) -> URLRequest {
    
    let postInfo = "{ \"postID\" : \"\(postID)\" }"
    let postIDData = postInfo.data(using: .utf8)
    
    var request = makeURLRequest(withURLPath: "/posts/unlike", token: token)
    
    request.httpMethod = "POST"
    request.httpBody = postIDData
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    
    return request
  }

  
  func newPostRequest(image: UIImage, description: String, token: String) -> URLRequest? {
    let imageData = image.jpegData(compressionQuality: 1)
    guard let imageString = imageData?.base64EncodedString() else {return nil}
    
    let body: [String: Any] = ["image": imageString, "description": description]
    guard let jsonData = try? JSONSerialization.data(withJSONObject: body, options: .prettyPrinted) else { return nil}
        
    var request = makeURLRequest(withURLPath: "/posts/create", token: token)
    
    request.httpMethod = "POST"
    request.httpBody = jsonData
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    
    return request
  }
  // MARK: - Perform Request function
  
  func performRequest(request: URLRequest,
                      session: URLSession,
                      completionHandler: @escaping (Result<Data, NetworkError>) -> Void) {
    
    let dataTask = session.dataTask(with: request) { data, response, error in
      if let error = error {
        completionHandler(.failure(.error(error.localizedDescription)))
        return
      }
      
      if let httpResponse = response as? HTTPURLResponse {
        
        switch httpResponse.statusCode {
        case 200 :
          guard let data = data else {return}
          completionHandler(.success(data))
        case 404 :
          completionHandler(.failure(.notFound(404)))
        case 400 :
          completionHandler(.failure(.badRequest(400)))
        case 401:
          completionHandler(.failure(.unathorized(401)))
        case 406:
          completionHandler(.failure(.notAcceptable(406)))
        case 422:
          completionHandler(.failure(.unprocessable(422)))
        default:
          completionHandler(.failure(.transferError(httpResponse.statusCode)))
        }
      }      
    }
    dataTask.resume()
  }
  
  func parseJSON<T: Codable>(jsonData: Data, toType: T.Type) -> T? {
    let decoder = JSONDecoder()
    
    guard let result = try? decoder.decode(T.self, from: jsonData) else {return nil}
    
    return result
  }
}
// MARK: - Private function

extension NetworkManager {
  private func makeURL(path: String) -> URL? {
    
    guard let baseURL = URL(string: hostPath) else {return nil}
    let fullURL = baseURL.appendingPathComponent(path)
    
    return fullURL
  }
  
  private func makeURLRequest(withURLPath path: String, token: String) -> URLRequest {
    let fullURL: URL
    let baseURL = URL(string: hostPath)!
    fullURL = baseURL.appendingPathComponent(path)
    
    var request = URLRequest(url: fullURL)
    request.addValue(token, forHTTPHeaderField: "token")
    
    return request
  }
}
