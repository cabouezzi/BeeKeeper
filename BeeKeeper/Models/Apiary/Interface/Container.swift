//
//  Container.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 9/8/23.
//

import Foundation

enum ContainerError: LocalizedError {
    case containerFull, containerInsufficient
    
    var errorDescription: String? { nil }
}

public protocol Container: AnyObject {
    /// The resources that the container holds.
    var containing: Resources { get }
    /// The maximum resources that the container can hold.
    var maximum: Resources { get }
    
    /// Fills the container with the amount, limited by the ``maximum``. Returns the excess resources.
    ///
    /// - throws: ``ContainerError``
    func fill(_ resources: Resources) throws -> Resources
    
    /// Removes the resources from the container, only if able to.
    ///
    /// - throws: ``ContainerError``
    func remove(_ resources: Resources) throws
}
