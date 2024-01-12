//
//  AnimatedNumberNode.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 9/9/23.
//

import SpriteKit

/// Label node for numbers (Integers, specifically) only.
class AnimatedIntLabel: SKLabelNode {
    private let numberFormatter = NumberFormatter()
    
    private(set) var value: Int! {
        didSet {
            text = numberFormatter.string(from: NSNumber(value: value))
        }
    }
    
    init (_ value: Int = 0) {
        super.init()
        self.value = value
        
        numberFormatter.groupingSeparator = " "
        numberFormatter.groupingSize = 3
        numberFormatter.usesGroupingSeparator = true
        
        text = numberFormatter.string(from: NSNumber(value: value))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var timer: Timer?
    
    func changeValue (to newValue: Int, duration: TimeInterval) {
        timer?.invalidate()
        timer = nil
        let difference = Double(abs(value - newValue))
        
        timer = Timer.scheduledTimer(withTimeInterval: (duration / difference), repeats: true, block: { (t) in
            if self.value < newValue {
                self.value += 1
            }
            else if self.value > newValue {
                self.value -= 1
            }
            else {
                self.timer?.invalidate()
            }
        })
        
        timer?.fire()
    }
    
}
