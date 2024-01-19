//
//  Incubator.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 9/8/23.
//

import Foundation

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
        self.name = "Incubator"
        self.area = DiscreteRect(x: 0, y: 0, width: 1, height: 1)
    }
    
    override func loadNode() {
        self.geometry = Meshes.Structure.incubator
        self.eulerAngles.y = -.pi / 2
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
    }
    
    override func accept<T>(_ visitor: T) -> T.ReturnType where T : ModelVisitor {
        visitor.visitIncubator(self)
    }
    
    func startIncubating(_ period: TimeInterval) throws {
        currentPeriod = IncubationPeriod(started: Date(), incubationPeriod: period, bee: Bee(GameManager.shared.account.unlockedGenes))
    }
    
    func hatch() throws {
        guard let currentPeriod = currentPeriod else { throw IncubatorError.notStarted } // TODO: throw error
        guard state == .finished else { throw IncubatorError.notFinished } // TODO: throw error
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
