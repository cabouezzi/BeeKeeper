//
//  SKNodeAnimations.swift
//  Bee Keeper 3
//
//  Created by Chaniel Ezzi on 1/1/21.
//  Copyright © 2021 Cezzi. All rights reserved.
//

import SpriteKit

extension SKNode {
    func fadeUp () {
        let fadeIn = SKAction.fadeIn(withDuration: 0.3)
        let moveUp = SKAction.moveBy(x: 0, y: frame.size.height / 6, duration: 0.3)
        let sequence = SKAction.group([fadeIn, moveUp])
        sequence.timingMode = .easeIn
        
        run(sequence)
    }
    
    func fadeDown () {
        let fadeOut = SKAction.fadeOut(withDuration: 0.3)
        let moveDown = SKAction.moveBy(x: 0, y:  -frame.size.height / 6, duration: 0.3)
        let sequence = SKAction.group([fadeOut, moveDown])
        sequence.timingMode = .easeOut
        
        run(sequence)
    }
    
    func fadeDownAndRemove () {
        let fadeOut = SKAction.fadeOut(withDuration: 0.3)
        let moveDown = SKAction.moveBy(x: 0, y:  -frame.size.height / 6, duration: 0.3)
        let sequence = SKAction.group([fadeOut, moveDown])
        sequence.timingMode = .easeOut
        
        run(sequence) {
            self.removeFromParent()
        }
    }
    
    func pop () {
        let shrink = SKAction.scale(to: 0.8, duration: 0.075)
        let expand = SKAction.scale(to: 1, duration: 0.075)
        
        run(shrink, completion: {self.run(expand)})
    }
}
