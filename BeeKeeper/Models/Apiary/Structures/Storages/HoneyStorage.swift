//
//  HoneyStorage.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 9/9/23.
//

public final class HoneyStorage: Structure, Container {
    public var containing = Resources()
    public var maximum = Resources(honey: 5000)
    
    public required init() {
        super.init()
        self.name = "Honey Storage"
        self.area = DiscreteRect(x: 0, y: 0, width: 2, height: 2)
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
    public func fill(_ resources: Resources) throws -> Resources {
        guard !containing.canAfford(maximum) else { throw ContainerError.containerFull }
        var amount = resources
        containing.fill(&amount, cap: maximum)
        return amount
    }
    
    public func remove(_ resources: Resources) throws {
        guard containing.canAfford(resources) else { throw ContainerError.containerInsufficient }
        containing = containing.subtracting(resources)
    }
    
    override func accept<T>(_ visitor: T) -> T.ReturnType where T : ModelVisitor {
        visitor.visitHoneyStorage(self)
    }
}
