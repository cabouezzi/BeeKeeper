//
//  EvolutionView.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 1/25/24.
//

import SpriteKit

class EvolutionView: SKView {
    let evolutionScene = SKScene(fileNamed: "EvolutionScene.sks")!
    
    private var lastSceneTime: TimeInterval = 0
    
    var camera = SKCameraNode()
    var cameraVelocity: CGPoint = .zero
    
    let centerNode: SKNode
    let backStars: SKNode
    let middleStars: SKNode
    
    private(set) var icons: [SKNode]
    
    override init(frame: CGRect) {
        evolutionScene.backgroundColor = .black
        evolutionScene.camera = camera
        evolutionScene.addChild(camera)
        
        centerNode = evolutionScene.childNode(withName: "Center")!
        backStars = evolutionScene.childNode(withName: "BackStars")!
        backStars.setScale(2)
        middleStars = evolutionScene.childNode(withName: "MiddleStars")!
        middleStars.setScale(2)
        
        icons = evolutionScene.children.filter({ Gene(rawValue: $0.name ?? "") != nil })
        
        super.init(frame: frame)
        
        evolutionScene.delegate = self
        centerNode.isUserInteractionEnabled = false
        middleStars.isUserInteractionEnabled = false
        backStars.isUserInteractionEnabled = false
        
        camera.constraints = [
            SKConstraint.positionX(SKRange(lowerLimit: -1515, upperLimit: 1515)),
            SKConstraint.positionY(SKRange(lowerLimit: -1515, upperLimit: 1515))
        ]
        
        presentScene(evolutionScene)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension EvolutionView: SKSceneDelegate {
    func update(_ currentTime: TimeInterval, for scene: SKScene) {
        camera.position.x -= cameraVelocity.x * (currentTime - lastSceneTime)
        camera.position.y += cameraVelocity.y * (currentTime - lastSceneTime)
        
        cameraVelocity.x *= 0.95
        cameraVelocity.y *= 0.95
        lastSceneTime = currentTime
    }
    
    func didApplyConstraints(for scene: SKScene) {
        backStars.position.x = camera.position.x / 2
        middleStars.position.x = camera.position.x / 3
        
        backStars.position.y = camera.position.y / 2
        middleStars.position.y = camera.position.y / 3
    }
}
