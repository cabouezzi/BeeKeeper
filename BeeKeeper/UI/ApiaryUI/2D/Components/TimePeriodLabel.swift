//
//  TimePeriodLabel.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 5/15/24.
//

import UIKit

class TimePeriodLabel<T: Codable>: UILabel {
    var period: Period<T>?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            guard self != nil else {
                timer.invalidate()
                return
            }
            self?.update()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func update() {
        guard let period = period else {
            text = "None"
            return
        }
        text = period.isFinished ? "Done" : "Finishes in " + Date.now.distance(to: period.dateFinished).formattedString()
    }
}
