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
}

public class ApiaryViewController: UIViewController {
    var apiaryView: ApiaryView!
    private var state: GameState = .idle
    
    convenience init() {
        self.init(frame: .zero)
    }
    
    public init(frame: CGRect) {
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
    
    public override func loadView() {
        super.loadView()
        self.view = apiaryView
        apiaryView.loadNodes()
        showDefaultButtons()
    }
    
    final func showDefaultButtons() {
        apiaryView.overlay.layoutButtons([
            SKButton(texture: Textures.blankOrange, title: "Shop", onTap: popToShop),
            SKButton(texture: Textures.blankOrange, title: "Evolution", onTap: popToEvolution),
            SKButton(texture: Textures.evolutionLock,title: "Hatch bee", onTap: { _ = try? GameManager.shared.hatchBee(Bee()) })
        ])
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
        
        apiaryView.overlay.layoutButtons(title: structure.name, [
            SKButton(texture: Textures.check, onTap: { [weak self] in
                guard let self = self else { return }
                do {
                    try completion?()
                    self.state = .idle
                    self.apiaryView.overlay.layoutDefaultButtons()
                } catch {
                    print(error)
                }
            }),
            SKButton(texture: Textures.blankWhite, onTap: { [weak self] in
                guard let self = self else { return }
                bknode.removeFromParentNode()
                self.state = .idle
                self.apiaryView.overlay.layoutDefaultButtons()
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
    
    // MARK: - Gesture Recognizers
    
    private func addGestureRecognizers() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapHandler))
        
        #if !DEBUG
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panHandler))
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(pinchHandler))
        
        apiaryView.addGestureRecognizer(pan)
        apiaryView.addGestureRecognizer(pinch)
        #endif
        
        apiaryView.addGestureRecognizer(tap)
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
        
        switch state {
        case .idle:
            guard let node = hitResults.first?.node as? BKNode else {
                showDefaultButtons()
                return
            }
            node.model?.accept(self)
            node.model?.accept(apiaryView.overlay)
            flashNode(node)
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
            structure.area.x = Int(xTranslation / 50)
            structure.area.y = Int(yTranslation / 50)
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
    public func visitHoneyStorage(_ model: HoneyStorage) -> () {
        print("\(model.name) was tapped. \(model.containing) / \(model.maximum).")
    }
    
    public func visitPollenStorage(_ model: PollenStorage) -> () {
        print("\(model.name) was tapped. \(model.containing) / \(model.maximum).")
    }
    
    public func visitBee(_ model: Bee) -> () {
        print("\(model.name) was tapped.")
    }
    
    public func visitHive(_ model: Hive) -> () {
        print("\(model.name) was tapped. \(model.containing) / \(model.maximum)")
    }
    
    public func visitIncubator(_ model: Incubator) -> () {
        print("\(model.name) was tapped.")
    }
}
