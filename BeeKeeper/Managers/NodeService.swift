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
    
    private func movePivotToCorner(_ node: SCNNode) {
        node.pivot = SCNMatrix4MakeTranslation(
            -(node.geometry!.boundingBox.max.x - node.geometry!.boundingBox.min.x) / 2,
            0,
            -(node.geometry!.boundingBox.max.z - node.geometry!.boundingBox.min.z) / 2
        )
    }
    
    func visitBee(_ model: Bee) -> BKNode {
        let bodyScene = SCNScene(named: "BeeBody1.scn")!
        let animation = CAAnimation.animationWithSceneNamed(name: "BeeWiggle.scn")!
//        let animation = wiggleScene?.entryWithIdentifier("action_container-BodyArmature", withClass: CAAnimation.self)
        animation.repeatCount = 1
        let node = SCNNode()
        node.addChildNode(bodyScene.rootNode.childNode(withName: "BodyArmature", recursively: true)!)
        node.childNode(withName: "BodyArmature", recursively: true)?.addAnimation(animation, forKey: "wiggle")
        node.eulerAngles.x = .pi / 2
        
        let bknode = BKNode(model: model)
        // TODO: Complete
        bknode.addChildNode(node)
        return bknode
    }
    
    func visitHive(_ model: Hive) -> BKNode {
        let node = BKNode(model: model)
        node.geometry = Meshes.Structure.hive
        movePivotToCorner(node)
        return node
    }
    
    func visitHoneyStorage(_ model: HoneyStorage) -> BKNode {
        let node = BKNode(model: model)
        node.geometry = Meshes.Structure.honeyStorage
        movePivotToCorner(node)
        return node
    }
    
    func visitPollenStorage(_ model: PollenStorage) -> BKNode {
        let node = BKNode(model: model)
        node.geometry = Meshes.Structure.pollenStorage
        movePivotToCorner(node)
        return node
    }
    
    func visitIncubator(_ model: Incubator) -> BKNode {
        let node = BKNode(model: model)
        node.geometry = Meshes.Structure.incubator
        node.position.y += (node.geometry!.boundingBox.max.y - node.geometry!.boundingBox.min.y) / 2
        movePivotToCorner(node)
        return node
    }
}

