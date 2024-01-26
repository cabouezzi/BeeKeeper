//
//  Honeycomb.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 9/10/23.
//

import SceneKit

class Honeycomb: SCNNode, Collector, Codable {
    unowned var hive: Hive!
    
    var containing: Resources = Resources()
    var maximum: Resources = Resources(honey: 100)
    
    init(hive: Hive) {
        self.hive = hive
        super.init()
        
        self.geometry = Meshes.Structure.honeycombFrame
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private enum CodingKeys: CodingKey {
        case containing, maximum
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        containing = try container.decode(Resources.self, forKey: .containing)
        maximum = try container.decode(Resources.self, forKey: .maximum)
        super.init()
        self.geometry = Meshes.Structure.honeycombFrame
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(containing, forKey: .containing)
        try container.encode(maximum, forKey: .maximum)
    }
    
    func resourceTargets() -> Set<WritableKeyPath<Resources, Float>> {
        return [\Resources.honey]
    }
    
    func accept(_ producer: some Producer) throws {
        var produce = Resources(honey: producer.production.honey)
        try? fill(&produce)
    }
    
    func fill(_ resources: inout Resources) throws {
        guard !containing.canAfford(maximum) else { throw ContainerError.containerFull }
        containing.fill(&resources, cap: maximum)
    }
    
    func remove(_ resources: Resources) throws {
        guard containing.canAfford(resources) else { throw ContainerError.containerInsufficient }
        containing = containing.subtracting(resources)
    }
    
    func transfer(to container: Container) throws {
        try container.fill(&containing)
    }
}


class Pollencomb: Honeycomb {
    // TODO: Refactor code to read how many bees with gene are assigned to hive
    let beeBreadCounter = 1
    
    override init(hive: Hive) {
        super.init(hive: hive)
        maximum = Resources(pollen: 100)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
    }
    
    override func resourceTargets() -> Set<WritableKeyPath<Resources, Float>> {
        return [\Resources.pollen]
    }
    
    override func fill(_ resources: inout Resources) throws {
        if containing.beeBread == 0 {
            try super.fill(&resources)
        }
        if containing.canAfford(maximum) && beeBreadCounter > 0 {
            containing = Resources(beeBread: 1)
        }
    }
    
    override func accept(_ producer: some Producer) throws {
        // Max pollen production = 0.35 per second
        // ==> pollen per hour ≈ 1265
        // ==> pollen per hour / 12.5 ≈ 100 pollen per hour = 1 bee bread per hour
        // Multiply by amount of bees with gene
        let multiplier: Float = powf(1.01, Float(beeBreadCounter)) / 12.5
        var produce = Resources(pollen: producer.production.pollen * multiplier)
        try? fill(&produce)
    }
}
