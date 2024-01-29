//
//  Rose.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 1/28/24.
//

import SceneKit

class Rose: Flower {
    required init() {
        super.init()
        maximum = Resources(pollen: 750)
        area = DiscreteRect(x: 0, y: 0, width: 2, height: 2)
        maximumAssignedBees = 4
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
    
    override func loadNode() {
        name = "Rose"
        geometry = Meshes.Flowers.rose
    }
    
    override func pollinationNode() -> SCNNode {
        let nodes = SCNScene(named: "Rose.scn")!.rootNode.childNodes.filter({ $0.name?.contains("node") ?? false })
        guard let random = nodes.randomElement() else {
            let node = SCNNode()
            node.worldPosition = worldPosition
            node.worldPosition.y = boundingBox.max.y
            return node
        }
        random.worldPosition += worldPosition
        return random
    }
}
