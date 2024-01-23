//
//  StructurePrototype.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 9/8/23.
//

import SceneKit

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

class Structure: BKNode, Model, Codable {
    /// A set of bees assigned to the structure.For collectors, the bees with produce resources.
    fileprivate(set) var assignedBees: Set<Bee>
    var maximumAssignedBees: Int
    
    // Encoding is done automatically
    private(set) var level: UInt
    
    /// The bounding rectangle of the structure on the apiary grid layout.
    /// In 3D space, this is the x-z plane:
    /// `width` corresponds to its size in the x plane, and `height` corresponds to its size in the y plane.
    var area: DiscreteRect
    
    private weak var bubble: Bubble?
    
    required override init() {
        self.assignedBees = []
        self.maximumAssignedBees = 0
        self.level = 1
        self.area = DiscreteRect(x: 0, y: 0, width: 0, height: 0)
        super.init()
        self.name = "Structure"
        loadNode()
        movePivotToCorner()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init(from decoder: Decoder) throws {
        fatalError()
        /*
        loadNode()
        movePivotToCorner()
        */
    }
    
    func encode(to encoder: Encoder) throws {
        fatalError()
    }
    
    private func movePivotToCorner() {
        pivot = SCNMatrix4MakeTranslation(
            -(geometry?.width ?? 0) / 2,
            0,
            -(geometry?.depth ?? 0) / 2
        )
    }
    
    open func loadNode() {}
    
    open func onSelect() {}
    
    open func onUnselect() {}
    
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
    
    final func showBubble(texture: Bubble.BubbleTexture, onTap: (() -> Void)? = nil) {
        guard self.bubble == nil else { return } // bubble already in use
        let bubble = Bubble(texture)
        addChildNode(bubble)
        bubble.position.y += (geometry?.height ?? 0) / 2
        bubble.onTap(onTap)
        self.bubble = bubble
    }
    
    final func removeBubble() {
        bubble?.removeFromParentNode()
        bubble = nil
    }
    
    func accept<T>(_ visitor: T) -> T.ReturnType where T : ModelVisitor {
        fatalError("Attempt to call `Structure.accept(visitor:)`. `Structure` should serve as a prototype and shouldn't be initialized.")
    }
}

extension Bee {
    /// Links the bee to the given structure, if the structure hasn't reached the maximum number of assigned bees.
    /// If structure is set to `nil`, the bee's assignment is cleared.
    ///
    /// - Throws: ``ContainerError/maximumAssignedBees``
    func assign(to structure: Structure?) throws {
        guard let structure = structure else {
            producerAssignment?.assignedBees.remove(self)
            producerAssignment = nil
            return
        }
        guard structure.assignedBees.count < structure.maximumAssignedBees else {
            print(structure.assignedBees)
            throw ContainerError.maximumAssignedBees }
        producerAssignment?.assignedBees.remove(self)
        structure.assignedBees.insert(self)
        producerAssignment = structure
    }
}
