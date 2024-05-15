//
//  Period.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 2/22/24.
//

import Foundation

enum PeriodError: LocalizedError {
    case busy, notStarted, notFinished
}

class Period<T: Codable>: Codable {
    let result: T
    let dateStarted: Date
    let duration: TimeInterval
    private(set) var dateFinished: Date
    
    var isFinished: Bool { dateFinished < .now }
    
    init(result: T, duration: TimeInterval) {
        self.result = result
        self.dateStarted = Date.now
        self.duration = duration
        self.dateFinished = dateStarted.addingTimeInterval(duration)
    }
    
    func forceFinish() {
        dateFinished = .now
    }
}
