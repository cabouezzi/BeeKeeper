//
//  NodeService.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 9/24/23.
//

import SceneKit

/// ``ModelVisitor`` service that returns a ``BKNode`` for models to be displayed as.
///
/// - Note: This is a singleton object, meaning it can only be accessed through the ``shared`` property.
final class NodeService: ModelVisitor {
    static let shared = NodeService()
    
    private init() {
        
    }
    
    func visitBee(_ model: Bee) -> BKNode {
        let node = BKNode(model: model)
        node.geometry = Meshes.Bee.body
        return node
    }
    
    func visitHive(_ model: Hive) -> BKNode {
        let node = BKNode(model: model)
        node.geometry = Meshes.Structure.hive
        node.position.y += 0.5
        return node
    }
    
    func visitHoneyStorage(_ model: HoneyStorage) -> BKNode {
        let node = BKNode(model: model)
        node.geometry = Meshes.Structure.honeyStorage
        node.position.y += (node.geometry!.boundingBox.max.y - node.geometry!.boundingBox.min.y) / 2
        return node
    }
}
