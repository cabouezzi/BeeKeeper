//
//  TimeInterval.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 12/2/23.
//

import Foundation

extension TimeInterval {
    var minutes: Double { return self / 60 }
    var hours: Double { return self / minutes / 60 }
    var days: Double { return self / hours / 24 }
    
    init(days: Double = 0, hours: Double = 0, minutes: Double = 0) {
        self = (days * 86400) + (hours * 3600) + (minutes * 60)
    }
    
    func formattedString() -> String {
        let ti = Int(self)
        let seconds = ti % 60
        let minutes = (ti / 60) % 60
        let hours = (ti / 3600)
        return NSString(format: "%0.2d:%0.2d:%0.2d", hours, minutes, seconds) as String
    }
}
