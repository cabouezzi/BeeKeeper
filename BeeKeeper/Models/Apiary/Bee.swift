//
//  Bee.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 9/8/23.
//

import Foundation

class Bee: Model, Producer, Codable {
    var name: String = UUID().uuidString
    var genetics: Set<Gene>
    
    var production: Resources
    var producerTarget: UUID?
    
    var honeyConsumption: Float = 0.01
    var bodyTemperature: Float = 70
    var intimidation: Float = 5
    var stingerDamage: Float = 5
    var venomDamage: Float = 20
    
    init() {
        self.genetics = GameManager.shared.account.unlockedGenes
        self.production = Resources(honey: 0.5, pollen: 0.25, beeBread: 1)
    }
    
    func accept<T>(_ visitor: T) -> T.ReturnType where T : ModelVisitor {
        return visitor.visitBee(self)
    }
}
