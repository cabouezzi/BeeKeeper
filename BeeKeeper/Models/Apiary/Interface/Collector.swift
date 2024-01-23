//
//  Collector.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 9/8/23.
//

protocol Collector {
    /// The paths of the resource type which the collector should collect from a producer.
    func resourceTargets() -> Set<WritableKeyPath<Resources, Float>>
    
    /// Called whenever the producer sends a call to produce.
    func accept(_ producer: some Producer) throws
    
    /// Transfers the contents of ``Container/containing`` into the `container` up to its maximum.
    ///
    /// - throws: Rethrows the errors thrown in ``Container1/fill(_:)``.
    func transfer(to container: Container) throws
}

extension Collector where Self: Structure {
    func showResourceBubble(_ onTap: (() -> Void)? = nil) {
        if let resource = resourceTargets().first {
            showBubble(texture: .fromResourcePath(resource), onTap: onTap)
        } else {
            showBubble(texture: .blank, onTap: onTap)
        }
    }
}

extension Collector where Self: Container {
    func accept(_ producer: some Producer) throws {
        var resources = Resources()
        for key in resourceTargets() {
            resources[keyPath: key] = producer.production[keyPath: key]
        }
        try fill(&resources)
    }
    
    func transfer(to container: Container) throws {
        guard container !== self else { throw ContainerError.transferToSelf }
        try container.fill(&containing)
    }
}
