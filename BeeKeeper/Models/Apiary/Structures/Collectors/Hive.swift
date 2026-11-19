//
//  Hive.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 9/8/23.
//

import SceneKit

enum HoneycombConstructionState {
    /// No construction in progress
    case idle
    /// A honeycomb is currently being built
    case building
    /// The current honeycomb build time has elapsed
    case finished
}

enum HiveError: LocalizedError {
    case maxHoneycombs
    case notStarted
    case notFinished
    case alreadyBuilding

    var errorDescription: String? {
        switch self {
        case .maxHoneycombs:
            return "You’ve reached the maximum number of honeycombs."
        case .notStarted:
            return "No honeycomb construction is in progress."
        case .notFinished:
            return "Honeycomb construction is not finished yet."
        case .alreadyBuilding:
            return "A honeycomb is already under construction."
        }
    }
}

class Hive: Container, Collector {
    private(set) var honeycombs: [Honeycomb] {
        didSet {
            bindHoneycombs()
            onChange?()
        }
    }
    private(set) var currentConstruction: TimedReward<Honeycomb>? {
        didSet {
            oldValue?.onChange = nil
            bindConstruction()
            onChange?()
        }
    }

    override var onChange: (() -> Void)? {
        didSet {
            bindHoneycombs()
            bindConstruction()
        }
    }

    private func bindHoneycombs() {
        for honeycomb in honeycombs {
            honeycomb.onChange = { [weak self] in self?.onChange?() }
        }
    }

    private func bindConstruction() {
        currentConstruction?.onChange = { [weak self] in self?.onChange?() }
        currentConstruction?.reward.onChange = { [weak self] in self?.onChange?() }
    }

    /// Tracks where we are in the honeycomb build process
    var constructionState: HoneycombConstructionState {
        guard let endDate = currentConstruction?.endDate else { return .idle }
        return Date.now >= endDate ? .finished : .building
    }

    let cover: SCNNode = SCNNode(geometry: Meshes.Structure.hiveCover)
    
    override var containing: Resources {
        get { honeycombs.reduce(Resources(), { $0.adding($1.containing) }) }
        set {
            var delta = newValue.canAfford(containing)
                ? newValue.subtracting(containing)
                : containing.subtracting(newValue)
            do {
                if newValue.canAfford(containing) {
                    try fill(&delta)
                } else {
                    try remove(delta)
                }
            } catch {
                // handle or log error
            }
        }
    }
    
    override var maximum: Resources {
        get { honeycombs.reduce(Resources(), { $0.adding($1.maximum) }) }
        set { /* TODO: handle dynamic maximum if needed */ }
    }
    
    required init() {
        self.honeycombs = []
        super.init()
        self.area = DiscreteRect(x: 0, y: 0, width: 2, height: 2)
        self.maximumAssignedBees = 1
    }
    
    override func loadNode() {
        name = "Hive"
        details = "A structured home for bees. Allows bees to produce and store honey in honeycombs."
        geometry = Meshes.Structure.hive
        cover.pivot = SCNMatrix4MakeTranslation(0, -cover.geometry!.height / 2, -cover.geometry!.depth * 0.45)
        cover.position.y = geometry!.height
        cover.position.z = -cover.geometry!.depth * 0.45
        addChildNode(cover)
        
        for (index, honeycomb) in honeycombs.enumerated() {
            honeycomb.position.y = (honeycomb.geometry?.height ?? 0) * 0.7
            honeycomb.position.z = Float(index - 1) * (geometry?.depth ?? 0) / 4
            addChildNode(honeycomb)
        }

        #if !RELEASE
        cover.isHidden = true
        #endif
    }
    
    override func onSelect() {
        let action = SCNAction.rotateTo(x: -.pi * 0.2, y: 0, z: 0, duration: 0.2)
        action.timingMode = .easeInEaseOut
        cover.runAction(action)
    }
    
    override func onUnselect() {
        let action = SCNAction.rotateTo(x: 0, y: 0, z: 0, duration: 0.2)
        action.timingMode = .easeInEaseOut
        cover.runAction(action)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private enum CodingKeys: CodingKey {
        case honeycombs
        case currentConstruction
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        honeycombs = try container.decode([Honeycomb].self, forKey: .honeycombs)
        currentConstruction = try container.decodeIfPresent(TimedReward<Honeycomb>.self, forKey: .currentConstruction)
        try super.init(from: decoder)
        honeycombs.forEach({ $0.hive = self })
        
        if let construction = currentConstruction {
            construction.reward.hive = self
        }
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(honeycombs, forKey: .honeycombs)
        try container.encodeIfPresent(currentConstruction, forKey: .currentConstruction)
        try super.encode(to: encoder)
    }
    
    override func accept<T>(_ visitor: T) -> T.ReturnType where T : ModelVisitor {
        return visitor.visitHive(self)
    }

    // MARK: - Timed Construction
    
    /// Begins building a new honeycomb over time
    func startHoneycombConstruction() throws {
        guard honeycombs.count < 3 else { throw HiveError.maxHoneycombs }
        guard constructionState == .idle else { throw HiveError.alreadyBuilding }
        
        let cost = GameManager.shared.getHoneycombBuildCost(self)
        let duration = GameManager.shared.getHoneycombBuildTime(self)
        try GameManager.shared.remove(cost)
        
        // Prepare a fresh honeycomb reward
        let honeycomb = Honeycomb(hive: self)
        currentConstruction = TimedReward(duration: duration, reward: honeycomb)
    }
    
    /// Completes the build (if finished), adds the new honeycomb to the hive
    @discardableResult
    func claimHoneycombConstruction() throws -> Honeycomb {
        guard let construction = currentConstruction else { throw HiveError.notStarted }
        guard constructionState == .finished else { throw HiveError.notFinished }
        
        let honeycomb = construction.reward
        maximumAssignedBees += 1
        honeycombs.append(honeycomb)
        addChildNode(honeycomb)
        
        honeycomb.position.y = (honeycomb.geometry?.height ?? 0) * 0.7
        honeycomb.position.z = Float(honeycombs.count - 2) * (geometry?.depth ?? 0) / 4
        
        currentConstruction = nil
        return honeycomb
    }
    
    /// Developer shortcut to instantly finish (non-RELEASE only)
    func forceCompleteConstruction() throws {
        #if !RELEASE
        guard let period = currentConstruction else { throw HiveError.notStarted }
        period.forceComplete()
        #endif
    }
    
    // MARK: - Collector
    
    func resourceTargets() -> Set<WritableKeyPath<Resources, Float>> {
        return honeycombs.reduce(into: []) { set, comb in
            set.formUnion(comb.resourceTargets())
        }
    }
    
    func transfer(to container: Container) throws {
        guard container !== self else { throw ContainerError.transferToSelf }
        for honeycomb in honeycombs where !honeycomb.containing.isEmpty() {
            try container.fill(&honeycomb.containing)
        }
    }
    
    override func fill(_ resources: inout Resources) throws {
        guard !containing.canAfford(maximum) else { throw ContainerError.containerFull }
        for honeycomb in honeycombs {
            guard !resources.isEmpty() else { return }
            try? honeycomb.fill(&resources)
        }
        if !resources.isEmpty() {
            throw ContainerError.containerFull
        }
    }
    
    override func remove(_ resources: Resources) throws {
        guard containing.canAfford(resources) else { throw ContainerError.containerInsufficient }
        var remaining = resources
        for honeycomb in honeycombs {
            guard !remaining.isEmpty() else { return }
            if honeycomb.containing.canAfford(remaining) {
                try honeycomb.remove(remaining)
                return
            } else {
                let extract = honeycomb.containing
                remaining = remaining.subtracting(extract)
                try honeycomb.remove(extract)
            }
        }
    }
}
