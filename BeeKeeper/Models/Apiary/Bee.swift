//
//  Bee.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 9/8/23.
//

import SceneKit

class Bee: SCNNode, Model, Producer, Codable {
    private enum AnimationState: Equatable {
        /// The case of being in the hive at night
        case dormant(_ hive: Hive)
        /// The state of idle flying
        case droning
        /// The state of flying to its target
        case targeting(_ node: SCNNode)
        /// The animation played when at its target
        case working(_ node: Structure)
    }
    private var animationState: AnimationState = .droning
    
    // Producer
    var production: Resources = Resources(honey: 0.5, pollen: 0.5, beeBread: 1)
    var producerAssignment: Structure?
    var producerAssignmentId: UUID?
    
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
        let count = 25
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
    
    private enum CodingKeys: CodingKey {
        case nickname, genetics, producerAssignmentId
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        producerAssignmentId = try container.decodeIfPresent(UUID.self, forKey: .producerAssignmentId)
        nickname = try container.decode(String.self, forKey: .nickname)
        genetics = try container.decode(Set<Gene>.self, forKey: .genetics)
        super.init()
        loadArmature()
        loadGeneticEffects()
        
        animationLoop()
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(producerAssignmentId, forKey: .producerAssignmentId)
        try container.encode(nickname, forKey: .nickname)
        try container.encode(genetics, forKey: .genetics)
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
        physicsBody = SCNPhysicsBody(type: .kinematic, shape: nil)
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
    
    func setNickname(_ string: String) {
        nickname = string
    }
    
    /// Sends the bee to the hive, and will not leave until awakened with ``wake()``
    func sleep(_ hive: Hive) {
        removeAllAnimations()
        animationState = .dormant(hive)
        animationLoop()
    }
    
    /// Forces the bee out of its hive and begins droning.
    func wake() {
        removeAllAnimations()
        animationState = .droning
        animationLoop()
        isHidden = false
    }
    
    func follow(_ target: SCNNode) {
        removeAllAnimations()
        animationState = .targeting(target)
        animationLoop()
    }
    
    func drone() {
        removeAllAnimations()
        animationState = .droning
        animationLoop()
    }
    
    private func freeze() {
        velocity = SCNVector3(0.001, 0.001, 0.001)
    }
    
    // MARK: - Animations
    
    private func animationLoop() {
        let animationPlayer: SCNAnimationPlayer
        let nextState: AnimationState
        
        switch animationState {
        case .dormant(let hive):
            if worldPosition.distance(to: hive.worldPosition) <= Float(hive.area.width) {
                isHidden = true
                freeze()
                return
            }
            animationPlayer = flapWings(repeatCount: 1)
            nextState = .dormant(hive)
            
        case .droning:
            animationPlayer = flapWings(repeatCount: Int.random(in: 10...30))
            if let producerAssignment = producerAssignment {
                if let container = producerAssignment as? Container, container.isFull {
                    nextState = .droning
                } else {
                    nextState = .targeting(producerAssignment)
                }
            } else {
                nextState = .droning
            }
            if Int.random(in: 0..<10) > 2 {
                playFlyingSound()
            }
            
        case .targeting(let node):
            guard let structure = producerAssignment else {
                nextState = .targeting(node)
                animationPlayer = flapWings(repeatCount: 1)
                break
            }
            if worldPosition.distance(to: node.worldPosition) < max(avoidanceDistance + 1, node.width / 2) {
                animationPlayer = prepareLanding()
                nextState = .working(structure)
            } else if let flower = structure as? Flower {
                animationPlayer = flapWings(repeatCount: 1)
                nextState = .targeting(flower.pollinationNode())
            } else {
                animationPlayer = flapWings(repeatCount: 1)
                nextState = .targeting(structure)
            }
            
        case .working(let structure):
            if worldPosition.distance(to: structure.worldPosition) < max(avoidanceDistance + 1, structure.width / 2) {
                animationPlayer = prepareFlight()
                nextState = .droning
            } else if let container = structure as? Container, container.isFull {
                animationPlayer = prepareFlight()
                nextState = .droning
            } else if Int.random(in: 0..<100) > 10 {
                playWiggleSound()
                animationPlayer = wiggle(repeatCount: 1)
                animationPlayer.animation.duration = .random(in: 2...5)
                nextState = animationState
            } else {
                animationPlayer = prepareFlight()
                nextState = .droning
            }
            
        }
        animationPlayer.animation.animationDidStop = { [weak self] x, y, z in
            guard let self = self else { return }
            if case .working(let structure) = self.animationState {
                if let collector = structure as? Collector {
                    try? collector.accept(self)
                }
            }
            self.animationState = nextState
            self.animationLoop()
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
    
    // MARK: - Audio
    func playFlyingSound() {
        guard let source = SCNAudioSource(named: "bee-buzz-1.wav") else { return }
        source.volume = 0.2
        source.rate = 0.5
        source.isPositional = true
        source.shouldStream = false
        source.load()
        let player = SCNAudioPlayer(source: source)
        addAudioPlayer(player)
        
        player.didFinishPlayback = { [unowned player, unowned self] in
            removeAudioPlayer(player)
        }
    }
    
    func playWiggleSound() {
        guard let source = SCNAudioSource(named: "bee-buzz-2.wav") else { return }
        source.volume = 1
        source.rate = 1.25
        source.isPositional = true
        source.shouldStream = false
        source.load()
        let player = SCNAudioPlayer(source: source)
        addAudioPlayer(player)
        
        player.didFinishPlayback = { [unowned player, unowned self] in
            removeAudioPlayer(player)
        }
    }
    
    // MARK: - Droning
    
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
            // Don't avoid assignment
            if let producerAssignment = producerAssignment, producerAssignment === collision.node.firstParentModelNode() {
                continue
            }
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
        guard case .targeting(let node) = animationState else { return .zero }
        let dir = (node.worldPosition - worldPosition).normalized()
        var targetVelocity = scaledForce(dir)
        
        let distance = node.worldPosition.distance(to: worldPosition)
        if distance < attractionPerception {
            targetVelocity = targetVelocity.normalized() * distance.clamped(min: 0.1, max: 1)
        }
        return targetVelocity
    }
    
    func sleepForce() -> SCNVector3 {
        guard case .dormant(let hive) = animationState else { return .zero }
        var targetPos = hive.worldPosition
        targetPos.y += 1
        let dir = (targetPos - worldPosition).normalized()
        var targetVelocity = scaledForce(dir)
        
        let distance = hive.worldPosition.distance(to: worldPosition)
        if distance < Float(hive.area.width) {
            targetVelocity = targetVelocity.normalized() * distance.clamped(min: 0.1, max: 1)
        }
        return targetVelocity
    }
    
    private func idleForce() -> SCNVector3 {
        let dir = velocity == .zero ? worldFront : velocity.normalized()
        return dir * (maxSpeed * 0.33 / velocity.magnitude)
    }
    
    /// Updates the position, velocity, and acceleration of the bee at a timestep.
    func droneStep(in world: SCNPhysicsWorld) {
        if case .working(_) = animationState {
            return
        }
        
        var acceleration = SCNVector3.zero
        let rayTest = world.rayTestWithSegment(from: worldPosition, to: worldPosition + velocity * (maxSpeed + avoidanceDistance))
        
        // If not obstructed, accelerate forward
        if rayTest.isEmpty {
            acceleration += idleForce()
        }
        
        acceleration += avoidanceForce(world)
        acceleration += attractionForce()
        acceleration += sleepForce()
        
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
