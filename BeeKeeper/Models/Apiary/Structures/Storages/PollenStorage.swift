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
        self.maximum = Resources(pollen: 5000)
        self.name = "Pollen Storage"
        self.area = DiscreteRect(x: 0, y: 0, width: 3, height: 2)
    }
    
    override func loadNode() {
        self.geometry = Meshes.Structure.pollenStorage
        self.scale = SCNVector3(1.5, 1.5, 1.5)
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
