//
//  Honeycomb.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 9/10/23.
//

class Honeycomb: Collector {
    unowned var hive: Hive
    
    var containing: Resources = Resources()
    var maximum: Resources = Resources(honey: 100)
    
    init(hive: Hive) {
        self.hive = hive
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
