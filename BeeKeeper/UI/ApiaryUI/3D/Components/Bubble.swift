//
//  Bubble.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 1/13/24.
//

import SceneKit

class Bubble: SCNNode {
    private var block: (() -> Void)?
    
    init(_ texture: SCNGeometry = Meshes.Bubble.blank) {
        super.init()
        self.geometry = texture
        self.geometry?.firstMaterial?.writesToDepthBuffer = false
        self.geometry?.firstMaterial?.readsFromDepthBuffer = false
        self.pivot = SCNMatrix4MakeTranslation(0, -1, 0)
        self.scale = SCNVector3(x: 1.5, y: 1.5, z: 1.5)
        self.constraints = [SCNBillboardConstraint()]
        self.castsShadow = false
        
        let duration: TimeInterval = 5
        let bobUp = SCNAction.moveBy(x: 0, y: 0.5, z: 0, duration: duration / 2)
        bobUp.timingMode = .easeInEaseOut
        let bobDown = SCNAction.moveBy(x: 0, y: -0.5, z: 0, duration: duration / 2)
        bobDown.timingMode = .easeInEaseOut
        let action = SCNAction.repeatForever(SCNAction.sequence([bobUp, bobDown]))
        runAction(action)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func onTap(_ block: (() -> Void)?) {
        self.block = block
    }
    
    func burst(duration: CFTimeInterval = 0.25) {
        let action = SCNAction.sequence([
            SCNAction.scale(by: 0.9, duration: duration / 4),
            SCNAction.group([
                SCNAction.scale(to: 4, duration: duration * 3 / 4),
                SCNAction.fadeOut(duration: duration)
            ])
        ])
        block?()
        runAction(action) {
            self.removeFromParentNode()
        }
    }
}
