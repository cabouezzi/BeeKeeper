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
