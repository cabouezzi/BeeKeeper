//
//  SCNNode.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 9/28/23.
//

import SceneKit

extension SCNNode {
    func addChildren(_ children: [SCNNode]) {
        for child in children {
            addChildNode(child)
        }
    }
    
    func addChildren(_ children: SCNNode...) {
        for child in children {
            addChildNode(child)
        }
    }
}

extension CAAnimation {
    @available(*, deprecated, renamed: "animationPlayerFromScene")
    static func animationWithSceneNamed(name: String) -> CAAnimation? {
        var animation: CAAnimation?
        if let scene = SCNScene(named: name) {
            scene.rootNode.enumerateChildNodes { child, stop in
                if !child.animationKeys.isEmpty {
                    animation = child.animation(forKey: child.animationKeys.first!)
                    stop.initialize(to: true)
                }
            }
        }
        return animation
    }
    
    static func animationPlayerFromScene(_ name: String) -> SCNAnimationPlayer? {
        var animation: SCNAnimationPlayer?
        if let scene = SCNScene(named: name) {
            scene.rootNode.enumerateChildNodes { child, stop in
                guard let key = child.animationKeys.first else { return }
                animation = child.animationPlayer(forKey: key)
                animation?.stop()
                stop.initialize(to: true)
            }
        }
        return animation
    }
}
