//
//  EvolutionViewController.swift
//  Bee Keeper
//
//  Created by Chaniel Ezzi on 3/20/21.
//  Copyright © 2021 Cezzi. All rights reserved.
//

import SpriteKit
import SwiftUI
import Observation

class EvolutionViewController: UIViewController {
    let model = EvolutionDetailsViewModel()
    
    private let evolutionView: EvolutionView
    let hostingController: UIHostingController<AnyView>
    
    init(frame: CGRect) {
        evolutionView = EvolutionView(frame: frame)
        hostingController = UIHostingController(rootView: AnyView(EvolutionDetailsView(viewModel: model)))
        super.init(nibName: nil, bundle: nil)
        
        hostingController.view.backgroundColor = .clear
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.rightAnchor.constraint(equalTo: evolutionView.rightAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: evolutionView.bottomAnchor),
            hostingController.view.widthAnchor.constraint(lessThanOrEqualToConstant: evolutionView.frame.width / 2),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        self.view = evolutionView
        // Hide icons not unlocked, add labels
        for icon in evolutionView.icons {
            guard let gene = Gene(rawValue: icon.name ?? "") else { continue }
            icon.isUserInteractionEnabled = true
            if !GameManager.shared.account.unlockedGenes.contains(gene) {
                icon.isHidden = true
            }
        }
        
        updateLockNodes()
        observeGeneUnlocks()
        drawDirectedEdges()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Add back button
        let frame = evolutionView.frame
        let backButton = UIButton(frame: CGRect(x: 25, y: 25, width: frame.height / 15, height: frame.height / 15))
        backButton.setImage(UIImage(named: "backButton"), for: .normal)
        backButton.addAction { [weak self] in
            SFXManager.shared.playSound(.pop)
            self?.navigationController?.popViewController(animated: false)
        }
        evolutionView.addSubview(backButton)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        SFXManager.shared.playMusic(.evolution)
        
        addGestureRecognizers()
        animateCenterNode()
        
        if let research = EvolutionResearchManager.shared.currentResearch {
            model.gene = research.reward
            showData()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        SFXManager.shared.stopMusic()
    }
    
    func showData(animated: Bool = false) {
        UIView.animate(withDuration: animated ? 0.15 : 0) { [unowned hostingController] in
            hostingController.view.alpha = 1
        }
    }
    
    func hideData(animated: Bool = false) {
        UIView.animate(withDuration: animated ? 0.15 : 0) { [unowned hostingController] in
            hostingController.view.alpha = 0
        }
    }
    
    // MARK: - Appearance
    
    private func animateCenterNode() {
        let centerNode = evolutionView.centerNode
        guard let centerTwo = centerNode.copy() as? SKNode else { return }
        centerTwo.name = centerNode.name
        evolutionView.evolutionScene.addChild(centerTwo)
        let action = SKAction.rotate(byAngle: .pi, duration: 3)
        let actionTwo = SKAction.rotate(byAngle: -.pi, duration: 3)
        centerNode.run(.repeatForever(action))
        centerTwo.run(.repeatForever(actionTwo))
    }
    
    private func drawDirectedEdges() {
        for edge in GeneNetwork.shared.edges {
            let to = evolutionView.evolutionScene.children.first(where: { node in
                guard let name = node.name, let gene = Gene(rawValue: name) else { return false }
                return gene == edge.to
            })
            let from = evolutionView.evolutionScene.children.first(where: { node in
                guard let name = node.name, let gene = Gene(rawValue: name) else { return false }
                return gene == edge.from
            })
            guard let to = to, let from = from else {
                assert(to == from)
                print("Couldn't find nodes for edge \(edge)")
                continue
            }
            let startPoint = from.position
            let endPoint = to.position
            let path = UIBezierPath()
            path.addArrow(start: startPoint, end: endPoint, pointerLineLength: 30, arrowAngle: .pi / 12)
            
            let line = SKShapeNode()
            line.path = path.cgPath
            line.strokeColor = UIColor.white
            line.fillColor = .white
            line.lineWidth = 4
            line.zPosition = 0
            
            #if RELEASE
            line.isHidden = !GameManager.shared.account.unlockedGenes.contains(edge.from)
            #endif
            
            evolutionView.evolutionScene.addChild(line)
        }
    }
    
    private func updateLockNodes() {
        for gene in Gene.allCases {
            // Unlocked genes
            if GameManager.shared.account.unlockedGenes.contains(gene) {
                guard let target = evolutionView.evolutionScene.childNode(withName: gene.rawValue) else { continue }
                let lockNode: SKNode? = target.childNode(withName: "lock")
                lockNode?.removeFromParent()
                target.isHidden = false
            // Locked Genes
            } else {
                // Leaf, display locks for next available upgrades
                let prereq = GeneNetwork.shared.prerequisites(for: gene)
                if prereq.isEmpty || prereq.contains(where: { GameManager.shared.account.unlockedGenes.contains($0) }) {
                    guard let leaf = evolutionView.evolutionScene.childNode(withName: gene.rawValue) else { continue }
                    var lockNode: SKNode! = leaf.childNode(withName: "lock")
                    if lockNode == nil {
                        lockNode = SKSpriteNode(texture: SKTexture.evolutionLock)
                        lockNode.name = "lock"
                        lockNode.isUserInteractionEnabled = false
                        lockNode.zPosition = leaf.zPosition + 1
                        leaf.addChild(lockNode)
                    }
                    leaf.isHidden = false
                }
            }
        }
    }

    private func observeGeneUnlocks() {
        withObservationTracking {
            _ = model.unlockedGenes
        } onChange: { [weak self] in
            Task { @MainActor [weak self] in
                guard let self else { return }
                self.updateLockNodes()
                self.observeGeneUnlocks()
            }
        }
    }
    
    // MARK: - Gesture Recognizers
    
    private func addGestureRecognizers() {
        evolutionView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizer)))
        evolutionView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapGestureRecognizer)))
        evolutionView.addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: #selector(pinchGestureRecognizer)))
    }
    
    @objc
    private func tapGestureRecognizer(_ gestureRecognizer: UITapGestureRecognizer) {
        if let research = EvolutionResearchManager.shared.currentResearch {
            model.gene = research.reward
            return
        }
        
        let pointInView = gestureRecognizer.location(in: evolutionView)
        guard !hostingController.view.frame.contains(pointInView) || hostingController.view.alpha == 0 else { return }
        let point = evolutionView.convert(pointInView, to: evolutionView.evolutionScene)
        guard let node = evolutionView.evolutionScene.nodes(at: point).first(where: { !$0.isHidden && $0.isUserInteractionEnabled }),
              let name = node.name,
              let gene = Gene(rawValue: name) else {
            hideData(animated: true)
            return
        }
        SFXManager.shared.playSound(.pop)
        node.pop()
        model.gene = gene
        showData(animated: true)
    }

    private var cameraStartPosition: CGPoint = CGPoint.zero
    
    @objc
    private func panGestureRecognizer(_ gestureRecognizer: UIPanGestureRecognizer) {
        let camera = evolutionView.camera
        
        if gestureRecognizer.state == .began {
            cameraStartPosition = camera.position
            evolutionView.cameraVelocity = .zero
        }
        
        let translation = gestureRecognizer.translation(in: evolutionView)
        let velocity = gestureRecognizer.velocity(in: evolutionView)
        let x = cameraStartPosition.x - translation.x
        let y = cameraStartPosition.y + translation.y
        
        camera.position.x = x
        camera.position.y = y
        
        if gestureRecognizer.state == .ended {
            evolutionView.cameraVelocity = velocity
        }
    }
    
    private var previousCameraScale: CGFloat = 1
    
    @objc
    private func pinchGestureRecognizer(_ gestureRecognizer: UIPinchGestureRecognizer) {
        let camera = evolutionView.camera
        if gestureRecognizer.state == .began {
            previousCameraScale = camera.xScale
        }
        var newScale = previousCameraScale / gestureRecognizer.scale
        newScale.clamp(min: 1, max: 3)
        camera.setScale(newScale)
    }
}
