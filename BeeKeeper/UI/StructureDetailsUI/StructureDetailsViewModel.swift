//
//  StructureDetailsViewModel.swift
//  BeeKeeper
//
//  Created by Chaniel Abou-Ezzi on 6/17/25.
//

import Combine

final class StructureDetailsViewModel: ObservableObject {
    let structure: Structure
    
    init(structure: Structure) {
        self.structure = structure
    }
}
