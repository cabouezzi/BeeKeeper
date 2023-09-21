//
//  Honeycomb.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 9/10/23.
//

public class Honeycomb: Collector {
    unowned var hive: Hive
    
    public var containing: Resources = Resources()
    public var maximum: Resources = Resources(honey: 100)
    
    init(hive: Hive) {
        self.hive = hive
    }
    
    func accept<T>(_ visitor: T) -> T.ReturnType where T : ModelVisitor {
        return visitor.visitHoneycomb(self)
    }
    
    public func accept(_ producer: some Producer) throws {
        _ = try? fill(Resources(honey: producer.production.honey))
    }
    
    public func fill(_ resources: Resources) throws -> Resources {
        guard !containing.canAfford(maximum) else { throw ContainerError.containerFull }
        var excess = resources
        containing.fill(&excess, cap: maximum)
        return excess
    }
    
    public func collect() -> Resources {
        let holder = containing
        containing = Resources()
        return holder
    }
}
