//
//  ApiaryViewController.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 9/8/23.
//

import UIKit
import SceneKit
import SpriteKit

fileprivate enum GameState {
    case idle
    case moving(_ structure: Structure, _ originalArea: DiscreteRect)
    case assigning(_ bee: Bee)
    case assigningWithDrag(_ bee: Bee)
    case following(_ node: SCNNode)
}

class ApiaryViewController: UIViewController {
    var apiaryView: ApiaryView!
    private var state: GameState = .idle
    
    convenience init() {
        self.init(frame: .zero)
    }
    
    init(frame: CGRect) {
        self.apiaryView = ApiaryView(frame: frame)
        super.init(nibName: nil, bundle: nil)
        self.apiaryView.delegate = self
        
        addGestureRecognizers()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        self.view = apiaryView
        apiaryView.loadNodes()
        linkOverlay()
        apiaryView.scene?.rootNode.childNode(withName: "Island", recursively: true)?.categoryBitMask = 1
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        apiaryView.overlay.mapButton.isHidden = true
    }
    
    // MARK: - UI Functions
    
    final func linkOverlay() {
        apiaryView.overlay.shopButton.onTap(popToShop)
        apiaryView.overlay.evolutionButton.onTap(popToEvolution)
        apiaryView.overlay.mapButton.onTap(popToMap)
        apiaryView.overlay.beesButton.onTap({ [unowned self] in popToBeeList() })
    }
    
    final func selectNode(_ node: SCNNode & Model) {
        selectedNode = node
        node.accept(self)
        flashNode(node)
    }
    
    final func clearHud() {
        apiaryView.overlay.closeHud()
        apiaryView.overlay.showSharedHud()
        apiaryView.overlay.setButtons()
        apiaryView.camera.defaultView()
        apiaryView.camera.follow(nil)
        selectedNode = nil
    }
    
    final func flashNode(_ node: SCNNode, duration: Float = 0.25) {
        guard !node.hasActions else { return }
        let scale = node.scale
        let action = SCNAction.sequence([
            SCNAction.run({ node in
                SCNTransaction.begin()
                SCNTransaction.animationDuration = CFTimeInterval(duration / 2)
                SCNTransaction.animationTimingFunction = CAMediaTimingFunction(name: .easeIn)
                node.scale.x = 0.95
                node.scale.y = 1.1
                node.scale.z = 0.95
                SCNTransaction.commit()
            }),
            SCNAction.wait(duration: Double(duration) / 2),
            SCNAction.run({ node in
                SCNTransaction.begin()
                SCNTransaction.animationDuration = CFTimeInterval(duration / 2)
                SCNTransaction.animationTimingFunction = CAMediaTimingFunction(name: .easeOut)
                node.scale = scale
                SCNTransaction.commit()
            })
        ])
        action.duration = TimeInterval(duration)
        node.runAction(action)
    }
    
    func beginMovingStructure(_ structure: Structure, completion: (() throws -> Void)? = nil) {
        guard case .idle = state else { return }
        let originalArea = structure.area
        let isNew = structure.parent == nil
        
        func clear(_ success: Bool) {
            if !success {
                if isNew {
                    structure.removeFromParentNode()
                } else {
                    structure.area = originalArea
                    structure.position.x = Float(structure.area.x) + Float(structure.area.width) / 2
                    structure.position.z = Float(structure.area.y) + Float(structure.area.height) / 2
                }
            }
            state = .idle
            clearHud()
            apiaryView.apiary.structures.forEach({ $0.hideBorder() })
        }
        
        if isNew {
            apiaryView.scene?.rootNode.addChildNode(structure)
        }
        
        state = .moving(structure, structure.area)
        apiaryView.camera.birdsEyeView()
        apiaryView.overlay.hideSharedHud()
        
        for structure in apiaryView.apiary.structures {
            structure.showBorder()
        }
        
        if apiaryView.apiary.structures.contains(where: { $0.overlaps(structure) }) {
            structure.showBorder(.red)
        } else {
            structure.showBorder(.green)
        }
        
        apiaryView.overlay.setButtons(title: structure.name, [
            SKButton(texture: SKTexture.check, onTap: { [unowned self] in
                do {
                    try completion?()
                    guard !apiaryView.apiary.structures.contains(where: { $0.overlaps(structure) }) else {
                        throw ApiaryError.overlappingStructures
                    }
                    if isNew {
                        try GameManager.shared.addStructure(structure)
                    }
                    clear(true)
                } catch {
                    print(error.localizedDescription)
                }
            }),
            SKButton(texture: SKTexture.blankWhite, onTap: {
                clear(false)
            })
        ])
    }
    
    func beginAssigningBee(_ bee: Bee) {
        func clear(_ exception: Structure? = nil) {
            for structure in apiaryView.apiary.structures where structure !== exception {
                structure.removeBubble()
            }
            clearHud()
            state = .idle
        }
        
        state = .assigning(bee)
        apiaryView.overlay.hideSharedHud()
        apiaryView.overlay.setButtons(
            title: "Choose a Target for \(bee.nickname.prefix(10))",
            SKButton(texture: SKTexture.check, onTap: { clear() }),
            SKButton(texture: SKTexture.unlink, onTap: {
                try? bee.assign(to: nil)
                clear()
            })
        )
        
        for structure in apiaryView.apiary.structures where structure !== bee.producerAssignment {
            guard structure.assignedBees.count < structure.maximumAssignedBees else { continue }
            structure.removeBubble()
            structure.showBubble(texture: .plus) {
                try? bee.assign(to: structure)
                clear(structure)
            }
        }
    }
    
    // MARK: - UI Navigation
    
    private func popToShop() {
        let shopView = ShopView(frame: apiaryView.frame)
        shopView.shopDelegate = self
        apiaryView.addSubview(shopView)
    }
    
    private func popToEvolution() {
        let vc = EvolutionViewController(frame: apiaryView.frame)
        self.navigationController?.pushViewController(vc, animated: false)
    }
    
    private func popToMap() {
        print("Not implemented yet")
    }
    
    func popToBeeList(_ bee: Bee? = nil) {
        let beeListView = BeeListView(bees: apiaryView.apiary.bees, frame: apiaryView.frame)
        beeListView.onSelect { [weak self] bee in
            beeListView.removeFromSuperview()
            self?.selectNode(bee)
        }
        beeListView.onRelease { [weak self] in
            guard case .idle = self?.state else { return }
            GameManager.shared.releaseBees()
            beeListView.removeFromSuperview()
        }
        if let bee = bee {
            beeListView.selectBee(bee)
        }
        apiaryView.addSubview(beeListView)
    }
    
    func popToInspectionView(for structure: Structure) {
        let view = InspectionView(structure: structure, frame: apiaryView.frame)
        apiaryView.addSubview(view)
    }
    
    // MARK: - Gesture Recognizers
    
    private func addGestureRecognizers() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapHandler))
        let hold = UILongPressGestureRecognizer(target: self, action: #selector(holdHandler))
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panHandler))
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(pinchHandler))
        
        apiaryView.addGestureRecognizer(pan)
        apiaryView.addGestureRecognizer(pinch)
        apiaryView.addGestureRecognizer(tap)
        apiaryView.addGestureRecognizer(hold)
        
        for gesture in [tap, hold, pan, pinch] {
            gesture.cancelsTouchesInView = false
            gesture.delegate = self
        }
    }
    
    private weak var selectedNode: SCNNode? {
        didSet {
            (oldValue as? Structure)?.onUnselect()
            (selectedNode as? Structure)?.onSelect()
        }
    }
    
    @objc
    private func tapHandler (_ gestureRecognizer: UITapGestureRecognizer) {
        let point = gestureRecognizer.location(in: apiaryView)
        gestureRecognizer.numberOfTapsRequired = 1
        
        // Check and handle 2D interaction
        if let spriteNode = apiaryView.overlay.nodes(at: apiaryView.overlay.convertPoint(fromView: point)).first(where: { $0.isUserInteractionEnabled }) {
            if let button = spriteNode as? SKButton, !button.isHidden {
                button.pop()
                button.activate()
            }
            return
        }
        
        // Check and handle 3D interaction
        let hitResults = apiaryView.hitTest(point, options: [:])
        guard let node = hitResults.first?.node else {
            clearHud()
            return
        }
        
        if let bubble = hitResults.compactMap({ $0.node as? Bubble }).first {
            bubble.burst()
            clearHud()
            return
        }
        
        switch state {
        case .following(_):
            clearHud()
            state = .idle
            fallthrough
        case .idle:
            guard let bknode = node.firstParentModelNode() else {
                clearHud()
                return
            }
            selectNode(bknode)
        default: break
        }
    }
    
    @objc
    private func panHandler(_ gestureRecognizer: UIPanGestureRecognizer) {
        let fov = apiaryView.camera.camera!.fieldOfView
        let location = gestureRecognizer.location(in: apiaryView)
        let velocity = gestureRecognizer.velocity(in: apiaryView)
        // Velocity is larger for the shorter dimension
        let factor = 1 / max(apiaryView.frame.width, apiaryView.frame.height)
        let scaledVelocityX = Float(-velocity.x * fov * factor / 200)
        let scaledVelocityY = Float(-velocity.y * fov * factor / 200)
        
        switch state {
        case .following(_):
            clearHud()
            state = .idle
            fallthrough
        case .assigning(_):
            fallthrough
        case .idle:
            if gestureRecognizer.state == .began {
                apiaryView.camera.velocity = .zero
            }
            
            apiaryView.camera.translate(x: scaledVelocityX, y: 0, z: scaledVelocityY)
            
            if gestureRecognizer.state == .ended {
                apiaryView.camera.velocity = SCNVector3(x: scaledVelocityX, y: 0, z: scaledVelocityY)
            }
            
        case .moving(let structure, _):
            let hitTest = apiaryView.hitTest(gestureRecognizer.location(in: apiaryView), options: [.categoryBitMask: 1 << 1])
            guard let pos = hitTest.first?.worldCoordinates else { break }
            
            // The `if` statements stop the "glitching"
            let clipMargin: Float = 0.3
            if abs(pos.x - roundf(pos.x)) >= clipMargin {
                structure.area.x = Int(round(pos.x)) - structure.area.width / 2
            }
            if abs(pos.z - roundf(pos.z)) >= clipMargin {
                structure.area.y = Int(round(pos.z)) - structure.area.height / 2
            }
            
            structure.area.x.clamp(min: -25, max: 25 - structure.area.width)
            structure.area.y.clamp(min: -25, max: 25 - structure.area.height)
            structure.position.x = Float(structure.area.x) + Float(structure.area.width) / 2
            structure.position.z = Float(structure.area.y) + Float(structure.area.height) / 2
            
            let highlight = apiaryView.apiary.structures.contains(where: { $0.overlaps(structure) }) ? UIColor.red : .green
            structure.showBorder(highlight)
            
            // Moves the camera further towards direction of movement
            let glideMargin = 0.2
            if location.x < apiaryView.frame.width * glideMargin {
                apiaryView.camera.velocity.x = -0.05
            }
            if location.x > apiaryView.frame.width * (1 - glideMargin) {
                apiaryView.camera.velocity.x = 0.05
            }
            if location.y < apiaryView.frame.height * glideMargin {
                apiaryView.camera.velocity.z = -0.05
            }
            if location.y > apiaryView.frame.height * (1 - glideMargin) {
                apiaryView.camera.velocity.z = 0.05
            }
            
        default:
            break
        }
    }
    
    @objc
    private func pinchHandler(_ gestureRecognizer: UIPinchGestureRecognizer) {
        let velocity = Float(gestureRecognizer.velocity) / 3
        apiaryView.camera.zoom(velocity)
    }
    
    private weak var beeTargetCache: Structure?
    
    @objc
    private func holdHandler(_ gestureReconizer: UILongPressGestureRecognizer) {
        let hitTest = apiaryView.hitTest(gestureReconizer.location(in: apiaryView))
        
        if gestureReconizer.state == .began {
            if let bee = hitTest.first?.node.firstParentModelNode() as? Bee {
                state = .assigningWithDrag(bee)
                apiaryView.overlay.setButtons(title: "Choose a Target for \(bee.nickname.prefix(10))", [])
            }
        }
        
        guard case GameState.assigningWithDrag(_) = state else { return }
        
        if let node = hitTest.first?.node.firstParentModelNode() as? Structure {
            if node !== beeTargetCache {
                beeTargetCache?.unhighlight()
                beeTargetCache = node
                beeTargetCache?.highlight()
            }
        } else {
            beeTargetCache?.unhighlight()
            beeTargetCache = nil
        }
        
        if gestureReconizer.state == .ended {
            if case GameState.assigningWithDrag(let bee) = state, let target = beeTargetCache {
                try? bee.assign(to: target)
            }
            beeTargetCache?.unhighlight()
            beeTargetCache = nil
            state = .idle
            clearHud()
        }
    }
}

// MARK: - UIGestureRecognizerDelegate
extension ApiaryViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let loc = gestureRecognizer.location(in: apiaryView)
        if apiaryView.subviews.contains(where: { $0.frame.contains(loc) }) {
            return false
        }
        return true
    }
}

// MARK: - ModelVisitor
extension ApiaryViewController: ModelVisitor {
    func visitHoneyStorage(_ model: HoneyStorage) -> () {
        apiaryView.overlay.setButtons(title: model.name, [
            SKButton(texture: .move, onTap: { [unowned self] in
                beginMovingStructure(model)
            }),
            SKButton(texture: SKTexture.info, title: "Info", onTap: { [unowned self] in
                self.popToInspectionView(for: model)
            }),
        ])
    }
    
    func visitPollenStorage(_ model: PollenStorage) -> () {
        apiaryView.overlay.setButtons(title: model.name, [
            SKButton(texture: .move, onTap: { [unowned self] in
                beginMovingStructure(model)
            }),
            SKButton(texture: SKTexture.info, title: "Info", onTap: { [unowned self] in
                self.popToInspectionView(for: model)
            }),
        ])
    }
    
    func visitBee(_ model: Bee) -> () {
        state = .following(model)
        apiaryView.camera.follow(model)
        apiaryView.overlay.setButtons(
            title: model.nickname,
            SKButton(texture: SKTexture.edit, onTap: {
                self.apiaryView.camera.follow(nil)
                self.beginAssigningBee(model)
            }),
            SKButton(texture: SKTexture.info, title: "Info", onTap: { [unowned self] in
                self.popToBeeList(model)
            })
        )
    }
    
    func visitHive(_ model: Hive) -> () {
        apiaryView.overlay.setButtons(title: model.name, [
            SKButton(texture: SKTexture.blankWhite, title: "Add Honeycomb", onTap: {
                do {
                    try model.addHoneycomb()
                } catch {
                    print(error.localizedDescription)
                }
            }),
            SKButton(texture: SKTexture.check, title: "Collect", onTap: {
                GameManager.shared.collect(from: model)
            }),
            SKButton(texture: .move, onTap: { [unowned self] in
                beginMovingStructure(model)
            }),
            SKButton(texture: SKTexture.info, title: "Info", onTap: { [unowned self] in
                self.popToInspectionView(for: model)
            }),
        ])
    }
    
    func visitIncubator(_ model: Incubator) -> () {
        apiaryView.overlay.setButtons(title: model.name, [
            SKButton(texture: .move, onTap: { [unowned self] in
                beginMovingStructure(model)
            }),
            SKButton(texture: SKTexture.info, title: "Info", onTap: { [unowned self] in
                self.popToInspectionView(for: model)
            }),
        ])
    }
    
    func visitFlower(_ model: Flower) -> () {
        apiaryView.overlay.setButtons(title: model.name, [
            SKButton(texture: SKTexture.check, title: "Collect", onTap: {
                GameManager.shared.collect(from: model)
            }),
            SKButton(texture: .move, onTap: { [unowned self] in
                beginMovingStructure(model)
            }),
            SKButton(texture: SKTexture.info, title: "Info", onTap: { [unowned self] in
                self.popToInspectionView(for: model)
            }),
        ])
    }
}

// MARK: - SCNSceneRendererDelegate
extension ApiaryViewController: SCNSceneRendererDelegate {
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        guard let scene = apiaryView.scene else { return }
        for node in apiaryView.scene?.rootNode.childNodes ?? [] {
            guard let bee = node as? Bee else { continue }
            bee.droneStep(in: scene.physicsWorld)
        }
        
        if apiaryView.camera.velocity.magnitude > 0.0001 {
            let accelerationFactor = (1 - scene.physicsWorld.timeStep) * (1 - scene.physicsWorld.timeStep)
            apiaryView.camera.translate(vector: apiaryView.camera.velocity)
            apiaryView.camera.velocity *= Float(accelerationFactor)
        }
    }
}

// MARK: - ShopViewDelegate
extension ApiaryViewController: ShopViewDelegate {
    func shopView(_ shopView: ShopView, canSelectItem item: ShopItem) -> Bool {
        return GameManager.shared.getAllResources().canAfford(item.cost)
    }
    
    func shopView(_ shopView: ShopView, didSelectItem item: ShopItem) {
        let structure = item.newProduct()
        beginMovingStructure(structure) {
            try GameManager.shared.remove(item.cost)
        }
        shopView.removeFromSuperview()
    }
    
    func shopView(_ shopView: ShopView, itemsForSection section: ShopView.Section) -> [ShopItem] {
        switch section {
        case .structures:
            return [
                ShopItem(name: "Hive", description: nil, cost: Resources(), newProduct: { Hive() }),
                ShopItem(name: "Incubator", description: nil, cost: Resources(), newProduct: { Incubator() }),
                ShopItem(name: "Honey Jar Rack", description: nil, cost: Resources(), newProduct: { HoneyStorage() }),
                ShopItem(name: "Pollen Jar Rack", description: nil, cost: Resources(), newProduct: { PollenStorage() }),
            ]
        case .flowers:
            return [
                ShopItem(name: "Daisy", description: "A flower", cost: Resources(), newProduct: { Daisy() }),
                ShopItem(name: "Lavender", description: "A purple flower", cost: Resources(), newProduct: { Lavender() }),
                ShopItem(name: "Rose", description: "A red flower", cost: Resources(), newProduct: { Rose() })
            ]
        case .buy: return []
        }
    }
}
