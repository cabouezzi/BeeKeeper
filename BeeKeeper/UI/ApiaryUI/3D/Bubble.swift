//
//  Bubble.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 1/13/24.
//

import SceneKit

class Bubble: SCNNode {
    private var block: (() -> Void)?
    
    override init() {
        super.init()
        self.geometry = Meshes.Bubble.blank
        self.scale = SCNVector3(x: 1.5, y: 1.5, z: 1.5)
        self.constraints = [SCNBillboardConstraint()]
        self.castsShadow = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func onTap(_ block: (() -> Void)?) {
        self.block = block
    }
    
    func burst(duration: CFTimeInterval = 0.25) {
        let action = SCNAction.group([
            SCNAction.scale(to: 4, duration: duration),
            SCNAction.fadeOut(duration: duration)
        ])
        runAction(action) {
            self.removeFromParentNode()
        }
    }
}
