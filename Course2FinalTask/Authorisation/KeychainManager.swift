//
//  KeyChainManager.swift
//  Course2FinalTask
//
//  Created by Rodianov on 27.03.2021.
//  Copyright © 2021 e-Legion. All rights reserved.
//

import Foundation

final class KeychainManager {
  func keychainQuery(service: String, account: String? = nil) -> [String: AnyObject] {
    var query = [String: AnyObject]()
    query[kSecClass as String] = kSecClassGenericPassword
    query[kSecAttrAccessible as String] = kSecAttrAccessibleWhenUnlocked
    query[kSecAttrService as String] = service as AnyObject
    
    if let account = account {
      query[kSecAttrAccount as String] = account as AnyObject
    }
    
    return query
  }
  
  func readToken(service: String, account: String?) -> String? {
    var query = keychainQuery(service: service, account: account)
    query[kSecMatchLimit as String] = kSecMatchLimitOne
    query[kSecReturnData as String] = kCFBooleanTrue
    query[kSecReturnAttributes as String] = kCFBooleanTrue
    
    var queryResult: AnyObject?
    let status = SecItemCopyMatching(query as CFDictionary, &queryResult)
    
    if status != noErr {
      return nil
    }
    
    guard let item = queryResult as? [String: AnyObject],
          let tokenData = item[kSecValueData as String] as? Data,
          let token = String(data: tokenData, encoding: .utf8) else {
      return nil
    }
    return token
  }
  
  func saveToken(service: String, token: String, account: String?) -> Bool {
    let tokenData = token.data(using: .utf8)
    
    if readToken(service: service, account: account) != nil {
      var attributesToUpdate = [String: AnyObject]()
      attributesToUpdate[kSecValueData as String] = tokenData as AnyObject
      
      let query = keychainQuery(service: service, account: account)
      let status = SecItemUpdate(query as CFDictionary, attributesToUpdate as CFDictionary)
      return status == noErr
    }
    
    var item = keychainQuery(service: service, account: account)
    item[kSecValueData as String] = tokenData as AnyObject
    let status = SecItemAdd(item as CFDictionary, nil)
    return status == noErr
  }
  
  func deleteToken(service: String, account: String?) -> Bool {
    let item = keychainQuery(service: service, account: account)
    let status = SecItemDelete(item as CFDictionary)
    return status == noErr
  }
}
