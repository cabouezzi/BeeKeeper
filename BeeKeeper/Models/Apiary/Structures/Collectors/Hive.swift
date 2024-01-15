//
//  Hive.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 9/8/23.
//

import Foundation

class Hive: Container, Collector {
    var honeycombs: [Honeycomb] = []
    
    override var containing: Resources {
        get { honeycombs.reduce(Resources(), { $0.adding($1.containing) }) }
        set {
            var new = newValue.canAfford(containing) ? newValue.subtracting(containing) : containing.subtracting(newValue)
            newValue.canAfford(containing) ? try? fill(&new) : try? remove(new)
        }
    }
    
    override var maximum: Resources {
        get { honeycombs.reduce(Resources(), { $0.adding($1.maximum) }) }
        set { /* TODO: ? */ }
    }
    
    required init() {
        super.init()
        self.name = "Hive"
        self.area = DiscreteRect(x: 0, y: 0, width: 2, height: 2)
        self.maximumBees = 4
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
    
    override func accept<T>(_ visitor: T) -> T.ReturnType where T : ModelVisitor {
        return visitor.visitHive(self)
    }
    
    @discardableResult
    func addHoneycomb() throws -> Honeycomb {
        guard honeycombs.count < 3 else { throw NSError(domain: "BeeKeeper", code: 101) }
        let honeycomb = Honeycomb(hive: self)
        honeycombs.append(honeycomb)
        return honeycomb
    }
    
    // MARK: Collector
    func resourceTargets() -> Set<WritableKeyPath<Resources, Float>> {
        return honeycombs.reduce([], { $0.union($1.resourceTargets()) })
    }
    
    func transfer(to container: Container) throws {
        guard container !== self else { throw ContainerError.transferToSelf }
        for honeycomb in honeycombs where !honeycomb.containing.isEmpty() {
            try container.fill(&honeycomb.containing)
        }
    }
    
    override func fill(_ resources: inout Resources) throws {
        guard !containing.canAfford(maximum) else { throw ContainerError.containerFull }
        for honeycomb in honeycombs {
            guard !resources.isEmpty() else { return }
            try? honeycomb.fill(&resources)
        }
    }
    
    override func remove(_ resources: Resources) throws {
        guard containing.canAfford(resources) else { throw ContainerError.containerInsufficient }
        var remaining = resources
        for honeycomb in honeycombs {
            guard !resources.isEmpty() else { return }
            if honeycomb.containing.canAfford(remaining) {
                try! honeycomb.remove(remaining)
                return
            } else {
                remaining = remaining.subtracting(honeycomb.containing)
                try! honeycomb.remove(honeycomb.containing)
            }
        }
    }
}
