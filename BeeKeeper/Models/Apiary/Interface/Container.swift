//
//  Container.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 9/8/23.
//

import Foundation

enum ContainerError: LocalizedError {
    case containerFull, containerInsufficient, transferToSelf, maximumAssignedBees
    
    var errorDescription: String? { nil }
}

class Container: Structure {
    @Published var containing = Resources()
    @Published var maximum: Resources = Resources()
    
    var isFull: Bool {
        return containing.canAfford(maximum)
    }
    
    required init() {
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private enum CodingKeys: CodingKey {
        case containing, maximum
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        containing = try container.decode(Resources.self, forKey: .containing)
        maximum = try container.decode(Resources.self, forKey: .maximum)
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(containing, forKey: .containing)
        try container.encode(maximum, forKey: .maximum)
        try super.encode(to: encoder)
    }
    
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
