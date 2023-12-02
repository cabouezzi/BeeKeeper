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
        let bodyScene = SCNScene(named: "BeeBody.scn")!
        let node = SCNNode()
        node.addChildNode(bodyScene.rootNode.childNode(withName: "BodyArmature", recursively: true)!)
        node.eulerAngles.x = .pi / 2
        node.eulerAngles.x = .pi / 2
        node.scale = SCNVector3(0.3, 0.3, 0.3)
        
        #if DEBUG
        let animatPlayer = CAAnimation.animationPlayerFromScene("BeeWiggle.scn")!
        animatPlayer.animation.repeatCount = 1
        node.childNode(withName: "BodyArmature", recursively: true)?.addAnimationPlayer(animatPlayer, forKey: "wiggle")
        animatPlayer.play()
        #endif
        
        let bknode = BKNode(model: model)
        // TODO: Complete: Modify model based on upgrades and assign to base armature fetched from BeeBody.scn
        bknode.addChildNode(node)
        return bknode
    }
    
    func visitHive(_ model: Hive) -> BKNode {
        let node = BKNode(model: model)
        node.geometry = Meshes.Structure.hive
        node.movePivotToCorner()
        return node
    }
    
    func visitHoneyStorage(_ model: HoneyStorage) -> BKNode {
        let node = BKNode(model: model)
        node.geometry = Meshes.Structure.honeyStorage
        node.movePivotToCorner()
        return node
    }
    
    func visitPollenStorage(_ model: PollenStorage) -> BKNode {
        let node = BKNode(model: model)
        node.geometry = Meshes.Structure.pollenStorage
        node.movePivotToCorner()
        return node
    }
    
    func visitIncubator(_ model: Incubator) -> BKNode {
        let node = BKNode(model: model)
        node.geometry = Meshes.Structure.incubator
        node.position.y += (node.geometry!.boundingBox.max.y - node.geometry!.boundingBox.min.y) / 2
        node.movePivotToCorner()
        return node
    }
    
    func visitFlower(_ model: Flower) -> BKNode {
        let node = BKNode(model: model)
        node.geometry = Meshes.Flowers.blackfoot
        node.movePivotToCorner()
        node.rotation.y += .pi
        return node
    }
}

fileprivate extension SCNNode {
    func movePivotToCorner() {
        self.pivot = SCNMatrix4MakeTranslation(
            -(self.geometry!.boundingBox.max.x - self.geometry!.boundingBox.min.x) / 2,
            0,
            -(self.geometry!.boundingBox.max.z - self.geometry!.boundingBox.min.z) / 2
        )
    }
}
