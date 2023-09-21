//
//  ApiaryView.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 9/8/23.
//

import SceneKit
import SpriteKit

public class ApiaryView: SCNView {
    public private(set) var apiary = Apiary()
    
    private let cameraNode = SCNNode()
    
    public var overlay: ApiaryOverlay
    
    convenience init() {
        self.init(frame: .zero)
    }
    
    override init(frame frameRect: CGRect) {
        let camera = SCNCamera()
        camera.usesOrthographicProjection = false
        
        let light = SCNLight()
        light.type = .omni
        
        self.cameraNode.camera = camera
        self.cameraNode.light = light
        self.cameraNode.position.x -= 5
        self.cameraNode.position.y += 3
        self.cameraNode.position.z -= 5
        self.cameraNode.eulerAngles.y -= .pi / 4
        
        self.overlay = ApiaryOverlay()
        self.overlay.isUserInteractionEnabled = false
        self.overlay.isHidden = false
        
        super.init(frame: frameRect, options: nil)
        self.scene = SCNScene()
        self.overlaySKScene = overlay
        self.pointOfView = cameraNode
        self.backgroundColor = .blue
        
        let floorNode = SCNNode(geometry: Meshes.floor)
        floorNode.position.y -= 5
        let groundNode = SCNNode(geometry: Meshes.ground)
        groundNode.eulerAngles.x += .pi / 2
        groundNode.position.y -= 4
        
        scene?.rootNode.addChildNode(cameraNode)
        scene?.rootNode.addChildNode(floorNode)
        scene?.rootNode.addChildNode(groundNode)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
