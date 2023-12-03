//
//  TimeInterval.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 12/2/23.
//

import Foundation

extension TimeInterval {
    func formattedString() -> String {
        let ti = Int(self)
        let seconds = ti % 60
        let minutes = (ti / 60) % 60
        let hours = (ti / 3600)
        return NSString(format: "%0.2d:%0.2d:%0.2d",hours,minutes,seconds) as String
    }
}
