//
//  NodeService.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 9/24/23.
//

import SceneKit

final class NodeService: ModelVisitor {
    static let shared = NodeService()
    
    private init() {
        
    }
    
    func visitBee(_ model: Bee) -> SCNNode {
        return SCNNode()
    }
    
    func visitHive(_ model: Hive) -> SCNNode {
        let node = SCNNode()
        node.geometry = Meshes.Structure.hive
        node.position.y += 0.5
        return node
    }
}
