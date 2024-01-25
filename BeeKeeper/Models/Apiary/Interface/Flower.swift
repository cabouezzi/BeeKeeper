//
//  Flower.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 9/8/23.
//

import Foundation
import SceneKit

enum FlowerGrowthState {
    case sprouting
    case seedling
    case budding
    case adult
    case dead
}

class Flower: Container, Collector {
    var growthState: FlowerGrowthState = .seedling
    private(set) var datePlanted: Date
    var lifespan: TimeInterval = 0
    var dateDies: Date { return datePlanted.advanced(by: lifespan)}
    
    required init() {
        self.datePlanted = Date()
        super.init()
        self.maximum = Resources(pollen: 10)
        self.name = "Flower"
        self.area = DiscreteRect(x: 0, y: 0, width: 2, height: 2)
        self.maximumAssignedBees = 4
    }
    
    override func loadNode() {
        self.geometry = Meshes.Flowers.daisy
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
    }
    
    func resourceTargets() -> Set<WritableKeyPath<Resources, Float>> {
        return [\Resources.pollen]
    }
    
    override func accept<T>(_ visitor: T) -> T.ReturnType where T : ModelVisitor {
        return visitor.visitFlower(self)
    }
    
    func pollinationNode() -> SCNNode {
        let one = SCNNode()
        one.worldPosition = worldPosition + SCNVector3(x: -0.188, y: 2.207, z: -0.248)
        let two = SCNNode()
        two.worldPosition = worldPosition + SCNVector3(x: -0.188, y: 1.896, z: 0.265)
        let three = SCNNode()
        three.worldPosition = worldPosition + SCNVector3(x: 0.413, y: 1.642, z: 0.05)
        return [one, two, three].randomElement()!
    }
}
