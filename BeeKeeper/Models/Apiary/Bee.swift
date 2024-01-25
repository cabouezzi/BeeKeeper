//
//  Bee.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 9/8/23.
//

import SceneKit

class Bee: SCNNode, Model, Producer, Codable {
    private enum AnimationState: CaseIterable {
        /// The state of idle flying
        case droning
        /// The state of flying to its target
        case targeting
        /// The animation played when at its target
        case working
    }
    private var animationState: AnimationState = .droning
    
    // Producer
    var production: Resources = Resources(honey: 0.5, pollen: 0.5, beeBread: 1)
    var producerAssignment: Structure?
    
    // Stats
    private(set) var nickname: String
    var genetics: Set<Gene>
    var hunger: Float = 100
    var consumption = Resources(honey: 0, pollen: 0.1)
    var bodyTemperature: Float = 70
    var intimidation: Float = 5
    var stingerDamage: Float = 5
    var venomDamage: Float = 20
    
    // Body parts
    private var bodyArmature: SCNNode?
    private var wingArmature: SCNNode?
    private var head: SCNNode?
    private var torso: SCNNode?
    private var stinger: SCNNode?
    private var abdomen: SCNNode?
    
    // Droning
    private var velocity: SCNVector3 = SCNVector3(x: Float.random(in: -1...1), y: Float.random(in: -1...1), z: Float.random(in: -1...1)).normalized()
    private var minSpeed: Float = 0
    private var maxSpeed: Float = 4
    private var maxSteerForce: Float = 3
    private var avoidanceDistance: Float = 1
    private var attraction: SCNNode? // TODO: Replace with targets from Structure class
    private var attractionPerception: Float = 4
    
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
        super.init()
        
        loadArmature()
        loadGeneticEffects()
        
        animationLoop()
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
        node.addChildren(bodyArmature)
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
        func setBodyColor(_ color: UIColor) {
            head?.geometry?.material(named: "body")?.diffuse.contents = color
            torso?.geometry?.material(named: "body")?.diffuse.contents = color
            abdomen?.geometry?.material(named: "body")?.diffuse.contents = color
            stinger?.geometry?.material(named: "body")?.diffuse.contents = color
        }
        func setStripeColor(_ color: UIColor) {
            head?.geometry?.material(named: "stripes")?.diffuse.contents = color
            torso?.geometry?.material(named: "stripes")?.diffuse.contents = color
            abdomen?.geometry?.material(named: "stripes")?.diffuse.contents = color
            stinger?.geometry?.material(named: "stripes")?.diffuse.contents = color
        }
        
        if genetics.contains(.furII) {
            torso?.geometry = Meshes.Bee.Torso.bumble
            abdomen?.geometry = Meshes.Bee.Abdomen.bumble
        } else if genetics.contains(.furI) {
            setStripeColor(.gray)
        }
        
        let bodyMaterial = torso?.geometry?.material(named: "body")
        
        if genetics.contains(.stripesIII) {
            bodyMaterial?.diffuse.contents = UIColor(red: 0, green: 0.5, blue: 0, alpha: 1)
            bodyMaterial?.metalness.intensity = 1
            bodyMaterial?.roughness.intensity = 0
            bodyMaterial?.reflective.contents = UIColor.black
            bodyMaterial?.reflective.intensity = 1
            bodyMaterial?.lightingModel = .physicallyBased
        }
        if genetics.contains(.stripesII) {
            setStripeColor(.yellow)
        } else if genetics.contains(.stripesI) {
            setStripeColor(.orange)
        }
        
        if genetics.contains(.stingerIII) {
            stinger?.geometry = Meshes.Bee.Stinger.long
        } else if genetics.contains(.stingerII) {
            stinger?.geometry = Meshes.Bee.Stinger.medium
        } else if genetics.contains(.stingerI) {
            stinger?.geometry = Meshes.Bee.Stinger.plain
        }
    }
    
    func accept<T>(_ visitor: T) -> T.ReturnType where T : ModelVisitor {
        return visitor.visitBee(self)
    }
    
    // MARK: Animations
    
    private func animationLoop() {
        let animationPlayer: SCNAnimationPlayer
        let nextState: AnimationState
        
        switch animationState {
        case .droning:
            animationPlayer = flapWings(repeatCount: .random(in: 60...120))
            if let producerAssignment = producerAssignment {
                if let flower = producerAssignment as? Flower {
                    attraction = flower.pollinationNode()
                } else {
                    attraction = SCNNode()
                    attraction?.worldPosition = producerAssignment.worldPosition
                    attraction?.worldPosition.y += 2
                }
                nextState = .targeting
            } else {
                nextState = .droning
            }
        case .targeting:
            if producerAssignment != nil, let attraction = attraction {
                if worldPosition.distance(to: attraction.worldPosition) < 1 {
                    animationPlayer = prepareLanding()
                    nextState = .working
                } else {
                    animationPlayer = flapWings(repeatCount: 1)
                    nextState = .targeting
                }
            } else {
                animationPlayer = flapWings(repeatCount: 1)
                nextState = .droning
            }
        case .working:
            if producerAssignment != nil {
                if Int.random(in: 1...100) > 33 {
                    animationPlayer = wiggle(repeatCount: 1)
                    animationPlayer.animation.duration = .random(in: 2...5)
                    nextState = .working
                } else {
                    animationPlayer = prepareFlight()
                    nextState = .droning
                }
            } else {
                animationPlayer = prepareFlight()
                nextState = .droning
            }
        }
        animationPlayer.animation.animationDidStop = { [weak self] x, y, z in
            self?.animationState = nextState
            self?.animationLoop()
        }
        animationPlayer.play()
    }
    
    func wiggle(repeatCount: Int = 1) -> SCNAnimationPlayer {
        guard let animationPlayer = CAAnimation.animationPlayerFromScene("BeeWiggle.scn") else {
            print("Failed to load wiggle animation")
            return SCNAnimationPlayer()
        }
        animationPlayer.animation.repeatCount = CGFloat(repeatCount)
        animationPlayer.speed *= 1.75
        bodyArmature?.addAnimationPlayer(animationPlayer, forKey: "wiggle")
        return animationPlayer
    }
    
    func flapWings(repeatCount: Int = .max) -> SCNAnimationPlayer {
        guard let animationPlayer = CAAnimation.animationPlayerFromScene("BeeWingsFlap.scn") else {
            print("Failed to load flap animation")
            return SCNAnimationPlayer()
        }
        animationPlayer.animation.repeatCount = CGFloat(repeatCount)
        animationPlayer.speed *= 4
        wingArmature?.addAnimationPlayer(animationPlayer, forKey: "flap")
        return animationPlayer
    }
    
    /// Plays the animation of transitioning to flapping wings.
    func prepareFlight() -> SCNAnimationPlayer {
        guard let animationPlayer = CAAnimation.animationPlayerFromScene("BeeWingsFold.scn") else {
            print("Failed to load fold animation")
            return SCNAnimationPlayer()
        }
        animationPlayer.animation.repeatCount = 1
        animationPlayer.speed *= 4
        wingArmature?.addAnimationPlayer(animationPlayer, forKey: "flap")
        animationPlayer.animation.isRemovedOnCompletion = false
        return animationPlayer
    }
    
    /// Plays the animation of transitioning to stationary position.
    func prepareLanding() -> SCNAnimationPlayer {
        guard let animationPlayer = CAAnimation.animationPlayerFromScene("BeeWingsFold.scn") else {
            print("Failed to load fold animation")
            return SCNAnimationPlayer()
        }
        animationPlayer.animation.repeatCount = 1
        animationPlayer.speed *= -4
        wingArmature?.addAnimationPlayer(animationPlayer, forKey: "flap")
        animationPlayer.animation.isRemovedOnCompletion = false
        return animationPlayer
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
            let collisionDistance = collision.worldCoordinates.distance(to: worldPosition)
            let steerDistance = velocity.normalized().distance(to: avoidanceDirection)
            
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
    
    private func attractionForce() -> SCNVector3 {
        guard let producerAssignment = producerAssignment, animationState == .targeting else { return .zero }
        var targetPosition = producerAssignment.worldPosition
        targetPosition.y += 2
        let dir = (targetPosition - worldPosition).normalized()
        var targetVelocity = velocity + scaledForce(dir)
        
        if let attraction = attraction, animationState == .targeting {
            let distance = attraction.worldPosition.distance(to: worldPosition)
            if distance < attractionPerception {
                targetVelocity = targetVelocity.normalized() * distance.clamped(min: 0.1, max: 1)
            }
        }
        
        return (targetVelocity - velocity)
    }
    
    private func idleForce() -> SCNVector3 {
        return velocity.normalized() * (maxSpeed * 0.67 / velocity.magnitude)
    }
    
    /// Updates the position, velocity, and acceleration of the bee at a timestep.
    func droneStep(in world: SCNPhysicsWorld) {
        guard animationState != .working else { return }
        
        var acceleration = SCNVector3.zero
        let rayTest = world.rayTestWithSegment(from: worldPosition, to: worldPosition + velocity * (maxSpeed + avoidanceDistance))
        
        // If not obstructed, accelerate forward
        if rayTest.isEmpty {
            acceleration += idleForce()
        }
        
        acceleration += avoidanceForce(world) * 5
        acceleration += attractionForce()
        
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
