//
//  ResearchPeriod.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 2/22/24.
//

import Foundation

class ResearchPeriod: Codable {
    let gene: Gene
    let dateStarted: Date
    let duration: TimeInterval
    var dateFinished: Date { return dateStarted.addingTimeInterval(duration) }
    
    init(gene: Gene, duration: TimeInterval) {
        self.gene = gene
        self.dateStarted = Date.now
        self.duration = duration
    }
}
