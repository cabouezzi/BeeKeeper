//
//  Hive.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 9/8/23.
//

import SceneKit

enum HiveError: LocalizedError {
    case maxHoneycombs
}

class Hive: Container, Collector {
    private(set) var honeycombs: [Honeycomb]
    let cover: SCNNode
    
    override var containing: Resources {
        get { honeycombs.reduce(Resources(), { $0.adding($1.containing) }) }
        set {
            var new = newValue.canAfford(containing) ? newValue.subtracting(containing) : containing.subtracting(newValue)
            newValue.canAfford(containing) ? try? fill(&new) : try? remove(new)
        }
    }
    
    override var maximum: Resources {
        get { honeycombs.reduce(Resources(), { $0.adding($1.maximum) }) }
        set { /* TODO: ? */ }
    }
    
    required init() {
        self.honeycombs = []
        self.cover = SCNNode(geometry: Meshes.Structure.hiveCover)
        super.init()
        name = "Hive"
        self.area = DiscreteRect(x: 0, y: 0, width: 2, height: 2)
        self.maximumAssignedBees = 4
        
        #if !RELEASE
        cover.isHidden = true
        #endif
    }
    
    override func loadNode() {
        geometry = Meshes.Structure.hive
        cover.pivot = SCNMatrix4MakeTranslation(0, -cover.geometry!.height / 2, -cover.geometry!.depth * 0.45)
        cover.position.y = geometry!.height
        cover.position.z = -cover.geometry!.depth * 0.45
        addChildNode(cover)
    }
    
    override func onSelect() {
        let action = SCNAction.rotateTo(x: -.pi * 0.2, y: 0, z: 0, duration: 0.2)
        action.timingMode = .easeInEaseOut
        cover.runAction(action)
    }
    
    override func onUnselect() {
        let action = SCNAction.rotateTo(x: 0, y: 0, z: 0, duration: 0.2)
        action.timingMode = .easeInEaseOut
        cover.runAction(action)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init(from decoder: Decoder) throws {
        self.honeycombs = []
        self.cover = SCNNode()
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
    }
    
    override func accept<T>(_ visitor: T) -> T.ReturnType where T : ModelVisitor {
        return visitor.visitHive(self)
    }
    
    @discardableResult
    func addHoneycomb() throws -> Honeycomb {
        guard honeycombs.count < 3 else { throw HiveError.maxHoneycombs }
        let honeycomb = Honeycomb(hive: self)
        honeycombs.append(honeycomb)
        addChildNode(honeycomb)
        
        honeycomb.position.y += (honeycomb.geometry?.height ?? 0) * 0.7
        honeycomb.position.z = Float(honeycombs.count - 2) * (geometry?.depth ?? 0) / 4
        return honeycomb
    }
    
    // MARK: Collector
    func resourceTargets() -> Set<WritableKeyPath<Resources, Float>> {
        return honeycombs.reduce([], { $0.union($1.resourceTargets()) })
    }
    
    func transfer(to container: Container) throws {
        guard container !== self else { throw ContainerError.transferToSelf }
        for honeycomb in honeycombs where !honeycomb.containing.isEmpty() {
            try container.fill(&honeycomb.containing)
        }
    }
    
    override func fill(_ resources: inout Resources) throws {
        guard !containing.canAfford(maximum) else { throw ContainerError.containerFull }
        for honeycomb in honeycombs {
            guard !resources.isEmpty() else { return }
            try? honeycomb.fill(&resources)
        }
    }
    
    override func remove(_ resources: Resources) throws {
        guard containing.canAfford(resources) else { throw ContainerError.containerInsufficient }
        var remaining = resources
        for honeycomb in honeycombs {
            guard !resources.isEmpty() else { return }
            if honeycomb.containing.canAfford(remaining) {
                try! honeycomb.remove(remaining)
                return
            } else {
                remaining = remaining.subtracting(honeycomb.containing)
                try! honeycomb.remove(honeycomb.containing)
            }
        }
    }
}
