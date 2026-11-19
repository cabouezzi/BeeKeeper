//
//  StructureDetailsViewModel.swift
//  BeeKeeper
//
//  Created by Chaniel Abou-Ezzi on 6/17/25.
//

import Combine
import Observation

@MainActor
@Observable
final class StructureDetailsViewModel {
    let structure: Structure
    
    @ObservationIgnored let didBuildHoneycomb = PassthroughSubject<Void, Never>()
    
    init(structure: Structure) {
        self.structure = structure
    }
}
