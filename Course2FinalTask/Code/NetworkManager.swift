//
//  NetworkManagerService.swift
//  Course2FinalTask
//
//  Created by Rodianov on 28.01.2021.
//  Copyright © 2021 e-Legion. All rights reserved.
//

import Foundation
import UIKit

protocol NetworkManagerDelegate: AnyObject {
  func showAlert(statusCode: Int)
}

final class NetworkManager {
  // MARK: - Properties
  private let hostPath = "http://localhost:8080"

  weak var delegate: NetworkManagerDelegate?
  
  static let shared = NetworkManager()
  
  private init() {}
  
// MARK: - Make GET Requests
  
  func currentUserRequest(token: String) -> URLRequest? {
    
    guard let url = makeURL(path: "/users/me") else { return nil }
    
    var request = URLRequest(url: url)
    request.addValue(token, forHTTPHeaderField: "token")
    
    return request
  }
  
  func getUserRequest(withUserID: String, token: String) -> URLRequest? {
    
    guard let url = makeURL(path: "/users/\(withUserID)") else { return nil }
    
    var request = URLRequest(url: url)
    request.addValue(token, forHTTPHeaderField: "token")
    
    return request
  }
  
  func getFollowingUsersForUserRequest(withUserID: String, token: String) -> URLRequest? {
    guard let url = makeURL(path: "/users/\(withUserID)/followers") else { return nil }
    
    var request = URLRequest(url: url)
    request.addValue(token, forHTTPHeaderField: "token")
    
    return request
  }
  
  func getUsersFollowedByUserRequest(withUserID: String, token: String) -> URLRequest? {
    guard let url = makeURL(path: "/users/\(withUserID)/following") else { return nil }
    
    var request = URLRequest(url: url)
    request.addValue(token, forHTTPHeaderField: "token")
    
    return request
  }
  
  func getPostsByUserRequest(withUserID: String, token: String) -> URLRequest? {
    guard let url = makeURL(path: "/users/\(withUserID)/posts") else { return nil }
    
    var request = URLRequest(url: url)
    request.addValue(token, forHTTPHeaderField: "token")
    
    return request
  }
  
  func getFeedRequest(token: String) -> URLRequest? {
    guard let url = makeURL(path: "/posts/feed") else { return nil }
    
    var request = URLRequest(url: url)
    request.addValue(token, forHTTPHeaderField: "token")
    
    return request
  }
  
  func getPostRequest(withPostID: String, token: String) -> URLRequest? {
    guard let url = makeURL(path: "/posts/\(withPostID)") else { return nil }
    
    var request = URLRequest(url: url)
    request.addValue(token, forHTTPHeaderField: "token")
    
    return request
  }
  
  
  func getUsersLikedPostRequest(withPostID: String, token: String) -> URLRequest? {
    guard let url = makeURL(path: "/posts/\(withPostID)/likes") else { return nil }
    
    var request = URLRequest(url: url)
    request.addValue(token, forHTTPHeaderField: "token")
    
    return request
  }
  // MARK: - Make POST Requests
  
  func signinRequest(userName: String, password: String) -> URLRequest? {
    
    guard let url = makeURL(path: "/signin") else { return nil }
    
    let authInfo = "{ \"login\" : \"\(userName)\", \"password\" : \"\(password)\" }"
    let authInfoData = authInfo.data(using: .utf8)
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.httpBody = authInfoData
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    
    return request
  }
  
  func signOutRequest(token: String) -> URLRequest? {
    
    guard let url = makeURL(path: "/signout") else { return nil }
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.addValue(token, forHTTPHeaderField: "token")
    
    return request
  }
  
  func followUserRequest(withUserID: String, token: String) -> URLRequest? {
    let userInfo = "{ \"userID\" : \"\(withUserID)\" }"
    let userIDData = userInfo.data(using: .utf8)
    
    guard let url = makeURL(path: "/users/follow") else { return nil }
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.httpBody = userIDData
    request.addValue(token, forHTTPHeaderField: "token")
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    
    return request
  }
  
  func unfollowUserRequest(withUserID: String, token: String) -> URLRequest? {
    let userInfo = "{ \"userID\" : \"\(withUserID)\" }"
    let userIDData = userInfo.data(using: .utf8)
    
    guard let url = makeURL(path: "/users/unfollow") else { return nil }
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.httpBody = userIDData
    request.addValue(token, forHTTPHeaderField: "token")
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    
    return request
  }
  
  func likePostRequest(withPostID: String, token: String) -> URLRequest? {
    
    let postInfo = "{ \"postID\" : \"\(withPostID)\" }"
    let postIDData = postInfo.data(using: .utf8)
    
    guard let url = makeURL(path: "/posts/like") else { return nil }
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.httpBody = postIDData
    request.addValue(token, forHTTPHeaderField: "token")
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    
    return request
  }
  
  func unlikePostRequest(withPostID: String, token: String) -> URLRequest? {
    
    let postInfo = "{ \"postID\" : \"\(withPostID)\" }"
    let postIDData = postInfo.data(using: .utf8)
    
    guard let url = makeURL(path: "/posts/unlike") else { return nil }
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.httpBody = postIDData
    request.addValue(token, forHTTPHeaderField: "token")
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    
    return request
  }

  
  func newPostRequest(image: UIImage, description: String, token: String) -> URLRequest? {
    let imageData = image.jpegData(compressionQuality: 1)
    guard let imageString = imageData?.base64EncodedString() else {return nil}
    
    let body: [String: Any] = ["image": imageString, "description": description]
    guard let jsonData = try? JSONSerialization.data(withJSONObject: body, options: .prettyPrinted) else { return nil}
    
    guard let url = makeURL(path: "/posts/create") else { return nil }
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.httpBody = jsonData
    request.addValue(token, forHTTPHeaderField: "token")
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")    
    
    return request
  }
  // MARK: - Perform Request function
  
  func performRequest(request: URLRequest,
                      session: URLSession,
                      completionHandler: @escaping (Data) -> Void) {
    
    let dataTask = session.dataTask(with: request) { [weak self] data, response, error in
      if let error = error {
        print(error.localizedDescription)
        return
      }
      
      if let httpResponse = response as? HTTPURLResponse {
        if httpResponse.statusCode != 200 {          
          DispatchQueue.main.async {
            self?.delegate?.showAlert(statusCode: httpResponse.statusCode)
          }
        } else {
          guard let data = data else {return}
          
          completionHandler(data)
        }
      }      
    }
    dataTask.resume()
  }
  
  func parseJSON<T: Codable>(jsonData: Data, toType: T.Type) -> T? {
    let decoder = JSONDecoder()
    
    guard let result = try? decoder.decode(T.self, from: jsonData) else {
      print("data decoding failed")
      return nil
    }
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
}
