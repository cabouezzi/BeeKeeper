//
//  HoneyStorage.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 9/9/23.
//

final class HoneyStorage: Container {
    required init() {
        super.init()
        self.maximum = Resources(honey: 5000)
        self.name = "Honey Storage"
        self.area = DiscreteRect(x: 0, y: 0, width: 2, height: 1)
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
    override func accept<T>(_ visitor: T) -> T.ReturnType where T : ModelVisitor {
        visitor.visitHoneyStorage(self)
    }
}
