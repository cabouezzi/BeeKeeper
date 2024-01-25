//
//  StructureBorder.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 1/20/24.
//

import SceneKit

class StructureBorder: SCNNode {
    let structure: Structure
    private var squares: [SCNNode]
    
    init(_ structure: Structure) {
        self.structure = structure
        squares = []
        for width in 0..<structure.area.width {
            for height in 0..<structure.area.height {
                let square = SCNNode()
                square.geometry = SCNPlane(width: 0.95, height: 0.95)
                square.geometry?.materials[0] = SCNMaterial()
                square.geometry?.firstMaterial?.readsFromDepthBuffer = false
                square.geometry?.firstMaterial?.writesToDepthBuffer = false
                square.eulerAngles.x = -.pi / 2
                square.pivot = SCNMatrix4MakeTranslation(-0.5, 0.5, 0)
                square.position.x = -Float(structure.area.width) / 2 + Float(width)
                square.position.y = 0.1
                square.position.z = -Float(structure.area.height) / 2 + Float(height)
                squares.append(square)
            }
        }
        super.init()
        setColor(.white)
        addChildren(squares)
        structure.addChildNode(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setColor(_ color: UIColor) {
        squares.forEach({ $0.geometry?.firstMaterial?.diffuse.contents = color })
    }
}
