//
//  Lavender.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 1/20/24.
//

import Foundation

class Lavender: Flower {
    required init() {
        super.init()
        area = DiscreteRect(x: 0, y: 0, width: 2, height: 2)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
    
    override func loadNode() {
        self.geometry = Meshes.Flowers.lavender
    }
}
