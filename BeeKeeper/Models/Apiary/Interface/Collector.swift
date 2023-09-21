//
//  Collector.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 9/8/23.
//

/// An interface for objects acting as a resource collector.
public protocol Collector {
    /// Called whenever the producer sends a call to produce.
    func accept(_ producer: some Producer) throws
    
    /// Fills the container with the amount, limited by the ``maximum``. Returns the excess resources.
    ///
    /// - throws: ``ContainerError``
    func fill(_ resources: Resources) throws -> Resources
    
    /// Empties the collector and returns resources that were collected over time.
    func collect() -> Resources
}
