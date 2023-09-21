//
//  Flower.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 9/8/23.
//

import Foundation

public enum FlowerGrowthState {
    case sprouting
    case seedling
    case budding
    case adult
    case dead
}

/*
open class Flower: Container, Collector {
    open var growthState: FlowerGrowthState = .seedling
    public private(set) var datePlanted: Date
    public var lifespan: TimeInterval = 0
    public var dateDies: Date { return datePlanted.advanced(by: lifespan)}
    
    public required init() {
        self.datePlanted = Date()
        super.init()
    }
    
    required public init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
    public func accept(_ producer: some Producer) throws {
        var resources = Resources()
        resources.pollen = producer.production.pollen
        try fill(&resources)
    }
}
*/
