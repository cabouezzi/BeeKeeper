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
    case moving(_ structure: Structure, _ node: BKNode, _ originalPosition: SCNVector3)
    case assigning(_ bee: Bee)
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
        apiaryView.overlay.mapButton.onTap(popToMap)
    }
    
    final func clearHud() {
        apiaryView.overlay.closeHud()
        apiaryView.overlay.setButtons()
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
        
        let bknode = structure.accept(NodeService.shared)
        state = .moving(structure, bknode, SCNVector3(0, 0, 0))
        apiaryView.scene?.rootNode.addChildNode(bknode)
        
        if apiaryView.apiary.structures.contains(where: { $0.overlaps(structure) }) {
            bknode.geometry?.materials.first?.emission.contents = UIColor.red
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
                    print(error)
                }
            }),
            SKButton(texture: Textures.blankWhite, onTap: { [weak self] in
                guard let self = self else { return }
                bknode.removeFromParentNode()
                self.state = .idle
                self.clearHud()
            })
        ])
    }
    
    // MARK: - UI Navigation
    
    private func popToShop() {
        let vc = ShopViewController(frame: apiaryView.frame)
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: false)
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
            return
        }
        
        switch state {
        case .idle:
            guard let bknode = node as? BKNode else {
                clearHud()
                return
            }
            bknode.model?.accept(self)
            bknode.model?.accept(apiaryView.overlay)
            flashNode(bknode)
        default: break
        }
    }
    
    private lazy var lastCameraPosition = apiaryView.cameraNode.position
    
    @objc
    private func panHandler(_ gestureRecognizer: UIPanGestureRecognizer) {
        // Translates the gesture into a number, the difference from start –> beginning
        let xTranslation = Float(gestureRecognizer.translation(in: apiaryView).x)
        let yTranslation = Float(gestureRecognizer.translation(in: apiaryView).y)
        
        // What the camera should move by
        let xSpeed = -xTranslation / 30
        let ySpeed = -yTranslation / 30
        
        switch state {
        case .idle:
            apiaryView.cameraNode.position.x = lastCameraPosition.x + xSpeed
            apiaryView.cameraNode.position.z = lastCameraPosition.z + ySpeed
            
            if gestureRecognizer.state == .ended {
                lastCameraPosition = apiaryView.cameraNode.position
            }
            
        case .moving(let structure, let node, _):
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
            node.position.x = Float(structure.area.x)
            node.position.z = Float(structure.area.y)
            
            if apiaryView.apiary.structures.contains(where: { $0.overlaps(structure) }) {
                node.geometry?.materials.first?.emission.contents = UIColor.red
            } else {
                node.geometry?.materials.first?.emission.contents = UIColor.black
            }
            
        default:
            break
        }
    }
    
    @objc
    private func pinchHandler(_ gestureRecognizer: UIPinchGestureRecognizer) {
        let velocity = gestureRecognizer.velocity / 2
        
        apiaryView.cameraNode.camera?.fieldOfView -= velocity
        
        if gestureRecognizer.state == .ended {
            lastCameraPosition = apiaryView.cameraNode.position
        }
    }
    
    private var beeTargetCache: BKNode?
    
    @objc
    private func holdHandler(_ gestureReconizer: UILongPressGestureRecognizer) {
        let hitTest = apiaryView.hitTest(gestureReconizer.location(in: apiaryView))
        
        if gestureReconizer.state == .began {
            if let bknode = hitTest.first?.node.firstBKNodeParent(), let bee = bknode.model as? Bee {
                state = .assigning(bee)
                apiaryView.overlay.setButtons(title: "Choose a Target for \(bee.name.prefix(10))", [])
            }
        }
        
        guard case GameState.assigning(_) = state else { return }
        
        if let node = hitTest.first?.node as? BKNode, let structure = node.model as? Structure {
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
            if case GameState.assigning(let bee) = state, let target = beeTargetCache?.model as? Structure {
                try? bee.assign(to: target)
            }
            beeTargetCache?.unhighlight()
            beeTargetCache = nil
            state = .idle
            clearHud()
        }
    }
}

extension ApiaryViewController: ShopDelegate {
    func shopViewController(_ shopViewController: ShopViewController, didSelectItem item: ShopItem) {
        let structure = item.newProduct()
        beginAddingNewStructure(structure)
        shopViewController.navigationController?.popViewController(animated: false)
    }
    
    func shopViewController(_ shopViewController: ShopViewController, canSelectItem item: ShopItem) -> Bool {
        return GameManager.shared.getAllResources().canAfford(item.cost)
    }
}

// MARK: - ModelVisitor
extension ApiaryViewController: ModelVisitor {
    func visitHoneyStorage(_ model: HoneyStorage) -> () {
        print("\(model.name) was tapped. \(model.containing) / \(model.maximum).")
    }
    
    func visitPollenStorage(_ model: PollenStorage) -> () {
        print("\(model.name) was tapped. \(model.containing) / \(model.maximum).")
    }
    
    func visitBee(_ model: Bee) -> () {
        print("\(model.name) was tapped.")
    }
    
    func visitHive(_ model: Hive) -> () {
        print("\(model.name) was tapped. \(model.containing) / \(model.maximum)")
    }
    
    func visitIncubator(_ model: Incubator) -> () {
        print("\(model.name) was tapped.")
    }
    
    func visitFlower(_ model: Flower) -> () {
        print("\(model.name) was tapped. \(model.containing) / \(model.maximum).")
    }
}
