//
//  StructureDetailsViewModel.swift
//  BeeKeeper
//
//  Created by Chaniel Abou-Ezzi on 6/17/25.
//

import Combine

final class StructureDetailsViewModel: ObservableObject {
    let structure: Structure
    
    convenience init() {
        let incubator = Incubator()
        try? incubator.startIncubating(.init(seconds: 10))
        self.init(structure: incubator)
    }
    
    init(structure: Structure) {
        self.structure = structure
    }
}
