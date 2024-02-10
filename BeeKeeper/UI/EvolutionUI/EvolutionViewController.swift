//
//  EvolutionViewController.swift
//  Bee Keeper
//
//  Created by Chaniel Ezzi on 3/20/21.
//  Copyright © 2021 Cezzi. All rights reserved.
//

import SpriteKit

protocol EvolutionViewDataSource: AnyObject {
    func geneData(for gene: Gene) -> GeneData
}

class EvolutionViewController: UIViewController {
    private let evolutionView: EvolutionView
    private let dataView: EvolutionGeneDataView
    
    weak var dataSource: EvolutionViewDataSource? = EvolutionGeneDataSource.shared
    
    init(frame: CGRect) {
        evolutionView = EvolutionView(frame: frame)
        
        let width = frame.width / 3
        let dataRect = CGRect(x: frame.width - width, y: 0, width: width, height: frame.height).insetBy(dx: 10, dy: 10)
        dataView = EvolutionGeneDataView(frame: dataRect)
        dataView.backgroundColor = .white.withAlphaComponent(0.3)
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
        
        dataView.purchaseButton.addAction { [unowned self] in
            guard let data = dataView.data else { return }
            // Buy gene
            if !GameManager.shared.account.unlockedGenes.contains(data.gene) {
                do {
                    guard GameManager.shared.getAllResources().canAfford(data.cost) else { throw ContainerError.containerInsufficient }
                    try GameManager.shared.unlockGene(data.gene)
                    // FIXME: The force success is to intentionally crash if we can't afford it. This should never happen, but in the event it does, the crash prevents saving the gene as unlocked.
                    try! GameManager.shared.remove(data.cost)
                    if let icon = evolutionView.iconForGene(data.gene) {
                        icon.childNode(withName: "lock")?.removeFromParent()
                    }
                    updateLockNodes()
                    print("Successfully unlocked \(data.gene)")
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        SFXManager.shared.stopMusic()
    }
    
    func showData(for gene: Gene, animated: Bool = false) {
        dataView.isUserInteractionEnabled = true
        if let data = dataSource?.geneData(for: gene) {
            dataView.setGeneData(data)
        }
        UIView.animate(withDuration: animated ? 0.15 : 0) { [unowned dataView] in
            dataView.alpha = 1
        }
    }
    
    func hideData(animated: Bool = false) {
        dataView.isUserInteractionEnabled = false
        UIView.animate(withDuration: animated ? 0.15 : 0) { [unowned dataView] in
            dataView.alpha = 0
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
        guard let node = evolutionView.evolutionScene.nodes(at: point).first(where: { !$0.isHidden && $0.isUserInteractionEnabled }),
              let name = node.name,
              let gene = Gene(rawValue: name) else {
            hideData(animated: true)
            return
        }
        SFXManager.shared.playSound(.pop)
        node.pop()
        showData(for: gene, animated: true)
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
