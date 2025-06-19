//
//  GeneNetwork.swift
//  Bee Keeper
//
//  Created by Chaniel Ezzi on 4/22/21.
//  Copyright © 2021 Cezzi. All rights reserved.
//

import Foundation

enum GeneError: LocalizedError {
    case missingPrerequisites(Set<Gene>)
    case alreadyResearched(Gene)
    case nothingResearching
    
    var errorDescription: String? {
        switch self {
        case .missingPrerequisites(let genes): return "The following prerequisites are required: \(genes.map({ $0.rawValue }).joined(separator: ", "))"
        case .alreadyResearched(let gene): return "\(gene.rawValue) has already been researched"
        case .nothingResearching: return "Nothing is currently being researched"
        }
    }
}

class GeneNetwork {
    struct Link: Hashable {
        let from: Gene
        let to: Gene
    }
    
    static let shared = GeneNetwork()
    
    private init() {
        
    }
    
    func prerequisites(for gene: Gene) -> Set<Gene> {
        return Set(edges.compactMap({ $0.to == gene ? $0.from : nil }))
    }
    
    func adjacentGenes(for gene: Gene) -> Set<Gene> {
        return Set(edges.compactMap({ $0.from == gene ? $0.to : nil }))
    }
    
    func isValidTopologicalOrdering() -> Bool {
        var vertices = Gene.allCases
        var edges = Array(edges)
        while !vertices.isEmpty {
            guard let source = vertices.first(where: { vert in
                !edges.contains(where: { $0.to == vert })
            }) else { return false}
            vertices.removeAll(where: { $0 == source })
            edges.removeAll(where: { $0.from == source })
        }
        return true
    }
    
    let edges: Set<Link> = {
        return [
            Link(from: .enzymesI, to: .enzymesII),
            Link(from: .enzymesII, to: .enzymesIII),
                Link(from: .enzymesI, to: .engineerI),
            Link(from: .enzymesIII, to: .bioluminescence),
                Link(from: .enzymesIII, to: .sustainability),
            
            Link(from: .engineerI, to: .engineerII),
            Link(from: .engineerII, to: .engineerIII),
                Link(from: .engineerII, to: .sustainability),
            Link(from: .engineerIII, to: .beeBread),
            
            Link(from: .furI, to: .furII),
                Link(from: .furI, to: .stingerI),
                Link(from: .furI, to: .stripesI),
                Link(from: .furI, to: .electricChargeI),
            Link(from: .electricChargeI, to: .electricChargeII),
            Link(from: .electricChargeII, to: .electricChargeIII),
            Link(from: .electricChargeIII, to: .beeBread),
            
            Link(from: .stripesI, to: .stripesII),
            Link(from: .stripesII, to: .stripesIII),
            Link(from: .stripesIII, to: .bioluminescence),
            
            Link(from: .stingerI, to: .stingerII),
                Link(from: .stingerI, to: .venomI),
            Link(from: .stingerII, to: .stingerIII),
            
            Link(from: .venomI, to: .venomII),
        ]
    }()
}
