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
    
    var production: Resources = Resources(honey: 0.5, pollen: 0.5, beeBread: 1)
    var producerAssignment: Structure?
    
    var hunger: Float = 100
    var consumption = Resources(honey: 0, pollen: 0.1)
    var bodyTemperature: Float = 70
    var intimidation: Float = 5
    var stingerDamage: Float = 5
    var venomDamage: Float = 20
    
    private var bodyArmature: SCNNode?
    private var wingArmature: SCNNode?
    private var head: SCNNode?
    private var torso: SCNNode?
    private var stinger: SCNNode?
    private var abdomen: SCNNode?
    
    private var velocity: SCNVector3
    private var minSpeed: Float
    private var maxSpeed: Float
    private var maxSteerForce: Float
    private var avoidanceDistance: Float
    
    private static let directions: Set<SCNVector3> = {
        let count = 100
        var dirs = Set<SCNVector3>(minimumCapacity: count)
        let goldenRatio: Float = (1 + sqrt(5)) / 2
        let angleIncrement: Float = (2 * .pi) * goldenRatio
        
        for i in 0..<count {
            // Ratio for spreading
            let ratio = Float(i) / Float(count)
            
            // Angles
            let polarAngle: Float = (acos(1 - 2 * ratio)).truncatingRemainder(dividingBy: .pi)
            let azimuthalAngle: Float = (Float(angleIncrement) * Float(i)).truncatingRemainder(dividingBy: 2 * .pi)
            
            // Cartesian
            let x = sin(polarAngle) * cos(azimuthalAngle)
            let y = cos(polarAngle)
            let z = sin(polarAngle) * sin(azimuthalAngle)
            let vector = SCNVector3(x, y, z)
            
            dirs.insert(vector)
        }
        return dirs
    }()
    
    init(_ genes: Set<Gene> = []) {
        self.genetics = genes
        self.nickname = UUID().uuidString
        self.velocity = SCNVector3(x: Float.random(in: -1...1), y: Float.random(in: -1...1), z: Float.random(in: -1...1)).normalized()
        self.minSpeed = 0
        self.maxSpeed = 4
        self.maxSteerForce = 3
        self.avoidanceDistance = 1
        super.init()
        
        loadArmature()
        loadGeneticEffects()
        
        flapWings()
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
        let modelScene = SCNScene(named: "BeePlain.scn")
        guard
            let bodyArmature = modelScene?.rootNode.childNode(withName: "BodyArmature", recursively: true),
            let wingArmature = modelScene?.rootNode.childNode(withName: "WingArmature", recursively: true)
        else {
            fatalError("Failed to load bee armature")
        }
        node.addChildren([bodyArmature, wingArmature])
        node.eulerAngles.x = .pi / 2
        node.eulerAngles.y = -.pi / 2
        node.scale = SCNVector3(0.3, 0.3, 0.3)
        
        self.bodyArmature = bodyArmature
        self.wingArmature = wingArmature
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
    
    // MARK: Animations
    
    func wiggle(repeatCount: Int = 1) {
        guard let animationPlayer = CAAnimation.animationPlayerFromScene("BeeWiggle.scn") else {
            print("Failed to load wiggle animation")
            return
        }
        animationPlayer.animation.repeatCount = CGFloat(repeatCount)
        animationPlayer.speed *= 1.75
        bodyArmature?.addAnimationPlayer(animationPlayer, forKey: "wiggle")
        animationPlayer.play()
    }
    
    func flapWings(repeatCount: Int = .max) {
        guard let animationPlayer = CAAnimation.animationPlayerFromScene("BeeWingsFlap.scn") else {
            print("Failed to load flap animation")
            return
        }
        animationPlayer.animation.repeatCount = CGFloat(repeatCount)
        animationPlayer.speed *= 4
        wingArmature?.addAnimationPlayer(animationPlayer, forKey: "flap")
        animationPlayer.play()
    }
    
    // MARK: Droning
    
    /// Scales the direction of a vector into a force vector.
    private func scaledForce(_ vector: SCNVector3) -> SCNVector3 {
        return (vector.normalized() * maxSpeed) - velocity
    }
    
    private func avoidanceForce(_ world: SCNPhysicsWorld) -> SCNVector3 {
        var force = SCNVector3.zero
        // Avoid obstacles as much as possible
        let collisions = Bee.directions.compactMap({ dir in
            return world.rayTestWithSegment(from: worldPosition, to: worldPosition + dir * (maxSpeed + avoidanceDistance)).first
        })
        
        for collision in collisions {
            let avoidanceDirection = collision.worldNormal.normalized()
            let avoidanceForce = scaledForce(avoidanceDirection)
            let collisionDistance = (collision.worldCoordinates - worldPosition).magnitude
            let steerDistance = (avoidanceDirection - velocity.normalized()).magnitude
            
            // collisionDistance in [0, ∞). shorter collisionDistance -> higher priority
            // steerDistance in [0, 2]. shorter steerDistance -> less priority
            let priority = steerDistance / collisionDistance
            force += avoidanceForce * priority
        }
        
        force /= Float(Bee.directions.count)
        if force.magnitude > maxSteerForce {
            force = force.normalized() * maxSteerForce
        }
        return force
    }
    
    /// Updates the position, velocity, and acceleration of the bee at a timestep.
    func droneStep(in world: SCNPhysicsWorld) {
        var acceleration = SCNVector3.zero
        let rayTest = world.rayTestWithSegment(from: worldPosition, to: worldPosition + velocity * (maxSpeed + avoidanceDistance))
        
        // If not obstructed, accelerate forward
        if rayTest.isEmpty {
            acceleration += velocity.normalized() * (maxSpeed * 0.67 / velocity.magnitude)
        }
        
        acceleration += avoidanceForce(world) * 5
        
        if let target = producerAssignment {
            acceleration += target.worldPosition - worldPosition
        }
        
        if acceleration.magnitude > maxSteerForce {
            acceleration = acceleration.normalized() * maxSteerForce
        }
        
        velocity += acceleration * Float(world.timeStep)
        
        if velocity.magnitude < minSpeed {
            velocity = velocity.normalized() * minSpeed
        }
        if velocity.magnitude > maxSpeed {
            velocity = velocity.normalized() * maxSpeed
        }
        
        var forward = worldPosition + velocity
        forward.y = worldPosition.y
        look(at: forward)
        worldPosition += velocity * Float(world.timeStep)
    }
}
