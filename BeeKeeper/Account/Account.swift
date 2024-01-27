//
//  Account.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 9/8/23.
//

final class Account: Codable {
    var apiaries: [Apiary]
    var unlockedGenes: Set<Gene>
    
    init() {
        apiaries = [
            Apiary()
        ]
        
        unlockedGenes = []
    }
}
