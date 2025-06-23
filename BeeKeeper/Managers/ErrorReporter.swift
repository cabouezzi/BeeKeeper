//
//  ErrorReporter.swift
//  BeeKeeper
//
//  Created by Chaniel Abou-Ezzi on 6/22/25.
//

import Foundation

/// Posts a notification for any error you want to surface as a toast.
enum ErrorReporter {
    /// The NotificationCenter name we listen for in the UI layer
    static let notification = Notification.Name("ErrorReporter.showError")

    /// Call this from anywhere in your code to show a toast:
    ///   ErrorReporter.show(someError)
    static func show(_ error: Error) {
        NotificationCenter.default.post(name: notification, object: error)
    }
}
