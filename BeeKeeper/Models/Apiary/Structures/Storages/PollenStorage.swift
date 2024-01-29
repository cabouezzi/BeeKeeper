//
//  PollenStorage.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 9/28/23.
//

import SceneKit

final class PollenStorage: Container {
    required init() {
        super.init()
        self.maximum = Resources(pollen: 200)
        self.area = DiscreteRect(x: 0, y: 0, width: 2, height: 2)
    }
    
    override func loadNode() {
        name = "Pollen Storage"
        geometry = Meshes.Structure.pollenStorage
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
        visitor.visitPollenStorage(self)
    }
}
