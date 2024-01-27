//
//  EvolutionGeneDataSource.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 1/27/24.
//

import Foundation

final class EvolutionGeneDataSource: EvolutionViewDataSource {
    static let shared = EvolutionGeneDataSource()
    
    private init() {
        
    }
    
    func geneData(for gene: Gene) -> GeneData {
        switch gene {
        default: return GeneData(gene: gene,
                                 details: "Aha! I think I've figured it out! Turns out it's the fur that gives bees their stripes pattern, but it's another mutation that sets their warning colors – aposematism. Let's see if this works now...",
                                 cost: Resources(money: 10000, honey: 10000, pollen: 10000, beeBread: 10000))
        }
    }
}
