//
//  Flower.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 9/8/23.
//

import Foundation

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
        self.maximum = Resources(pollen: 500)
        self.name = "Flower"
        self.area = DiscreteRect(x: 0, y: 0, width: 1, height: 1)
        self.maximumAssignedBees = 1
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
    
    func accept(_ producer: some Producer) throws {
        var produce = Resources(pollen: producer.production.pollen)
        try? fill(&produce)
    }
    
    override func accept<T>(_ visitor: T) -> T.ReturnType where T : ModelVisitor {
        return visitor.visitFlower(self)
    }
}
