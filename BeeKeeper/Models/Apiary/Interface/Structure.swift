//
//  StructurePrototype.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 9/8/23.
//

import Foundation

/// A rectangle in discrete space.
///
/// The `x` axis increases from left to right.
/// The `y` axis increases from top to bottom.
struct DiscreteRect: Codable {
    var x, y, width, height: Int
    
    /// Returns whether it overlaps the given rectangle.
    func intersects(_ rect: DiscreteRect) -> Bool {
        return max(x, rect.x) < min(x+width, rect.x+rect.width) && max(y, rect.y) < min(y+height, rect.y+rect.height)
    }
}

class Structure: Model, Codable {
    open var name: String = "Structure"
    // Encoding is done automatically
    private(set) var level: UInt = 1
    /// The bounding rectangle of the structure on the apiary grid layout.
    /// In 3D space, this is the x-z plane:
    /// `width` corresponds to its size in the x plane, and `height` corresponds to its size in the y plane.
    var area = DiscreteRect(x: 0, y: 0, width: 0, height: 0)
    
    required init() {}
    
    /// Increments the ``level``.
    final func levelUp() {
        level += 1
        onLevelUp()
    }
    
    /// Implemented for subclasses to modify their properties base on their level.
    /// This is separated from ``levelUp()`` to ensure that `levelUp()` does not get overriden,
    /// as level should only incrementally.
    open func onLevelUp() {}
    
    /// Returns whether it overlaps the given structure.
    final func overlaps(_ structure: Structure) -> Bool {
        return area.intersects(structure.area)
    }
    
    func accept<T>(_ visitor: T) -> T.ReturnType where T : ModelVisitor {
        fatalError("Attempt to call `Structure.accept(visitor:)`. `Structure` should serve as a prototype and shouldn't be initialized.")
    }
}
