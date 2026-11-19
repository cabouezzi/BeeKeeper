//
//  TimedReward.swift
//  BeeKeeper
//
//  Created by Chaniel Abou-Ezzi on 6/18/25.
//

import Foundation

class TimedReward<T: Codable>: Codable {
    var onChange: (() -> Void)?
    let duration: TimeInterval
    let reward: T
    let startDate: Date
    private(set) var endDate: Date { didSet { onChange?() } }

    private enum CodingKeys: CodingKey {
        case duration, reward, startDate, endDate
    }

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

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        duration = try container.decode(TimeInterval.self, forKey: .duration)
        reward = try container.decode(T.self, forKey: .reward)
        startDate = try container.decode(Date.self, forKey: .startDate)
        endDate = try container.decode(Date.self, forKey: .endDate)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(duration, forKey: .duration)
        try container.encode(reward, forKey: .reward)
        try container.encode(startDate, forKey: .startDate)
        try container.encode(endDate, forKey: .endDate)
    }
    
    func forceComplete() {
        #if !RELEASE
        endDate = .now
        #endif
    }
}
