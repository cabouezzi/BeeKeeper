//
//  GameManager.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 9/10/23.
//

import SceneKit

protocol GameObserver: AnyObject {
    func gameManager(_ account: Account, _ apiary: Apiary, didHatchBee bee: Bee)
    func gameManager(_ account: Account, _ apiary: Apiary, didUpdateResources resources: Resources)
    func gameManager(_ account: Account, _ apiary: Apiary, didReleaseBees bees: [Bee])
}

/// Global functionality that represents the user's capabilities and control over the game.
final class GameManager: NSObject {
    static let shared = GameManager()
    
    private(set) var account: Account
    private(set) var apiary: Apiary
    
    private let gameTicker = GameTicker()
    
    private override init() {
        account = Account()
        apiary = account.apiaries.first!
        super.init()
        gameTicker.setHandler { [weak self] timer in
            self?.onTick(timer.timeInterval)
        }
        gameTicker.start()
    }
    
    private func onTick(_ seconds: TimeInterval) {
        apiary.tickWildBees(seconds)
        
        // TODO: Make formula instead of loop
        
        for _ in 0..<Int(seconds) {
            for structure in apiary.structures {
                if let collector = structure as? (Container & Collector), let resource = collector.resourceTargets().first {
                    if collector.containing[keyPath: resource] > collector.maximum[keyPath: resource] * 0.8 {
                        collector.showResourceBubble {
                            self.collect(from: collector)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Observer Control
    // TODO: Replace with reactive code
    
    private var observers: [() -> (any GameObserver)?] = []
    
    func addObserver(_ observer: any GameObserver) {
        guard !observers.contains(where: { $0() === observer }) else { return }
        observers.append { [weak observer] in
            return observer
        }
    }
    
    func removeObserver(_ observer: any GameObserver) {
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
    
    func changeAccount(to account: Account) throws {
        // Tear down here
        gameTicker.stop()
        self.account = account
        guard let apiary = account.apiaries.first else { fatalError("Account doesn't have an apiary") }
        changeApiary(apiary)
        gameTicker.start()
    }
    
    func unlockGene(_ gene: Gene) {
        account.unlockedGenes.insert(gene)
    }
    
    // MARK: - Apiary-Dependent
    
    func changeApiary(_ apiary: Apiary) {
        // Save last online data
        self.apiary.lastOnline = .now
        
        // Simulate time passing for the new apiary
        let timePassed = Date().timeIntervalSince(apiary.lastOnline)
        for bee in apiary.bees {
            guard let collector = bee.producerAssignment as? (Collector & Container) else { return }
            var production = bee.production.multiplying(Float(timePassed)).multiplying(0.7)
            try? collector.fill(&production)
        }
        
        // Set new apiary
        self.apiary = apiary
    }
    
    /// Calculates the resources contained in all containers.
    func getAllResources() -> Resources {
        let total = apiary.structures
            .compactMap({ $0 is Collector ? nil : $0 as? Container })
            .reduce(Resources(), { $0.adding($1.containing) })
        return total
    }
    
    /// Calculates the maximum resources that all containers can collectively hold.
    func getMaximumResources() -> Resources {
        let total = apiary.structures
            .compactMap({ $0 is Collector ? nil : $0 as? Container })
            .reduce(Resources(), { $0.adding($1.maximum) })
        return total
    }
    
    /// Removes resources from the apiary. Should be mainly called from the shop.
    ///
    /// - throws: ``ContainerError``
    func remove(_ cost: Resources) throws {
        guard getAllResources().canAfford(cost) else { throw ContainerError.containerInsufficient }
        var resources = cost
        for structure in apiary.structures {
            guard let storage = structure as? Container, !(storage is Collector) else { continue }
            if storage.containing.canAfford(resources) {
                // Single storage covers the cost
                try! storage.remove(resources)
                notifyObservers({ $0.gameManager(account, apiary, didUpdateResources: getAllResources()) })
                return
            } else {
                // Remove as much contents as can
                resources = resources.subtracting(storage.containing)
                try! storage.remove(storage.containing)
            }
        }
        
        notifyObservers({ $0.gameManager(account, apiary, didUpdateResources: getAllResources()) })
    }
    
    /// Transfers resources from a ``Collector`` and stores them into an available storage .
    func collect(from collector: some Collector) {
        for storage in apiary.structures.compactMap({ $0 is Collector ? nil : $0 as? Container }) {
            do {
                try collector.transfer(to: storage)
            } catch {
                ErrorReporter.show(error)
            }
        }
        notifyObservers({ $0.gameManager(account, apiary, didUpdateResources: getAllResources()) })
    }
    
    /// Adds a new bee to the apiary.
    ///
    /// - throws: ``ApiaryError``
    func hatchBee(_ bee: Bee) throws {
        try apiary.addBee(bee)
        
        notifyObservers({ $0.gameManager(account, apiary, didHatchBee: bee) })
    }
    
    func releaseBees() {
        do {
            let bees = try apiary.releaseAllBees()
            notifyObservers({ $0.gameManager(account, apiary, didReleaseBees: bees) })
        } catch {
            ErrorReporter.show(error)
        }
    }
    
    /// Adds a new structure to the apiary.
    ///
    /// - throws: ``ApiaryError``
    func addStructure<T: Structure>(_ structure: T) throws {
        try apiary.addStructure(structure)
    }
    
    /// Returns the cost for incubating a new bee. Dependent on number of bees, and therefore on apiary.
    func getIncubationCost() -> Resources {
        // Free for tutorial
        if SettingsManager.shared.isFirstLogin {
            return Resources()
        }
        
        let beeIndex = apiary.bees.count
        
        switch beeIndex {
        case 0, 1:
            return Resources()
            
        case 2...8:
            let pollen = Float(100 * Int(pow(1.5, Double(beeIndex - 2))))
            let honey = beeIndex >= 5 ? Float(100 * (beeIndex - 4)) : 0
            if honey > 0 {
                return Resources(honey: honey, pollen: pollen)
            } else {
                return Resources(pollen: pollen)
            }
            
        case 9:
            return Resources(honey: 1000, pollen: 1500, beeBread: 1)
            
        case 10:
            return Resources(honey: 1200, pollen: 2000, beeBread: 2)
            
        case 11:
            return Resources(honey: 1500, pollen: 3000, beeBread: 3)
            
        default:
            return Resources(money: .infinity, honey: .infinity, pollen: .infinity, beeBread: .infinity)
        }
    }
    
    /// Returns the time for incubating a new bee. Dependent on number of bees, and therefore on apiary.
    func getIncubationTime() -> TimeInterval {
        return 15 * pow(Double(account.unlockedGenes.count) + 1, TimeInterval(apiary.bees.count))
    }
    
    
    func getHoneycombBuildCost(_ hive: Hive) -> Resources {
        if SettingsManager.shared.isFirstLogin && hive.honeycombs.isEmpty {
            return Resources()
        }
        
        var cost = Resources(honey: 750).multiplying(Float(hive.honeycombs.count + 1))
        
        for bee in hive.assignedBees {
            if bee.genetics.contains(.engineerIII) {
                cost = cost.subtracting(Resources(honey: 75))
            } else if bee.genetics.contains(.engineerII) {
                cost = cost.subtracting(Resources(honey: 50))
            } else if bee.genetics.contains(.engineerI) {
                cost = cost.subtracting(Resources(honey: 25))
            }
        }
        
        if !cost.canAfford(Resources()) {
            cost = Resources()
        }
        return cost
    }
    
    func getHoneycombBuildTime(_ hive: Hive) -> TimeInterval {
        if SettingsManager.shared.isFirstLogin && hive.honeycombs.isEmpty {
            return 5
        }
        
        // Percentage
        var factor: TimeInterval = 1.0
        
        for bee in hive.assignedBees {
            if bee.genetics.contains(.engineerIII) {
                factor -= 0.05
            } else if bee.genetics.contains(.engineerII) {
                factor -= 0.025
            } else if bee.genetics.contains(.engineerI) {
                factor -= 0.01
            }
        }
        
        let time = TimeInterval(hours: 1) * pow(5, TimeInterval(hive.honeycombs.count)) * factor
        return time
    }
}
