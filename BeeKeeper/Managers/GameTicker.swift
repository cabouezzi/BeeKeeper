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
        let timer = Timer(timeInterval: 1, repeats: true, block: onTick)
        RunLoop.main.add(timer, forMode: .common)
        timer.fire()
        ticker = timer
    }
    
    func stop() {
        ticker?.invalidate()
        ticker = nil
    }
}
