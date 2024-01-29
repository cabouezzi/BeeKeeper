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
    var growthState: FlowerGrowthState = .seedling // TODO: No purpose yet
    private(set) var datePlanted: Date
    var lifespan: TimeInterval = 0
    var dateDies: Date { return datePlanted.advanced(by: lifespan)}
    
    required init() {
        self.datePlanted = Date()
        super.init()
        self.name = "Flower"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadNode() {
        fatalError("This class is a prototype and should not be initialized on its own.")
    }
    
    private enum CodingKeys: CodingKey {
        case datePlanted, lifespan
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        datePlanted = try container.decode(Date.self, forKey: .datePlanted)
        lifespan = try container.decode(TimeInterval.self, forKey: .lifespan)
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(datePlanted, forKey: .datePlanted)
        try container.encode(lifespan, forKey: .lifespan)
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
