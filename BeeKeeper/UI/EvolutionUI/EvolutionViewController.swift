//
//  EvolutionViewController.swift
//  Bee Keeper
//
//  Created by Chaniel Ezzi on 3/20/21.
//  Copyright © 2021 Cezzi. All rights reserved.
//

import SpriteKit

class EvolutionViewController: UIViewController {
    let evolutionView: EvolutionView
    let dataView: EvolutionGeneDataView
    
    init(frame: CGRect) {
        evolutionView = EvolutionView(frame: frame)
        
        let width = frame.width / 3
        let dataRect = CGRect(x: frame.width - width, y: 0, width: width, height: frame.height).insetBy(dx: 10, dy: 10)
        dataView = EvolutionGeneDataView(frame: dataRect)
        evolutionView.addSubview(dataView)
        super.init(nibName: nil, bundle: nil)
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
            #if !RELEASE
            let label = SKLabelNode(text: icon.name)
            label.fontSize = 20
            label.fontColor = .black
            label.position = icon.position
            label.zPosition = .infinity
            evolutionView.evolutionScene.addChild(label)
            label.isUserInteractionEnabled = false
            #endif
            
            if !GameManager.shared.account.unlockedGenes.contains(gene) {
                icon.isHidden = true
            }
        }
        
        updateLockNodes()
        drawDirectedEdges()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Add back button
        let frame = evolutionView.frame
        let backButton = UIButton(frame: CGRect(x: 25, y: 25, width: frame.height / 15, height: frame.height / 15))
        backButton.setImage(UIImage(named: "backButton"), for: .normal)
        backButton.addAction { [weak self] in
            self?.navigationController?.popViewController(animated: false)
        }
        evolutionView.addSubview(backButton)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        addGestureRecognizers()
        animateCenterNode()
    }
    
    func showDetails(for gene: Gene) {
        dataView.isHidden = false
        dataView.setGeneData(.init(gene: gene, details: "Aha! I think I've figured it out! Turns out it's the fur that gives bees their stripes pattern, but it's another mutation that sets their warning colors – aposematism. Let's see if this works now...", cost: Resources(money: 10000, honey: 10000, pollen: 10000, beeBread: 10000)))
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
            line.zPosition = 3
            evolutionView.evolutionScene.addChild(line)
        }
    }
    
    private func updateLockNodes() {
        let leaves = Gene.allCases
            .filter { g in
                guard !GameManager.shared.account.unlockedGenes.contains(g) else { return false }
                let prereq = GeneNetwork.shared.prerequisites(for: g)
                return prereq.isEmpty || prereq.contains(where: { GameManager.shared.account.unlockedGenes.contains($0) })
            }
        
        for lockedGene in leaves {
            guard let target = evolutionView.evolutionScene.childNode(withName: lockedGene.rawValue) else { continue }
            var lockNode: SKNode! = target.childNode(withName: "lock")
            if lockNode == nil {
                lockNode = SKSpriteNode(texture: SKTexture.evolutionLock)
                lockNode.name = "lock"
                lockNode.isUserInteractionEnabled = false
                lockNode.zPosition = target.zPosition + 1
                target.addChild(lockNode)
            }
            target.isHidden = false
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
        let pointInView = gestureRecognizer.location(in: evolutionView)
        let point = evolutionView.convert(pointInView, to: evolutionView.evolutionScene)
        guard let node = evolutionView.evolutionScene.nodes(at: point).first(where: { !$0.isHidden && $0.isUserInteractionEnabled }) else { return }
        
        guard let name = node.name, let gene = Gene(rawValue: name) else { return }
        node.pop()
        
        showDetails(for: gene)
        
        // Buy gene
        // TODO: Add extra steps: Show popup first, then buy/confirm button
        if !GameManager.shared.account.unlockedGenes.contains(gene) {
            do {
                try GameManager.shared.unlockGene(gene)
                node.childNode(withName: "lock")?.removeFromParent()
                updateLockNodes()
                print("Successfully unlocked \(gene)")
            } catch {
                print(error.localizedDescription)
            }
        }
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
