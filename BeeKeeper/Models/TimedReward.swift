//
//  TimedReward.swift
//  BeeKeeper
//
//  Created by Chaniel Abou-Ezzi on 6/18/25.
//

import Foundation

class TimedReward<T: Codable>: Codable {
    let duration: TimeInterval
    let reward: T
    let startDate: Date
    private(set) var endDate: Date

    var isComplete: Bool {
        return Date.now >= endDate
    }
    
    var timeRemaining: TimeInterval {
        return endDate.timeIntervalSinceNow
    }
    
    init(startDate: Date = .now, duration: TimeInterval, reward: T) {
        self.duration = duration
        self.reward = reward
        self.startDate = startDate
        self.endDate = startDate.addingTimeInterval(duration)
    }
    
    func forceComplete() {
        #if !RELEASE
        endDate = .now
        #endif
    }
}
