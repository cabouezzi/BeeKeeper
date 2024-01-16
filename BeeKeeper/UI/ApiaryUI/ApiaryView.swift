//
//  ApiaryView.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 9/8/23.
//

import SceneKit
import SpriteKit

class ApiaryView: SCNView {
    var apiary: Apiary { GameManager.shared.apiary }
    
    private let cameraAnchor: SCNNode
    let cameraNode: SCNNode
    let overlay: ApiaryOverlay
    
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
        self.cameraNode.eulerAngles.x -= .pi / 4
        
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
        self.isPlaying = true
        #if TEST
        self.showsStatistics = true
        #endif
        
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // FIXME: Make overlay aware of safe area
        // let safeAreaSize = self.safeAreaLayoutGuide.layoutFrame.size
    }
    
    func loadNodes() {
        for bee in apiary.bees {
            bee.position.y += 3
            scene?.rootNode.addChildNode(bee)
        }
        
        for structure in apiary.structures {
            structure.position.x = Float(structure.area.x)
            structure.position.z = Float(structure.area.y)
            scene?.rootNode.addChildNode(structure)
        }
    }
    
    func showBubble(node: SCNNode) {
        let bubble = Bubble()
        scene?.rootNode.addChildNode(bubble)
        bubble.position = node.position
        bubble.position.x += (node.geometry?.width ?? 0) / 2
        bubble.position.z += (node.geometry?.depth ?? 0) / 2
        bubble.position.y += (node.geometry?.height ?? 0) + 1
        bubble.onTap {
            print("Bubble burst!")
        }
    }
}

extension ApiaryView: GameObserver {
    func gameManager(_ account: Account, _ apiary: Apiary, didHatchBee bee: Bee) {
        bee.position.y = 3
        bee.position.x = Float.random(in: -5...5)
        scene?.rootNode.addChildNode(bee)
    }
    
    func gameManager(_ account: Account, _ apiary: Apiary, didUpdateResources resources: Resources) {
        overlay.resources.update(resources)
    }
}

extension ApiaryView: SCNNodeRendererDelegate {
    func renderNode(_ node: SCNNode, renderer: SCNRenderer, arguments: [String : Any]) {
        node.look(at: cameraNode.position)
    }
}
