//
//  Incubator.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 9/8/23.
//

import Foundation

public enum IncubatorState {
    case idle, incubating, finished
}

public class Incubator: Structure {
    public struct IncubationPeriod: Codable {
        private(set) var startTime: Date
        private(set) var finishTime: Date
        private(set) var incubatedBee: Bee
        
        var timeLeft: TimeInterval { return finishTime.distance(to: Date()) }
        
        init (started startDate: Date, incubationPeriod: TimeInterval, bee: Bee) {
            self.startTime = startDate
            self.finishTime = startTime.addingTimeInterval(incubationPeriod)
            self.incubatedBee = bee
        }
    }
    
    public private(set) var currentPeriod: IncubationPeriod?
    
    public var state: IncubatorState {
        let now = Date()
        switch currentPeriod?.finishTime.compare(now) {
        case .orderedAscending: return .finished
        case .orderedDescending, .orderedSame: return .incubating
        case nil: return .idle
        }
    }
    
    public required init() {
        super.init()
        self.area = DiscreteRect(x: 0, y: 0, width: 1, height: 1)
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
    override func accept<T>(_ visitor: T) -> T.ReturnType where T : ModelVisitor {
        visitor.visitIncubator(self)
    }
    
    func startIncubating(_ period: TimeInterval) throws {
        currentPeriod = IncubationPeriod(started: Date(), incubationPeriod: period, bee: Bee())
    }
    
    func hatch() throws {
        guard let currentPeriod = currentPeriod else { return } // TODO: throw error
        guard state == .finished else { return } // TODO: throw error
        try GameManager.shared.hatchBee(currentPeriod.incubatedBee)
    }
}
