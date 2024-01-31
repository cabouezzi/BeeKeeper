//
//  HoneyStorage.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 9/9/23.
//

import SceneKit

final class HoneyStorage: Container {
    private var fillers: [SCNNode] = []
    
    required init() {
        super.init()
        self.maximum = Resources(honey: 200)
        self.area = DiscreteRect(x: 0, y: 0, width: 3, height: 3)
        updateFiller()
    }
    
    override func loadNode() {
        name = "Honey Storage"
        let node = SCNNode(geometry: Meshes.Structure.honeyStorage)
        node.eulerAngles.y = .pi
        addChildNode(node)
        
        guard let scene = SCNScene(named: "Container.scn") else { return }
        fillers = scene.rootNode.childNodes(passingTest: { node, _ in
            return node.name?.contains("fill") ?? false
        }).sorted(by: { $0.name! < $1.name! })
        node.addChildren(fillers)
        updateFiller()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        updateFiller()
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
    }
    
    override func accept<T>(_ visitor: T) -> T.ReturnType where T : ModelVisitor {
        visitor.visitHoneyStorage(self)
    }
    
    override func fill(_ resources: inout Resources) throws {
        try super.fill(&resources)
        updateFiller()
    }
    
    private func updateFiller() {
        var index = Float(fillers.count)
        if maximum.honey > 0 {
            index *= containing.honey / maximum.honey
        }
        for (i, filler) in fillers.enumerated() {
            filler.isHidden = i != Int(ceil(index - 1))
        }
    }
}
