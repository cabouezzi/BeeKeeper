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
        get {
            honeycombs.reduce(Resources(), { $0.adding($1.containing) })
        }
        set {
            var new = newValue.subtracting(containing)
            try? fill(&new)
        }
    }
    override var maximum: Resources {
        get {
            honeycombs.reduce(Resources(), { $0.adding($1.maximum) })
        }
        set {
            // TODO: ?
        }
    }
    
    required init() {
        super.init()
        self.name = "Hive"
        self.area = DiscreteRect(x: 0, y: 0, width: 2, height: 2)
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
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
    func accept(_ producer: some Producer) throws {
        for honeycomb in honeycombs {
            do {
                try honeycomb.accept(producer)
                return
            } catch ContainerError.containerFull {
                continue
            }
        }
    }
    
    func transfer(to container: Container) throws {
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
}
