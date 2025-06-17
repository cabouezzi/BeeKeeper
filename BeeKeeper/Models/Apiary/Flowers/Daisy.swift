//
//  Daisy.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 1/28/24.
//

import Foundation

class Daisy: Flower {
    required init() {
        super.init()
        maximum = Resources(pollen: 100)
        area = DiscreteRect(x: 0, y: 0, width: 1, height: 1)
        maximumAssignedBees = 2
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
    
    override func loadNode() {
        name = "Daisy"
        geometry = Meshes.Flowers.daisy
        self.details = "A common flower found near apiaries. Produces enough pollen to support two bees."
    }
}
