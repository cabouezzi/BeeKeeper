//
//  Hive.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 9/8/23.
//

public final class Hive: Structure, Collector {
    
    public internal(set) var honeycombs: [Honeycomb] = []
    
    public var containing: Resources { honeycombs.reduce(Resources(), { $0.adding($1.containing) }) }
    public var maximum: Resources { honeycombs.reduce(Resources(), { $0.adding($1.maximum) }) }
    
    public required init() {
        super.init()
        self.name = "Hive"
        self.area = DiscreteRect(x: 0, y: 0, width: 2, height: 2)
        
        honeycombs = [
            Honeycomb(hive: self)
        ]
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
    override func accept<T>(_ visitor: T) -> T.ReturnType where T : ModelVisitor {
        return visitor.visitHive(self)
    }
    
    // MARK: Collector
    
    public func accept(_ producer: some Producer) throws {
        var lastError: Error!
        for honeycomb in honeycombs {
            do {
                try honeycomb.accept(producer)
                return
            } catch {
                lastError = error
            }
        }
        throw lastError
    }
    
    public func fill(_ resources: Resources) throws -> Resources {
        var excess = resources
        for honeycomb in honeycombs {
            excess = (try? honeycomb.fill(excess)) ?? excess
        }
        guard !excess.canAfford(resources) else { throw ContainerError.containerFull }
        return excess
    }
    
    public func collect() -> Resources {
        var commulative = Resources()
        for honeycomb in honeycombs {
            commulative = commulative.adding(honeycomb.collect())
        }
        return commulative
    }
}
