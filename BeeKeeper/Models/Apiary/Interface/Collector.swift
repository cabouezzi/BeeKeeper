//
//  Collector.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 9/8/23.
//

protocol Collector {
    /// Called whenever the producer sends a call to produce.
    func accept(_ producer: some Producer) throws
    
    /// Transfers the contents of ``Container/containing`` into the `container` up to its maximum.
    ///
    /// - throws: Rethrows the errors thrown in ``Container1/fill(_:)``.
    func transfer(to container: Container) throws
}

extension Collector where Self: Container {
    func accept(_ producer: some Producer) throws {
        print("`Collector` subclass `\(Self.self)` doesn't implement `accept` method for producers. Calling this function will have no effect")
    }
    
    func transfer(to container: Container) throws {
        try container.fill(&containing)
    }
}
