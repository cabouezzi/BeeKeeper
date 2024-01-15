//
//  Bee.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 9/8/23.
//

import SceneKit

class Bee: SCNNode, Model, Producer, Codable {
    private(set) var nickname: String
    
    var genetics: Set<Gene>
    
    var production: Resources
    var producerAssignment: Structure?
    
    var honeyConsumption: Float = 0.01
    var bodyTemperature: Float = 70
    var intimidation: Float = 5
    var stingerDamage: Float = 5
    var venomDamage: Float = 20
    
    private var armature: SCNNode?
    private var head: SCNNode?
    private var torso: SCNNode?
    private var stinger: SCNNode?
    private var abdomen: SCNNode?
    
    override init() {
        self.genetics = GameManager.shared.account.unlockedGenes
        self.production = Resources(honey: 0.5, pollen: 0.25, beeBread: 1)
        self.nickname = UUID().uuidString
        super.init()
        
        loadArmature()
        loadGeneticEffects()
        
        #if DEBUG
        let animationPlayer = CAAnimation.animationPlayerFromScene("BeeWiggle.scn")!
        animationPlayer.animation.repeatCount = 5
        armature?.addAnimationPlayer(animationPlayer, forKey: "wiggle")
        animationPlayer.play()
        #endif
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init(from decoder: Decoder) throws {
        fatalError()
    }
    
    func encode(to encoder: Encoder) throws {
        fatalError()
    }
    
    func loadArmature() {
        let node = SCNNode()
        let bodyScene = SCNScene(named: "BeePlain.scn")
        guard let armature = bodyScene?.rootNode.childNode(withName: "BodyArmature", recursively: true) else {
            fatalError("Failed to load bee armature")
        }
        node.addChildNode(armature)
        node.eulerAngles.x = .pi / 2
        node.scale = SCNVector3(0.3, 0.3, 0.3)
        
        self.armature = armature
        head = node.childNode(withName: "Head", recursively: true)
        torso = node.childNode(withName: "Torso", recursively: true)
        stinger = node.childNode(withName: "Stinger", recursively: true)
        abdomen = node.childNode(withName: "Abdomen", recursively: true)
        
        addChildNode(node)
    }
    
    func loadGeneticEffects() {
        if genetics.contains(.stripesI) {
            torso?.geometry = Meshes.Bee.Torso.yellowStripes
            abdomen?.geometry = Meshes.Bee.Abdomen.yellowStripes
        }
    }
    
    func accept<T>(_ visitor: T) -> T.ReturnType where T : ModelVisitor {
        return visitor.visitBee(self)
    }
}
