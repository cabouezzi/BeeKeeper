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
    case emptyBeeName
    case foreignAssignment
    
    var errorDescription: String? {
        switch self {
        case .overlappingStructures:
            return "Structures cannot overlap."
        case .sameBeeName:
            return "A bee with that name already exists."
        case .noBees:
            return "You have no bees to assign."
        case .emptyBeeName:
            return "A bee's name cannot be empty."
        case .foreignAssignment:
            return "Bee and structure must be in the same apiary."
        }
    }
}

class Apiary: Codable {
    var onChange: (() -> Void)? {
        didSet { bindContents() }
    }
    let id: UUID
    var lastOnline: Date
    
    private(set) var wildBees: Float { didSet { onChange?() } }
    private(set) var wildGenePool: [Gene: Float] { didSet { onChange?() } }
    private(set) var bees: [Bee] {
        didSet {
            for old in oldValue where !bees.contains(where: { $0 === old }) {
                old.onChange = nil
                old.ownerApiary = nil
            }
            bindContents()
            onChange?()
        }
    }
    private(set) var structures: [Structure] {
        didSet {
            for old in oldValue where !structures.contains(where: { $0 === old }) {
                old.onChange = nil
                old.ownerApiary = nil
            }
            bindContents()
            onChange?()
        }
    }

    private func bindContents() {
        for bee in bees {
            bee.ownerApiary = self
            bee.onChange = { [weak self] in self?.onChange?() }
        }
        for structure in structures {
            structure.ownerApiary = self
            structure.onChange = { [weak self] in self?.onChange?() }
        }
    }
    
    init() {
        id = UUID()
        lastOnline = .now
        
        wildBees = 1000
        wildGenePool = [:]
        
        let hive = Hive()
        hive.area.x = 0
        let honeyStorage = HoneyStorage()
        honeyStorage.area.x = hive.area.width
        
        let pollenStorage = PollenStorage()
        pollenStorage.area.x = hive.area.width
        pollenStorage.area.y = honeyStorage.area.height
        
        let incubator = Incubator()
        incubator.area.y = pollenStorage.area.y + pollenStorage.area.height
        
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
        bindContents()
    }
    
    private enum CodingKeys: CodingKey {
        case id, wildBees, wildGenePool, wrappers, lastOnline
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        lastOnline = try container.decodeIfPresent(Date.self, forKey: .lastOnline) ?? .now
        wildBees = try container.decodeIfPresent(Float.self, forKey: .wildBees) ?? 1000
        wildGenePool = try container.decodeIfPresent(Dictionary<Gene, Float>.self, forKey: .wildGenePool) ?? [:]
        
        let wrappers = try container.decode(Array<Wrapper>.self, forKey: .wrappers)
        structures = wrappers.compactMap({ $0.value as? Structure })
        bees = wrappers.compactMap({ $0.value as? Bee })
        bindContents()
        
        for bee in bees {
            guard let id = bee.producerAssignmentId else { continue }
            guard let structure = structures.first(where: { $0.id == id }) else {
                throw DecodingError.dataCorruptedError(
                    forKey: .wrappers,
                    in: container,
                    debugDescription: "Bee assignment references a missing structure."
                )
            }
            do {
                try bee.assign(to: structure)
            } catch {
                throw DecodingError.dataCorruptedError(
                    forKey: .wrappers,
                    in: container,
                    debugDescription: "Bee assignment exceeds structure capacity."
                )
            }
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(lastOnline, forKey: .lastOnline)
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
        guard !bee.nickname.isEmpty else { throw ApiaryError.emptyBeeName}
        guard !bees.contains(where: { $0.nickname == bee.nickname }) else { throw ApiaryError.sameBeeName }
        if let assignedID = bee.producerAssignmentId,
           !structures.contains(where: { $0.id == assignedID }) {
            throw ApiaryError.foreignAssignment
        }
        if let assigned = bee.producerAssignment,
           !structures.contains(where: { $0 === assigned }) {
            throw ApiaryError.foreignAssignment
        }
        if let owner = bee.ownerApiary, owner !== self {
            throw ApiaryError.foreignAssignment
        }
        bees.append(bee)
    }
    
    /// Removes the bee with the name.
    @discardableResult
    func removeBee(withName name: String) -> Bee? {
        guard let index = bees.firstIndex(where: { $0.nickname == name }) else { return nil }
        let bee = bees.remove(at: index)
        try? bee.assign(to: nil)
        return bee
    }
    
    // MARK: - Structures
    
    func addStructure<T:Structure>(_ structure: T) throws {
        guard !structures.contains(where: { $0.overlaps(structure) }) else { throw ApiaryError.overlappingStructures }
        if let owner = structure.ownerApiary, owner !== self {
            throw ApiaryError.foreignAssignment
        }
        structures.append(structure)
    }
    
    /// Removes the structure with the same object id.
    func removeStructure<T:Structure>(_ structure: T) {
        guard let index = structures.firstIndex(where: { $0 === structure }) else { return }
        for bee in bees where bee.producerAssignment === structure {
            try? bee.assign(to: nil)
        }
        structures.remove(at: index)
    }
}
