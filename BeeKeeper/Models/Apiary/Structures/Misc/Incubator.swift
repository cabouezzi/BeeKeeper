//
//  Incubator.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 9/8/23.
//

import SceneKit

enum IncubatorState {
    case idle, incubating, finished
}

enum IncubatorError: LocalizedError {
    case notStarted, notFinished
    
    var errorDescription: String? {
        switch self {
        case .notStarted: return "Start incubating to hatch a new bee."
        case .notFinished: return "Incubation is not finished yet"
        }
    }
}

class Incubator: Structure {
    private(set) var currentIncubation: TimedReward<Bee>? {
        didSet {
            oldValue?.onChange = nil
            bindIncubation()
            onChange?()
        }
    }

    override var onChange: (() -> Void)? {
        didSet { bindIncubation() }
    }

    private func bindIncubation() {
        currentIncubation?.onChange = { [weak self] in self?.onChange?() }
        currentIncubation?.reward.onChange = { [weak self] in self?.onChange?() }
    }
    
    var state: IncubatorState {
        guard let endDate = currentIncubation?.endDate else { return .idle }
        
        return Date.now >= endDate ? .finished : .incubating
    }
    
    required init() {
        super.init()
        self.area = DiscreteRect(x: 0, y: 0, width: 4, height: 4)
    }
    
    override func loadNode() {
        name = "Incubator"
        geometry = Meshes.Structure.incubator
        eulerAngles.y = -.pi / 2
        self.details = "A warm chamber where young bees are raised from eggs. Used to incubate new bees using pollen."
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private enum CodingKeys: CodingKey {
        case currentPeriod
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        currentIncubation = try container.decodeIfPresent(TimedReward<Bee>.self, forKey: .currentPeriod)
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(currentIncubation, forKey: .currentPeriod)
        try super.encode(to: encoder)
    }
    
    override func accept<T>(_ visitor: T) -> T.ReturnType where T : ModelVisitor {
        visitor.visitIncubator(self)
    }
    
    func startIncubating(_ period: TimeInterval) throws {
        guard state == .idle else { throw IncubatorError.notFinished }
        let cost = GameManager.shared.getIncubationCost()
        // TODO: Throw better error
        try GameManager.shared.remove(cost)
        currentIncubation = TimedReward(duration: period, reward: Bee(GameManager.shared.account.unlockedGenes))
    }
    
    func hatch() throws {
        guard let currentPeriod = currentIncubation else { throw IncubatorError.notStarted }
        guard state == .finished else { throw IncubatorError.notFinished }
        try GameManager.shared.hatchBee(currentPeriod.reward)
        self.currentIncubation = nil
    }
    
    func forceComplete() throws {
        #if !RELEASE
        guard let period = currentIncubation else { throw IncubatorError.notStarted }
        period.forceComplete()
        #endif
    }
}
