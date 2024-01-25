//
//  Bubble.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 1/13/24.
//

import SceneKit

class Bubble: SCNNode {
    private var block: (() -> Void)?
    
    enum BubbleTexture {
        case honey
        case pollen
        case blank
        case plus
        
        static func fromResourcePath(_ path: KeyPath<Resources, Float>) -> BubbleTexture {
            switch path {
            case \.honey: return .honey
            case \.pollen: return .pollen
            default: return .blank
            }
        }
        
        fileprivate func texture() -> SCNGeometry {
            switch self {
            case .honey: return Meshes.Bubble.honey
            case .pollen: return Meshes.Bubble.pollen
            case .blank: return Meshes.Bubble.blank
            case .plus: return Meshes.Bubble.plus
            }
        }
    }
    
    init(_ texture: BubbleTexture) {
        super.init()
        geometry = texture.texture()
        geometry?.firstMaterial?.writesToDepthBuffer = false
        geometry?.firstMaterial?.readsFromDepthBuffer = false
        geometry?.firstMaterial?.lightingModel = .constant
        
        scale = SCNVector3(x: 1.5, y: 1.5, z: 1.5)
        constraints = [SCNBillboardConstraint()]
        castsShadow = false
        opacity = 1
        
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
        runAction(action) { [weak self] in
            self?.removeFromParentNode()
        }
    }
}
