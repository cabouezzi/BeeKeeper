//
//  EvolutionViewController.swift
//  Bee Keeper
//
//  Created by Chaniel Ezzi on 3/20/21.
//  Copyright © 2021 Cezzi. All rights reserved.
//

import SpriteKit

class EvolutionViewController: UIViewController {
    var evolutionView: SKView!
    var evolutionScene: SKScene = SKScene(fileNamed: "EvolutionScene.sks")!
    
    private var camera = SKCameraNode()
    private let centerNode: SKNode
    private let backStars: SKNode
    private let middleStars: SKNode
    
    init() {
        evolutionScene.backgroundColor = .black
        evolutionScene.camera = camera
        evolutionScene.addChild(camera)
        centerNode = evolutionScene.childNode(withName: "Center")!
        backStars = evolutionScene.childNode(withName: "BackStars")!
        backStars.setScale(2)
        middleStars = evolutionScene.childNode(withName: "MiddleStars")!
        middleStars.setScale(2)
        super.init(nibName: nil, bundle: nil)
        
        #if !RELEASE
        centerNode.isUserInteractionEnabled = true
        #else
        centerNode.isUserInteractionEnabled = false
        #endif
        middleStars.isUserInteractionEnabled = false
        backStars.isUserInteractionEnabled = false
        
        camera.constraints = [
            SKConstraint.positionX(SKRange(lowerLimit: -1515, upperLimit: 1515)),
            SKConstraint.positionY(SKRange(lowerLimit: -1515, upperLimit: 1515))
        ]
        backStars.constraints = [
            SKConstraint.positionX(SKRange(lowerLimit: -1515 / 2, upperLimit: 1515 / 2)),
            SKConstraint.positionY(SKRange(lowerLimit: -1515 / 2, upperLimit: 1515 / 2))
        ]
        middleStars.constraints = [
            SKConstraint.positionX(SKRange(lowerLimit: -1515 / 3, upperLimit: 1515 / 3)),
            SKConstraint.positionY(SKRange(lowerLimit: -1515 / 3, upperLimit: 1515 / 3))
        ]
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        evolutionView = SKView(frame: self.view.frame)
        evolutionView.presentScene(evolutionScene)
        self.view = evolutionView
        
        for node in evolutionScene.children {
            guard let gene = Gene(rawValue: node.name ?? "") else { continue }
            node.isUserInteractionEnabled = true
#if !RELEASE
            let label = SKLabelNode(text: node.name)
            label.fontSize = 20
            label.fontColor = .black
            label.position = node.position
            label.zPosition = .infinity
            evolutionScene.addChild(label)
            label.isUserInteractionEnabled = false
#endif
            
            if !GameManager.shared.account.unlockedGenes.contains(gene) {
                node.isHidden = true
            }
        }
        
        updateLockNodes()
        drawDirectedEdges()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        addGestureRecognizers()
        animateCenterNode()
    }
    
    private func animateCenterNode() {
        guard let centerTwo = centerNode.copy() as? SKNode else { return }
        centerTwo.name = centerNode.name
        evolutionScene.addChild(centerTwo)
        let action = SKAction.rotate(byAngle: .pi, duration: 3)
        let actionTwo = SKAction.rotate(byAngle: -.pi, duration: 3)
        centerNode.run(.repeatForever(action))
        centerTwo.run(.repeatForever(actionTwo))
    }
    
    private func drawDirectedEdges() {
        for edge in GeneNetwork.shared.edges {
            let to = evolutionScene.children.first(where: { node in
                guard let name = node.name, let gene = Gene(rawValue: name) else { return false }
                return gene == edge.to
            })
            let from = evolutionScene.children.first(where: { node in
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
            evolutionScene.addChild(line)
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
            guard let target = self.evolutionScene.childNode(withName: lockedGene.rawValue) else { continue }
            var lockNode: SKNode! = target.childNode(withName: "lock")
            if lockNode == nil {
                lockNode = SKSpriteNode(texture: Textures.evolutionLock)
                lockNode.name = "lock"
                lockNode.isUserInteractionEnabled = false
                lockNode.zPosition = target.zPosition + 1
                target.addChild(lockNode)
            }
            target.isHidden = false
        }
    }
    
    private var lastCameraPosition: CGPoint = CGPoint.zero
    
    private func addGestureRecognizers() {
        evolutionView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizer)))
        evolutionView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapGestureRecognizer)))
    }
    
    @objc
    private func tapGestureRecognizer(_ gestureRecognizer: UITapGestureRecognizer) {
        let pointInView = gestureRecognizer.location(in: evolutionView)
        let point = evolutionView.convert(pointInView, to: evolutionScene)
        guard let node = evolutionScene.nodes(at: point).first(where: { !$0.isHidden && $0.isUserInteractionEnabled }) else { return }
        
        if node.name == "Center" {
            let zoomInAction = SKAction.scale(by: 1.5, duration: 1)
            camera.run(zoomInAction)
            return
        }
        
        guard let name = node.name, let gene = Gene(rawValue: name) else { return }
        node.pop()
        
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
    
    @objc
    private func panGestureRecognizer(_ gestureRecognizer: UIPanGestureRecognizer) {
        if gestureRecognizer.state == .began {
            lastCameraPosition = camera.position
        }
        
        let point = gestureRecognizer.translation(in: evolutionView)
        let x = lastCameraPosition.x - point.x
        let y = lastCameraPosition.y + point.y
        
        camera.position.x = x
        backStars.position.x = camera.position.x / 2
        middleStars.position.x = camera.position.x / 3
        
        camera.position.y = y
        backStars.position.y = camera.position.y / 2
        middleStars.position.y = camera.position.y / 3
        
        if gestureRecognizer.state == .ended {
            lastCameraPosition = camera.position
        }
    }
}
