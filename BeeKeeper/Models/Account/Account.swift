//
//  Account.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 9/8/23.
//

import Foundation

final class Account: Codable {
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
