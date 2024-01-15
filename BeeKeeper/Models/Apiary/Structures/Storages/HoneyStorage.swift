//
//  HoneyStorage.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 9/9/23.
//

import SceneKit

final class HoneyStorage: Container {
    required init() {
        super.init()
        self.maximum = Resources(honey: 5000)
        self.name = "Honey Storage"
        self.area = DiscreteRect(x: 0, y: 0, width: 2, height: 1)
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
        visitor.visitHoneyStorage(self)
    }
}
