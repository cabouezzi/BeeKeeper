//
//  ApiaryView.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 9/8/23.
//

import SceneKit
import SpriteKit

public class ApiaryView: SCNView {
    public private(set) lazy var apiary = GameManager.shared.apiary
    
    public let cameraNode: SCNNode
    public let overlay: ApiaryOverlay
    
    convenience init() {
        self.init(frame: .zero)
    }
    
    override init(frame frameRect: CGRect) {
        let camera = SCNCamera()
        camera.usesOrthographicProjection = false
        
        let light = SCNLight()
        light.type = .omni
        
        self.cameraNode = SCNNode()
        self.cameraNode.camera = camera
        self.cameraNode.light = light
        self.cameraNode.position.x += 0
        self.cameraNode.position.y += 8
        self.cameraNode.position.z += 15
        self.cameraNode.eulerAngles.x -= .pi / 8
        
        self.overlay = ApiaryOverlay()
        self.overlay.isUserInteractionEnabled = false
        self.overlay.isHidden = false
        
        super.init(frame: frameRect, options: nil)
        self.scene = SCNScene()
        self.overlaySKScene = overlay
        self.pointOfView = cameraNode
        self.backgroundColor = .blue
        
        let floorNode = SCNNode(geometry: Meshes.floor)
        floorNode.position.y -= 1
        let groundNode = SCNNode(geometry: Meshes.ground)
        groundNode.eulerAngles.x -= .pi / 2
        
        scene?.rootNode.addChildNode(cameraNode)
        scene?.rootNode.addChildNode(floorNode)
        scene?.rootNode.addChildNode(groundNode)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func loadNodes() {
        for structure in apiary.structures {
            let node = structure.accept(NodeService.shared)
            node.position.x = Float(structure.area.x)
            node.position.z = Float(structure.area.y)
            scene?.rootNode.addChildNode(node)
        }
    }
}
