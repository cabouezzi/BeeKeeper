//
//  Comparable.swift
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
    
    func clamped(min: Self, max: Self) -> Self {
        if self < min {
            return min
        } else if self > max {
            return max
        } else {
            return self
        }
    }
}
