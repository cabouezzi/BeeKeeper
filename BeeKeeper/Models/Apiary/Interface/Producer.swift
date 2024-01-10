//
//  Producer.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 9/8/23.
//

import Foundation

protocol Producer {
    /// The production capabilities of the producer.
    var production: Resources { get set }
    /// The UUID of the producer's target. This should correspond to the ``Structure/id`` of a structure.
    var producerTarget: UUID? { get set }
}
