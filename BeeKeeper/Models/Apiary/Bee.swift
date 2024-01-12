//
//  Bee.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 9/8/23.
//

import Foundation

class Bee: Model, Producer, Codable {
    let id: UUID
    var name: String = UUID().uuidString
    var genetics: Set<Gene>
    
    var production: Resources
    var producerTarget: Structure?
    
    var honeyConsumption: Float = 0.01
    var bodyTemperature: Float = 70
    var intimidation: Float = 5
    var stingerDamage: Float = 5
    var venomDamage: Float = 20
    
    init() {
        self.id = UUID()
        self.genetics = GameManager.shared.account.unlockedGenes
        self.production = Resources(honey: 0.5, pollen: 0.25, beeBread: 1)
    }
    
    func accept<T>(_ visitor: T) -> T.ReturnType where T : ModelVisitor {
        return visitor.visitBee(self)
    }
}

extension Bee: Hashable {
    static func == (lhs: Bee, rhs: Bee) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
