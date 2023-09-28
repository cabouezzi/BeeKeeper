//
//  GameManager.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 9/10/23.
//

protocol GameObserver: AnyObject {
    func gameManager(_ account: Account, _ apiary: Apiary, didHatchBee bee: Bee)
    func gameManager(_ account: Account, _ apiary: Apiary, didUpdateResources resources: Resources)
}

/// Global functionality that represents the user's capabilities and control over the game.
final class GameManager {
    static let shared = GameManager()
    
    private(set) var account: Account
    private(set) var apiary: Apiary
    
    private init() {
        account = Account()
        apiary = account.apiaries.first!
    }
    
    // MARK: - Observer Control
    // TODO: Replace with reactive code
    
    private var observers: [() -> (any GameObserver)?] = []
    
    public func addObserver(_ observer: any GameObserver) {
        guard !observers.contains(where: { $0() === observer }) else { return }
        observers.append { [weak observer] in
            return observer
        }
    }
    
    public func removeObserver(_ observer: any GameObserver) {
        observers.removeAll { closure in
            guard let other = closure() else { return true }
            return observer === other
        }
    }
    
    private func notifyObservers(_ block: (any GameObserver) -> ()) {
        observers.forEach { closure in
            guard let observer = closure() else { return }
            block(observer)
        }
    }
    
    // MARK: - Account-Dependent
    
    public func unlockGene(_ gene: Gene) {
        account.unlockedGenes.insert(gene)
    }
    
    // MARK: - Apiary-Dependent
    
    public func changeApiary(_ apiary: Apiary) {
        self.apiary = apiary
    }
    
    /// Calculates the resources contained in all containers.
    public func getAllResources() -> Resources {
        let total = apiary.structures
            .compactMap({ $0 as? Container })
            .reduce(Resources(), { $0.adding($1.containing) })
        return total
    }
    
    /// Calculates the maximum resources that all containers can collectively hold.
    public func getMaximumResources() -> Resources {
        let total = apiary.structures
            .compactMap({ $0 as? Container })
            .reduce(Resources(), { $0.adding($1.maximum) })
        return total
    }
    
    /// Removes resources from the apiary. Should be mainly called from the shop.
    ///
    /// - throws: ``ContainerError``
    public func remove(_ cost: Resources) throws {
        guard getAllResources().canAfford(cost) else { throw ContainerError.containerInsufficient }
        var resources = cost
        for structure in apiary.structures {
            guard let storage = structure as? Container else { continue }
            if storage.containing.canAfford(resources) {
                // Single storage covers the cost
                try! storage.remove(resources)
                return
            } else {
                // Remove as much contents as can
                resources = resources.subtracting(storage.containing)
                try! storage.remove(storage.containing)
            }
        }
        
        notifyObservers({ $0.gameManager(account, apiary, didUpdateResources: getAllResources()) })
    }
    
    /// Transfers resources from some ``Collector`` and stores them into an available ``Container`` .
    public func collect(from collector: some Collector) {
        var resources = collector.collect()
        for structure in apiary.structures {
            guard let storage = structure as? Container else { continue }
            resources = (try? storage.fill(resources)) ?? resources
        }
        _ = try? collector.fill(resources)
        
        notifyObservers({ $0.gameManager(account, apiary, didUpdateResources: getAllResources()) })
    }
    
    /// Adds a new bee to the apiary.
    ///
    /// - throws: ``ApiaryError``
    public func hatchBee(_ bee: Bee) throws {
        try apiary.addBee(bee)
        
        notifyObservers({ $0.gameManager(account, apiary, didHatchBee: bee) })
    }
    
    /// Adds a new structure to the apiary.
    ///
    /// - throws: ``ApiaryError``
    public func addStructure<T: Structure>(_ structure: T) throws {
        try apiary.addStructure(structure)
    }
}
