//
//  Apiary.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 9/8/23.
//

import Foundation

public enum ApiaryError: LocalizedError {
    case overlappingStructures
    case sameBeeName
}

public struct Apiary {
    public private(set) var bees: [Bee]
    public private(set) var structures: [Structure]
    
    init() {
        let hive = Hive()
        let honeyStorage = HoneyStorage()
        hive.area.x = 0
        honeyStorage.area.x = hive.area.width
        
        self.bees = []
        self.structures = [
            hive,
            honeyStorage
        ]
    }
    
    // MARK: - Bees
    
    /// Adds the bee if there doesn't already exist a bee with the same name
    internal mutating func addBee(_ bee: Bee) throws {
        guard bees.contains(where: { $0.name == bee.name }) else { throw ApiaryError.sameBeeName }
        bees.append(bee)
    }
    
    /// Removes the bee with the name.
    @discardableResult
    internal mutating func removeBee(withName name: String) -> Bee? {
        for bee in bees where bee.name == name {
            return bee
        }
        return nil
    }
    
    // MARK: - Structures
    
    internal mutating func addStructure<T:Structure>(_ structure: T) throws {
        guard !structures.contains(where: { $0.overlaps(structure) }) else { throw ApiaryError.overlappingStructures }
        structures.append(structure)
    }
    
    /// Removes the structure with the same object id.
    internal mutating func removeStructure<T:Structure>(_ structure: T) {
        guard let index = structures.firstIndex(where: { $0 === structure }) else { return }
        structures.remove(at: index)
    }
}
