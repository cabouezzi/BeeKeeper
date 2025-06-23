//
//  Account.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 9/8/23.
//

import Foundation

final class Account: Codable {
    var name: String = "The Apiary" {
        didSet {
            NotificationCenter.default.post(name: .didChangeName, object: nil)
        }
    }
    var apiaries: [Apiary]
    var unlockedGenes: Set<Gene>
    var research: TimedReward<Gene>?
    
    init() {
        apiaries = [
            Apiary()
        ]
        
        unlockedGenes = []
    }
}

// TODO: One day this will move to reactive programming...
extension Notification.Name {
    static let didChangeName = Notification.Name("didChangeName")
}
