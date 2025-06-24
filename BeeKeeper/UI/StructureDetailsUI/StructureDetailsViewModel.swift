//
//  StructureDetailsViewModel.swift
//  BeeKeeper
//
//  Created by Chaniel Abou-Ezzi on 6/17/25.
//

import Combine

final class StructureDetailsViewModel: ObservableObject {
    let structure: Structure
    
    // TODO: Refactor
    // Literally only need for the hive details in the tutorial
    let didBuildHoneycomb = PassthroughSubject<Void, Never>()
    
    init(structure: Structure) {
        self.structure = structure
    }
}
