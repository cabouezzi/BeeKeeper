//
//  ApiaryViewController.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 9/8/23.
//

import UIKit
import SceneKit

fileprivate enum GameState {
    case idle
    case moving(_ structure: Structure, _ originalPosition: SCNVector3)
    case assigning(_ bee: Bee)
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
#if DEBUG
        self.apiaryView.allowsCameraControl = true
        self.apiaryView.showsStatistics = true
#endif
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
        clearHud()
        linkOverlay()
        
        apiaryView.scene?.rootNode.childNode(withName: "Island", recursively: true)?.categoryBitMask = 1
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    final func linkOverlay() {
        apiaryView.overlay.shopButton.onTap(popToShop)
        apiaryView.overlay.evolutionButton.onTap(popToEvolution)
        apiaryView.overlay.mapButton.onTap(popToMap)
    }
    
    final func clearHud() {
        apiaryView.overlay.closeHud()
        apiaryView.overlay.setButtons()
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
    
    func beginAddingNewStructure(_ structure: Structure, completion: (() throws -> Void)? = nil) {
        guard case .idle = state else { return }
        
        state = .moving(structure, SCNVector3(0, 0, 0))
        apiaryView.scene?.rootNode.addChildNode(structure)
        
        if apiaryView.apiary.structures.contains(where: { $0.overlaps(structure) }) {
            structure.geometry?.materials.first?.emission.contents = UIColor.red
        }
        
        apiaryView.overlay.setButtons(title: structure.name, [
            SKButton(texture: Textures.check, onTap: { [weak self] in
                guard let self = self else { return }
                do {
                    try completion?()
                    try GameManager.shared.addStructure(structure)
                    self.state = .idle
                    self.clearHud()
                } catch {
                    print(error.localizedDescription)
                }
            }),
            SKButton(texture: Textures.blankWhite, onTap: { [weak self] in
                guard let self = self else { return }
                structure.removeFromParentNode()
                self.state = .idle
                self.clearHud()
            })
        ])
    }
    
    // MARK: - UI Navigation
    
    private func popToShop() {
        let shopView = ShopView(frame: apiaryView.frame)
        shopView.shopDelegate = self
        apiaryView.addSubview(shopView)
    }
    
    private func popToEvolution() {
        let vc = EvolutionViewController()
        self.navigationController?.pushViewController(vc, animated: false)
    }
    
    private func popToMap() {
        print("Not implemented yet")
    }
    
    // MARK: - Gesture Recognizers
    
    private func addGestureRecognizers() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapHandler))
        let hold = UILongPressGestureRecognizer(target: self, action: #selector(holdHandler))
        
#if !DEBUG
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panHandler))
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(pinchHandler))
        
        apiaryView.addGestureRecognizer(pan)
        apiaryView.addGestureRecognizer(pinch)
#endif
        
        apiaryView.addGestureRecognizer(tap)
        apiaryView.addGestureRecognizer(hold)
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
            if let button = spriteNode as? SKButton {
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
        
        if let bubble = node as? Bubble {
            bubble.burst()
            clearHud()
            return
        }
        
        switch state {
        case .idle:
            guard let bknode = node.firstParentModelNode() else {
                clearHud()
                return
            }
            selectedNode = bknode
            bknode.accept(self)
            bknode.accept(apiaryView.overlay)
            flashNode(bknode)
        default: break
        }
    }
    
    private lazy var lastCameraPosition = apiaryView.camera.pointOfView.position
    
    @objc
    private func panHandler(_ gestureRecognizer: UIPanGestureRecognizer) {
        let fov = apiaryView.camera.camera!.fieldOfView
        let velocity = gestureRecognizer.velocity(in: apiaryView)
        // Velocity is larger for the shorter dimension
        let factor = 1 / max(apiaryView.frame.width, apiaryView.frame.height)
        let scaledTranslationX = Float(velocity.x * fov * factor / 100)
        let scaledTranslationY = Float(velocity.y * fov * factor / 100)
        
        switch state {
        case .following(_):
            apiaryView.camera.follow(nil)
            clearHud()
            state = .idle
            lastCameraPosition = apiaryView.camera.pointOfView.position
            fallthrough
        case .idle:
            if gestureRecognizer.state == .began {
                apiaryView.camera.velocity = .zero
                lastCameraPosition = apiaryView.camera.pointOfView.position
            }
            
            apiaryView.camera.pointOfView.position.x -= scaledTranslationX
            apiaryView.camera.pointOfView.position.z -= scaledTranslationY
            
            if gestureRecognizer.state == .ended {
                apiaryView.camera.velocity = SCNVector3(x: scaledTranslationX, y: 0, z: scaledTranslationY)
            }
            
        case .moving(let structure, _):
            let hitTest = apiaryView.hitTest(gestureRecognizer.location(in: apiaryView), options: [.categoryBitMask: 1])
            guard let pos = hitTest.first?.worldCoordinates else { break }
            // The `if` statements stop the "glitching"
            let clipMargin: Float = 0.3
            if abs(pos.x - roundf(pos.x)) >= clipMargin {
                structure.area.x = Int(round(pos.x)) - structure.area.width / 2
            }
            if abs(pos.z - roundf(pos.z)) >= clipMargin {
                structure.area.y = Int(round(pos.z)) - structure.area.height / 2
            }
            structure.position.x = Float(structure.area.x)
            structure.position.z = Float(structure.area.y)
            
            if apiaryView.apiary.structures.contains(where: { $0.overlaps(structure) }) {
                structure.geometry?.materials.first?.emission.contents = UIColor.red
            } else {
                structure.geometry?.materials.first?.emission.contents = UIColor.black
            }
            
        default:
            break
        }
    }
    
    @objc
    private func pinchHandler(_ gestureRecognizer: UIPinchGestureRecognizer) {
        let velocity = gestureRecognizer.velocity / 2
        guard let camera = apiaryView.camera.camera else { return }
        
        camera.fieldOfView -= velocity
        
        if camera.fieldOfView > 70 {
            camera.fieldOfView = 70
        } else if camera.fieldOfView < 25 {
            camera.fieldOfView = 25
        }
        
        if gestureRecognizer.state == .ended {
            lastCameraPosition = apiaryView.camera.pointOfView.position
        }
    }
    
    private weak var beeTargetCache: Structure?
    
    @objc
    private func holdHandler(_ gestureReconizer: UILongPressGestureRecognizer) {
        let hitTest = apiaryView.hitTest(gestureReconizer.location(in: apiaryView))
        
        if gestureReconizer.state == .began {
            if let bee = hitTest.first?.node.firstParentModelNode() as? Bee {
                state = .assigning(bee)
                apiaryView.overlay.setButtons(title: "Choose a Target for \(bee.nickname.prefix(10))", [])
            }
        }
        
        guard case GameState.assigning(_) = state else { return }
        
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
            if case GameState.assigning(let bee) = state, let target = beeTargetCache {
                try! bee.assign(to: target)
            }
            beeTargetCache?.unhighlight()
            beeTargetCache = nil
            state = .idle
            clearHud()
        }
    }
}

// MARK: - ModelVisitor
extension ApiaryViewController: ModelVisitor {
    func visitHoneyStorage(_ model: HoneyStorage) -> () {
        
    }
    
    func visitPollenStorage(_ model: PollenStorage) -> () {
        
    }
    
    func visitBee(_ model: Bee) -> () {
        model.wiggle(repeatCount: 1)
        apiaryView.camera.follow(model)
        state = .following(model)
    }
    
    func visitHive(_ model: Hive) -> () {
        
    }
    
    func visitIncubator(_ model: Incubator) -> () {
        
    }
    
    func visitFlower(_ model: Flower) -> () {
        
    }
}

extension ApiaryViewController: SCNSceneRendererDelegate {
    func renderer(_ renderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval) {
        let accelerationFactor = (1 - scene.physicsWorld.timeStep) * (1 - scene.physicsWorld.timeStep)
        apiaryView.camera.pointOfView.position -= apiaryView.camera.velocity
        apiaryView.camera.velocity *= Float(accelerationFactor)
        
        for bee in apiaryView.apiary.bees {
            bee.droneStep(in: scene.physicsWorld)
        }
    }
}

extension ApiaryViewController: ShopViewDelegate {
    func shopView(_ shopView: ShopView, canSelectItem item: ShopItem) -> Bool {
        return GameManager.shared.getAllResources().canAfford(item.cost)
    }
    
    func shopView(_ shopView: ShopView, didSelectItem item: ShopItem) {
        let structure = item.newProduct()
        beginAddingNewStructure(structure) {
            try GameManager.shared.remove(item.cost)
        }
        shopView.removeFromSuperview()
    }
    
    func shopView(_ shopView: ShopView, itemsForSection section: ShopView.Section) -> [ShopItem] {
        switch section {
        case .structures:
            return [
                ShopItem(name: "Hive", description: nil, cost: Resources(), display: UIImage(named: "world.png")!, newProduct: { Hive() }),
                ShopItem(name: "Incubator", description: nil, cost: Resources(), display: UIImage(named: "world"), newProduct: { Incubator() }),
                ShopItem(name: "Honey Jar Rack", description: nil, cost: Resources(), display: UIImage(named: "world"), newProduct: { HoneyStorage() }),
                ShopItem(name: "Pollen Jar Rack", description: nil, cost: Resources(), display: UIImage(named: "world"), newProduct: { PollenStorage() }),
            ]
        case .flowers:
            return [
                ShopItem(name: "Blackfoot", description: "A flower", cost: Resources(), display: UIImage(named: "world"), newProduct: { Flower() }),
            ]
        case .buy: return []
        }
    }
}
