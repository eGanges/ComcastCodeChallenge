//
//  ServiceErrors.swift
//  ComcastCodeChallenge
//
//  Created by Edward C Ganges on 1/22/19.
//  Copyright © 2019 Edward C Ganges. All rights reserved.
//

import Foundation

// ERRORS
enum ServiceError: Error {
    case noInternetConnection
    case custom(String)
    case other
}

extension ServiceError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .noInternetConnection:
            return "No Internet Connection"
        case .other:
            return "Something went wrong."
        case .custom(let message):
            return message
        }
    }
}

extension ServiceError {
    init(json: JSON) {
        if let message = json["message"] as? String {
            self = .custom(message)
        } else {
            self = .other
        }
    }
}

