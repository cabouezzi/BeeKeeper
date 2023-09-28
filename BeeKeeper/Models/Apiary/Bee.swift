//
//  Bee.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 9/8/23.
//

import Foundation

public class Bee: Model, Producer, Codable {
    var name: String = UUID().uuidString
    var genetics: Set<Gene>
    
    public var production: Resources
    
    init() {
        self.genetics = GameManager.shared.account.unlockedGenes
        self.production = Resources(honey: 3, pollen: 2, beeBread: 1)
    }
    
    func accept<T>(_ visitor: T) -> T.ReturnType where T : ModelVisitor {
        return visitor.visitBee(self)
    }
}
