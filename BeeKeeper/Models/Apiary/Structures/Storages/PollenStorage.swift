//
//  PollenStorage.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 9/28/23.
//

import SceneKit

final class PollenStorage: Container {
    private var jars: [SCNNode] = []
    
    required init() {
        super.init()
        self.maximum = Resources(pollen: 200)
        self.area = DiscreteRect(x: 0, y: 0, width: 3, height: 3)
        updateJars()
    }
    
    override func loadNode() {
        name = "Pollen Storage"
        self.details = "Wooden shelves stacked with jars to organize foraged pollen. Increases your maximum pollen capacity."
        let rack = SCNNode(geometry: Meshes.Structure.pollenStorage)
        rack.scale = SCNVector3(1.5, 1.5, 1.5)
        addChildNode(rack)
        
        guard let scene = SCNScene(named: "Rack.scn") else { return }
        let jars = scene.rootNode.childNodes.filter({ $0.name == "jar" })
        rack.addChildren(jars)
        self.jars = jars
        updateJars()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        updateJars()
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
    }
    
    override func accept<T>(_ visitor: T) -> T.ReturnType where T : ModelVisitor {
        visitor.visitPollenStorage(self)
    }
    
    override func fill(_ resources: inout Resources) throws {
        try super.fill(&resources)
        updateJars()
    }
    
    private func updateJars() {
        var index = Float(jars.count)
        if maximum.pollen > 0 {
            index *= containing.pollen / maximum.pollen
        }
        for (i, jar) in jars.enumerated() {
            jar.isHidden = i > Int(index)
        }
    }
}
