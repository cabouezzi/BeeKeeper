//
//  SmartCountdownView.swift
//  BeeKeeper
//
//  Created by Chaniel Abou-Ezzi on 6/16/25.
//

import SwiftUI

struct SmartCountdownView: View {
    let timeLeft: TimeInterval
    let cadence: TimelineViewDefaultContext.Cadence?
    
    init(timeLeft: TimeInterval, cadence: TimelineViewDefaultContext.Cadence? = nil) {
        self.timeLeft = timeLeft
        self.cadence = cadence
    }

    var body: some View {
        Text(formattedTime(remainingTime: timeLeft, cadence: cadence))
            .monospacedDigit()
    }

    private func formattedTime(remainingTime time: TimeInterval,
                               cadence: TimelineViewDefaultContext.Cadence? = nil) -> String {
//        if time <= 0 {
//            return "00:00:00"
//        }
        let totalMilliseconds = max(Int(time * 1000), 0)
        let totalSeconds = totalMilliseconds / 1000

        let days = totalSeconds / 86400
        let hours = (totalSeconds / 3600) % 24
        let minutes = (totalSeconds / 60) % 60
        let seconds = totalSeconds % 60
        let milliseconds = (totalMilliseconds % 1000) / 10  // 2-digit ms, e.g. 34 = 340ms

        if days > 0 {
            return String(format: "%02d:%02d:%02d", days, hours, minutes)
        } else if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d:%02d", minutes, seconds, milliseconds)
        }
    }
}
