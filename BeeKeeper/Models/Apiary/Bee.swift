//
//  Bee.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 9/8/23.
//

import SceneKit

class Bee: SCNNode, Model, Producer, Codable {
    private(set) var nickname: String
    
    var genetics: Set<Gene>
    
    var production: Resources
    var producerAssignment: Structure?
    
    var honeyConsumption: Float = 0.01
    var bodyTemperature: Float = 70
    var intimidation: Float = 5
    var stingerDamage: Float = 5
    var venomDamage: Float = 20
    
    override init() {
        self.genetics = GameManager.shared.account.unlockedGenes
        self.production = Resources(honey: 0.5, pollen: 0.25, beeBread: 1)
        self.nickname = "Bee"
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init(from decoder: Decoder) throws {
        fatalError()
    }
    
    func encode(to encoder: Encoder) throws {
        fatalError()
    }
    
    func accept<T>(_ visitor: T) -> T.ReturnType where T : ModelVisitor {
        return visitor.visitBee(self)
    }
}
