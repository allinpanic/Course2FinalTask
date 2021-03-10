//
//  NetworkError.swift
//  Course2FinalTask
//
//  Created by Rodianov on 10.03.2021.
//  Copyright © 2021 e-Legion. All rights reserved.
//

import Foundation

enum NetworkError: Error {
  case notFound(Int)
  case badRequest(Int)
  case unathorized(Int)
  case notAcceptable(Int)
  case unprocessable(Int)
  case transferError(Int)
}
