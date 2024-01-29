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
    struct IncubationPeriod: Codable {
        fileprivate(set) var startTime: Date
        fileprivate(set) var finishTime: Date
        fileprivate(set) var incubatedBee: Bee
        
        var timeLeft: TimeInterval { return finishTime.distance(to: Date()) }
        
        init (started startDate: Date, incubationPeriod: TimeInterval, bee: Bee) {
            self.startTime = startDate
            self.finishTime = startTime.addingTimeInterval(incubationPeriod)
            self.incubatedBee = bee
        }
    }
    
    private(set) var currentPeriod: IncubationPeriod?
    
    var state: IncubatorState {
        let now = Date()
        switch currentPeriod?.finishTime.compare(now) {
        case .orderedAscending: return .finished
        case .orderedDescending, .orderedSame: return .incubating
        case nil: return .idle
        }
    }
    
    required init() {
        super.init()
        self.area = DiscreteRect(x: 0, y: 0, width: 4, height: 4)
    }
    
    override func loadNode() {
        name = "Incubator"
        geometry = Meshes.Structure.incubator
        eulerAngles.y = -.pi / 2
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private enum CodingKeys: CodingKey {
        case currentPeriod
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        currentPeriod = try container.decodeIfPresent(IncubationPeriod.self, forKey: .currentPeriod)
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(currentPeriod, forKey: .currentPeriod)
        try super.encode(to: encoder)
    }
    
    override func accept<T>(_ visitor: T) -> T.ReturnType where T : ModelVisitor {
        visitor.visitIncubator(self)
    }
    
    func startIncubating(_ period: TimeInterval) throws {
        currentPeriod = IncubationPeriod(started: Date(), incubationPeriod: period, bee: Bee(GameManager.shared.account.unlockedGenes))
    }
    
    func hatch() throws {
        guard let currentPeriod = currentPeriod else { throw IncubatorError.notStarted }
        guard state == .finished else { throw IncubatorError.notFinished }
        try GameManager.shared.hatchBee(currentPeriod.incubatedBee)
        self.currentPeriod = nil
    }
    
    func forceFinish() throws {
        #if !RELEASE
        if currentPeriod == nil {
            throw IncubatorError.notStarted
        }
        currentPeriod?.finishTime = .now
        #endif
    }
}
