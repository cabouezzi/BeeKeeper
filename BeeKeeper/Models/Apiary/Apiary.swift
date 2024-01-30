//
//  Apiary.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 9/8/23.
//

import Foundation

enum ApiaryError: LocalizedError {
    case overlappingStructures
    case sameBeeName
    case noBees
}

class Apiary: Codable {
    private(set) var wildBees: Float
    private(set) var wildGenePool: [Gene: Float]
    private(set) var bees: [Bee]
    private(set) var structures: [Structure]
    
    init() {
        wildBees = 1000
        wildGenePool = [:]
        
        let hive = Hive()
        try? hive.addHoneycomb()
        try? hive.addHoneycomb()
        try? hive.addHoneycomb()
        hive.area.x = 0
        let honeyStorage = HoneyStorage()
        honeyStorage.area.x = hive.area.width
        
        let pollenStorage = PollenStorage()
        pollenStorage.area.x = hive.area.width
        pollenStorage.area.y = honeyStorage.area.height
        
        let incubator = Incubator()
        incubator.area.y = hive.area.height + 1
        
        let flower = Daisy()
        flower.area.x -= 4
        
        let bee = Bee([.stripesI])
        try? bee.assign(to: flower)
        
        self.bees = [bee, Bee([.stripesII]), Bee([.stripesIII, .stripesII]), Bee([.stingerII]), Bee([.stingerIII]), Bee([.furII, .stingerIII, .stripesII])]
        self.structures = [
            hive,
            honeyStorage,
            pollenStorage,
            incubator,
            flower
        ]
    }
    
    private enum CodingKeys: CodingKey {
        case wildBees, wildGenePool, wrappers
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        wildBees = try container.decodeIfPresent(Float.self, forKey: .wildBees) ?? 1000
        wildGenePool = try container.decodeIfPresent(Dictionary<Gene, Float>.self, forKey: .wildGenePool) ?? [:]
        
        let wrappers = try container.decode(Array<Wrapper>.self, forKey: .wrappers)
        structures = wrappers.compactMap({ $0.value as? Structure })
        bees = wrappers.compactMap({ $0.value as? Bee })
        
        for bee in bees {
            guard let id = bee.producerAssignmentId else { continue }
            guard let structure = structures.first(where: { $0.id == id }) else { fatalError("Bee holds id to structure that doesn't exist") }
            try? bee.assign(to: structure)
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(wildBees, forKey: .wildBees)
        try container.encode(wildGenePool, forKey: .wildGenePool)
        
        let wrappers = structures.map({ Wrapper($0) }) + bees.map({ Wrapper($0) })
        try container.encode(wrappers, forKey: .wrappers)
    }
    
    // MARK: - Bees
    
    /// Call to release all bees into the wild.
    @discardableResult
    func releaseAllBees() throws -> [Bee] {
        // Calculate score from bees and gees
        // TODO: Make some actual formula
        let score = bees.reduce(0, { $0 + $1.genetics.count })
        wildBees += Float(score)
        
        for bee in bees {
            for gene in bee.genetics {
                if wildGenePool.keys.contains(gene) {
                    wildGenePool[gene]! += 1
                } else {
                    wildGenePool[gene] = 1
                }
            }
        }
        
        let temp = bees
        bees.forEach({ try? $0.assign(to: nil) })
        bees.removeAll()
        return temp
    }
    
    /// Call to simulate a timestep in the wild
    func tickWildBees(_ seconds: TimeInterval) {
        // TODO: Growth rate vs death rate. (Always make negative net rate tho)
        for key in wildGenePool.keys {
            wildGenePool[key]! -= Float(seconds / TimeInterval(days: 7)) // 1 per week
        }
        
        let factor = seconds / TimeInterval(days: 1)
        wildBees -= 5 * Float(factor)
        wildBees.clamp(min: 0, max: .infinity)
    }
    
    /// Adds the bee if there doesn't already exist a bee with the same name
    func addBee(_ bee: Bee) throws {
        guard !bees.contains(where: { $0.nickname == bee.nickname }) else { throw ApiaryError.sameBeeName }
        bees.append(bee)
    }
    
    /// Removes the bee with the name.
    @discardableResult
    func removeBee(withName name: String) -> Bee? {
        for bee in bees where bee.name == name {
            return bee
        }
        return nil
    }
    
    // MARK: - Structures
    
    func addStructure<T:Structure>(_ structure: T) throws {
        guard !structures.contains(where: { $0.overlaps(structure) }) else { throw ApiaryError.overlappingStructures }
        structures.append(structure)
    }
    
    /// Removes the structure with the same object id.
    func removeStructure<T:Structure>(_ structure: T) {
        guard let index = structures.firstIndex(where: { $0 === structure }) else { return }
        structures.remove(at: index)
    }
}
