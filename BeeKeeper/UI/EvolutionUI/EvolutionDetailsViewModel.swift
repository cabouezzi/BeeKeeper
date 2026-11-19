//
//  EvolutionDetailsViewModel.swift
//  BeeKeeper
//
//  Created by Chaniel Abou-Ezzi on 6/18/25.
//

import Observation

@MainActor
@Observable
final class EvolutionDetailsViewModel {
    var gene: Gene = EvolutionResearchManager.shared.currentResearch?.reward ?? .furI
    var unlockedGenes: Set<Gene> = GameManager.shared.account.unlockedGenes
}
