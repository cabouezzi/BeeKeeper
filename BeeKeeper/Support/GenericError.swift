//
//  GenericError.swift
//  BeeKeeper
//
//  Created by Chaniel Abou-Ezzi on 6/22/25.
//

import Foundation

enum GenericError: LocalizedError {
    /// A completely custom error message.
    case custom(message: String)
    /// Wraps any existing Error (uses its localizedDescription).
    case underlying(Error)

    var errorDescription: String? {
        switch self {
        case .custom(let message):
            return message
        case .underlying(let error):
            return error.localizedDescription
        }
    }
}
