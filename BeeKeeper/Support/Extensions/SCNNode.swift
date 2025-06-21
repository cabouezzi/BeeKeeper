//
//  SCNNode.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 9/28/23.
//

import SceneKit

extension SCNNode {
    /// The length of the mesh on the `y` axis
    var height: Float { self.boundingBox.max.y - self.boundingBox.min.y }
    /// The length of the mesh on the `x` axis
    var width: Float { self.boundingBox.max.x - self.boundingBox.min.x }
    /// The length of the mesh on the `z` axis
    var depth: Float { self.boundingBox.max.z - self.boundingBox.min.z }
    
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

extension SCNGeometry {
    /// The length of the mesh on the `y` axis
    var height: Float { self.boundingBox.max.y - self.boundingBox.min.y }
    /// The length of the mesh on the `x` axis
    var width: Float { self.boundingBox.max.x - self.boundingBox.min.x }
    /// The length of the mesh on the `z` axis
    var depth: Float { self.boundingBox.max.z - self.boundingBox.min.z }
}

extension CAAnimation {
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
