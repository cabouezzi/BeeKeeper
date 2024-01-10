//
//  GameTicker.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 1/9/24.
//

import Foundation

class GameTicker {
    private var ticker: Timer?
    private var block: (Timer) -> Void
    
    init() {
        block = { _ in }
    }
    
    private func onTick(_ timer: Timer) {
        block(timer)
    }
    
    func setHandler(_ block: @escaping (Timer) -> Void) {
        self.block = block
    }
    
    func start() {
        ticker = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: onTick)
    }
    
    func stop() {
        ticker?.invalidate()
        ticker = nil
    }
}
