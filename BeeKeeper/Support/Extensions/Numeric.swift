//
//  Numeric.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 1/22/24.
//

import Foundation

extension Comparable {
    mutating func clamp(min: Self, max: Self) {
        if self < min {
            self = min
        } else if self > max {
            self = max
        }
    }
}
