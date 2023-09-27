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
    
    func visitBee(_ model: Bee) -> BKNode {
        return BKNode(model: model)
    }
    
    func visitHive(_ model: Hive) -> BKNode {
        let node = BKNode(model: model)
        node.geometry = Meshes.Structure.hive
        node.position.y += 0.5
        return node
    }
    
    func visitHoneyStorage(_ model: HoneyStorage) -> BKNode {
        let node = BKNode(model: model)
        node.geometry = Meshes.Structure.hive
        node.position.y += 0.5
        return node
    }
}
