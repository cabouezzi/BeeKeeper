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
        // Load basic model
        let node = SCNNode()
        let bodyScene = SCNScene(named: "BeePlain.scn")
        guard let armature = bodyScene?.rootNode.childNode(withName: "BodyArmature", recursively: true) else {
            fatalError("Failed to load bee armature")
        }
        node.addChildNode(armature)
        node.eulerAngles.x = .pi / 2
        node.scale = SCNVector3(0.3, 0.3, 0.3)
        
        let head = node.childNode(withName: "Head", recursively: true)
        let torso = node.childNode(withName: "Torso", recursively: true)
        let stinger = node.childNode(withName: "Stinger", recursively: true)
        let abdomen = node.childNode(withName: "Abdomen", recursively: true)
        
        // Modify model based on genes
        if model.genetics.contains(.stripesI) {
            torso?.geometry = Meshes.Bee.Torso.yellowStripes
            abdomen?.geometry = Meshes.Bee.Abdomen.yellowStripes
        }
        
        #if DEBUG
        let animationPlayer = CAAnimation.animationPlayerFromScene("BeeWiggle.scn")!
        animationPlayer.animation.repeatCount = 5
        node.childNode(withName: "BodyArmature", recursively: true)?.addAnimationPlayer(animationPlayer, forKey: "wiggle")
        animationPlayer.play()
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
        
        
        for i in 0..<model.honeycombs.count {
            let frame = SCNNode(geometry: Meshes.Structure.honeycombFrame)
            node.addChildNode(frame)
            frame.position.y += frame.geometry!.height * 0.7
            frame.position.z = Float(i - 1) * node.geometry!.depth / 4
        }
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
            -(self.boundingBox.max.x - self.boundingBox.min.x) / 2,
            0,
            -(self.boundingBox.max.z - self.boundingBox.min.z) / 2
        )
    }
}
