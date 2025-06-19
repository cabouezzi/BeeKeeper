//
//  EvolutionDetailsViewModel.swift
//  BeeKeeper
//
//  Created by Chaniel Abou-Ezzi on 6/18/25.
//

import Combine

class EvolutionDetailsViewModel: ObservableObject {
    @Published var gene: Gene = .furI
    @Published var unlockedGenes: Set<Gene> = GameManager.shared.account.unlockedGenes
}
