//
//  Container.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 9/8/23.
//

import Foundation

enum ContainerError: LocalizedError {
    case containerFull, containerInsufficient, transferToSelf
    
    var errorDescription: String? { nil }
}

class Container: Structure {
    var containing = Resources()
    var maximum: Resources = Resources()
    
    /// Fills the container with the amount, limited by the ``maximum``. Returns the excess resources.
    ///
    /// - throws: ``ContainerError``
    func fill(_ resources: inout Resources) throws {
        guard !containing.canAfford(maximum) else { throw ContainerError.containerFull }
        containing.fill(&resources, cap: maximum)
    }
    
    /// Removes the resources from the container, only if able to.
    ///
    /// - throws: ``ContainerError``
    func remove(_ resources: Resources) throws {
        guard containing.canAfford(resources) else { throw ContainerError.containerInsufficient }
        containing = containing.subtracting(resources)
    }
}
