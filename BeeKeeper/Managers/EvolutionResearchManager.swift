//
//  EvolutionGeneDataSource.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 1/27/24.
//

import Foundation

final class EvolutionResearchManager {
    enum ResearchState {
        case idle
        case researching(_ research: TimedReward<Gene>)
        case completed(_ research: TimedReward<Gene>)
    }
    
    static let shared = EvolutionResearchManager()

    var researchState: ResearchState {
        if let research = currentResearch {
            return research.isComplete ? .completed(research) : .researching(research)
        } else {
            return .idle
        }
    }
    
    var currentResearch: TimedReward<Gene>? {
        get { GameManager.shared.account.research }
        set { GameManager.shared.account.research = newValue }
    }
    
    private init() {
        
    }
    
    @discardableResult
    func beginResearch(for gene: Gene) throws -> TimedReward<Gene> {
        let account = GameManager.shared.account
        let prereq = GeneNetwork.shared.prerequisites(for: gene)
        guard prereq.allSatisfy({ account.unlockedGenes.contains($0) }) else {
            throw GeneError.missingPrerequisites(prereq.filter({ !account.unlockedGenes.contains($0) }))
        }
        guard !GameManager.shared.account.unlockedGenes.contains(gene) else {
            throw GeneError.alreadyResearched(gene)
        }
        
        guard GameManager.shared.getAllResources().canAfford(gene.cost) else { throw ContainerError.containerInsufficient }
        
        try GameManager.shared.remove(gene.cost)
        //            if let icon = evolutionView.iconForGene(gene) {
        //                icon.childNode(withName: "lock")?.removeFromParent()
        //            }
        //            updateLockNodes()
        let research = TimedReward(duration: TimeInterval(hours: 1), reward: gene)
        currentResearch = research
        return research
    }
    
    func claimResearch() throws {
        guard let research = currentResearch else { throw GeneError.nothingResearching }
        GameManager.shared.unlockGene(research.reward)
        currentResearch = nil
    }
    
    func forceComplete() throws {
        guard let research = currentResearch else { throw GeneError.nothingResearching }
        research.forceComplete()
    }
}
