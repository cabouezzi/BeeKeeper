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
    
    private let cameraAnchor: SCNNode
    public let cameraNode: SCNNode
    public let overlay: ApiaryOverlay
    
    convenience init() {
        self.init(frame: .zero)
    }
    
    override init(frame frameRect: CGRect) {
        let camera = SCNCamera()
        camera.usesOrthographicProjection = false
        
        self.cameraAnchor = SCNNode()
        
        self.cameraNode = SCNNode()
        self.cameraNode.camera = camera
        self.cameraNode.position.x += 0
        self.cameraNode.position.y += 15
        self.cameraNode.position.z += 15
        self.cameraNode.eulerAngles.x -= .pi / 5
        
        self.cameraAnchor.eulerAngles.y -= .pi / 4
        self.cameraAnchor.addChildNode(cameraNode)
        
        self.overlay = ApiaryOverlay(size: frameRect.size)
        self.overlay.isUserInteractionEnabled = false
        self.overlay.isHidden = false
        
        super.init(frame: frameRect, options: nil)
        self.scene = SCNScene(named: "ModelBase.scn")
        self.scene?.background.contents = UIColor(red: 0.5, green: 0.9, blue: 1, alpha: 1)
        self.overlaySKScene = overlay
        self.pointOfView = cameraNode
        self.backgroundColor = .blue
        
        let floorNode = SCNNode(geometry: Meshes.floor)
        floorNode.position.y -= 1
        let groundNode = SCNNode(geometry: Meshes.ground)
        groundNode.eulerAngles.x -= .pi / 2
        
        scene?.rootNode.addChildNode(cameraAnchor)
        
        GameManager.shared.addObserver(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        GameManager.shared.removeObserver(self)
    }
    
    func loadNodes() {
        for bee in apiary.bees {
            let node = bee.accept(NodeService.shared)
            node.position.y += 3
            scene?.rootNode.addChildNode(node)
        }
        
        for structure in apiary.structures {
            let node = structure.accept(NodeService.shared)
            node.position.x = Float(structure.area.x)
            node.position.z = Float(structure.area.y)
            scene?.rootNode.addChildNode(node)
        }
    }
}

extension ApiaryView: GameObserver {
    func gameManager(_ account: Account, _ apiary: Apiary, didHatchBee bee: Bee) {
        let node = bee.accept(NodeService.shared)
        node.position.y += 3
        node.position.x = Float.random(in: -10...10)
        scene?.rootNode.addChildNode(node)
    }
    
    func gameManager(_ account: Account, _ apiary: Apiary, didUpdateResources resources: Resources) {
        overlay.resources.update(resources)
    }
}
