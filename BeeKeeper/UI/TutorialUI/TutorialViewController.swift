//
//  TutorialViewController.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 1/31/24.
//

import UIKit
import SceneKit
import SpriteKit

class TutorialViewController: ApiaryViewController {
    enum State {
        case initial
        case incubating
        case assigning
        case evolving
        case releasing
        case stalling
        case finished
    }
    let tutorialView: TutorialView
    private var state = State.initial
    
    private weak var pointer: SKNode?
    
    override init(frame: CGRect) {
        tutorialView = TutorialView(frame: frame)
        super.init(frame: frame)
        GameManager.shared.addObserver(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        GameManager.shared.removeObserver(self)
    }
    
    func highlightSKNode(_ node: SKNode) {
        removePointer()
        
        let pointer = SKSpriteNode(imageNamed: "chevron-down")
        pointer.size = node.frame.size
        pointer.size.width /= 2
        pointer.size.height /= 2
        pointer.anchorPoint = CGPoint(x: 0.5, y: -0.1)
        pointer.position.x = node.position.x
        pointer.position.y = node.frame.maxY
        
        let dist = pointer.size.height * 0.5
        let dur: TimeInterval = 1
        
        let up = SKAction.moveBy(x: 0, y: dist, duration: dur / 2)
        up.timingMode = .easeInEaseOut
        let down = SKAction.moveBy(x: 0, y: -dist, duration: dur / 2)
        down.timingMode = .easeInEaseOut
        
        let bob = SKAction.sequence([up, down])
        pointer.run(.repeatForever(bob))
        
        apiaryView.overlay.addChild(pointer)
        pointer.zPosition = .infinity
        self.pointer = pointer
    }
    
    func removePointer() {
        pointer?.removeFromParent()
    }
    
    func beginIncubatingTutorial() {
        let dialogue = [
            "Well, well, what do we have here? A surprise visitor in the apiary! I wasn't expecting company today, but I must say, it's a pleasant change from the routine. Have you too sensed the urgency, the responsibility we bear in a world teetering on the brink?",
            "I’m ___, and my purpose is crystal clear: breathe life back into the wings that once fluttered so tirelessly, restoring the harmony we've lost. If you want to help, you can start over at my little corner of experimentation. ",
            "See that contraption over there? Whatever genetically enhanced blueprints we got at hand, I pop that concoction into the incubator, and voila! It's like a fast-forward evolution process, bringing our buzzing friends back into the world.",
        ]
        tutorialView.queueSequence(dialogue: dialogue) { [unowned self] in
            guard let incubator = apiaryView.apiary.structures.first(where: { $0 is Incubator }) as? Incubator else { return }
            let action = SCNAction.move(to: incubator.worldPosition, duration: 0.5)
            action.timingMode = .easeOut
            apiaryView.camera.runAction(action)
            visitIncubator(incubator)
            state = .incubating
            if let button = apiaryView.overlay.children.compactMap({ $0 as? SKButton }).first(where: { $0.texture == .info }) {
                highlightSKNode(button)
            }
        }
    }
    
    override func beginAssigningBee(_ bee: Bee) {
        super.beginAssigningBee(bee)
        for structure in apiaryView.apiary.structures where !(structure is Flower) {
            structure.removeBubble()
        }
    }
    
    func beginAssigningTutorial(_ bee: Bee) {
        let dialogue = [
            "Hey, would you look at that!",
            "Well… um, quite different from your standard bee, wouldn't you say? I know, okay. It’s gonna take a bit of research to see how to get them looking more familiar.",
            "The thing is, research isn’t cheap. It takes a lot of resources to play around and find a genetic match. Pollen is usually the nutritional gold mine for bees, packed with all the amino acids and nutrients they need to thrive. I usually use that as my source of organic material.",
            "Have our new friend go about pollinating. If you plant some flowers, maybe you can harvest more pollen to help me out with my research.",
        ]
        tutorialView.queueSequence(dialogue: dialogue) { [unowned self] in
            state = .assigning
            apiaryView.camera.follow(nil)
            beginAssigningBee(bee)
        }
    }
    
    func beginEvolvingTutorial() {
        let dialogue = [
            "I've barely made any progress in terms of genetics, but you bring me a handful of pollen to fuel my research and give me the time,  I bet I can make some major strides!",
            "Take a look at my blueprints for their genetic makeup. I have to say, it ain't much, but it's a start.",
        ]
        tutorialView.queueSequence(dialogue: dialogue) { [unowned self] in
            state = .evolving
            apiaryView.camera.follow(nil)
            highlightSKNode(apiaryView.overlay.evolutionButton)
        }
    }
    
    func beginReleasingTutorial() {
        let dialogue = [
            "Done checking them out? It'll be worth your while, I promise. While some genes come with a phenotype, others will boost the productivity of the bees and increase their chance of survival in the wild.",
            "Wait... what? You thought they're staying here forever?",
            "Of course not! How else would we restore bees across the world? We have to release them at some point.",
            "As a matter of fact, this colony was due to be set free earlier today. Your arrival made me forget!"
        ]
        tutorialView.queueSequence(dialogue: dialogue) { [unowned self] in
            state = .releasing
            clearHud()
            highlightSKNode(apiaryView.overlay.beesButton)
        }
    }
    
    func beginForceRelease() {
        guard state == .stalling else { return }
        let dialogue = [
            "I know it's hard, but we have to do what we have to do...",
            "...And if you don't, I will."
        ]
        tutorialView.queueSequence(dialogue: dialogue) {
            DispatchQueue.main.asyncAfter(deadline: .now().advanced(by: .seconds(10))) { [weak self] in
                guard self?.state == .stalling, let self = self else { return }
                let dialogue = [
                    "Alright, friend, it's almost dark. Time to say your goodbyes, and for them to taste freedom."
                ]
                self.tutorialView.queueSequence(dialogue: dialogue) { [weak self] in
                    guard let self = self else { return }
                    GameManager.shared.releaseBees()
                    removePointer()
                    self.state = .finished
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tutorialView.isUserInteractionEnabled = false
        apiaryView.addSubview(tutorialView)
        tutorialView.layer.zPosition = 10
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if state == .initial {
            DispatchQueue.main.asyncAfter(deadline: .now().advanced(by: .seconds(3))) { [unowned self] in
                beginIncubatingTutorial()
            }
        } else if state == .evolving {
            removePointer()
            beginReleasingTutorial()
        }
    }
    
    override func tapHandler(_ gestureRecognizer: UITapGestureRecognizer) {
        let point = gestureRecognizer.location(in: tutorialView)
        
        switch state {
        case .initial:
            return
        case .incubating:
            if let spriteNode = apiaryView.overlay.nodes(at: apiaryView.overlay.convertPoint(fromView: point)).first(where: { $0.isUserInteractionEnabled }) {
                if let button = spriteNode as? SKButton, !button.isHidden, button.texture == .info {
                    button.pop()
                    button.activate()
                }
                return
            }
        case .assigning:
            let hitResults = apiaryView.hitTest(point, options: [:])
            if let bubble = hitResults.compactMap({ $0.node as? Bubble }).first, bubble.firstParentModelNode() is Flower {
                bubble.burst()
                beginEvolvingTutorial()
            }
            return
        case .evolving:
            if let spriteNode = apiaryView.overlay.nodes(at: apiaryView.overlay.convertPoint(fromView: point)).first(where: { $0.isUserInteractionEnabled }) {
                if let button = spriteNode as? SKButton, button == apiaryView.overlay.evolutionButton {
                    button.pop()
                    button.activate()
                }
                return
            }
        case .releasing, .stalling:
            if let spriteNode = apiaryView.overlay.nodes(at: apiaryView.overlay.convertPoint(fromView: point)).first(where: { $0.isUserInteractionEnabled }) {
                if let button = spriteNode as? SKButton, button == apiaryView.overlay.beesButton {
                    button.pop()
                    button.activate()
                    if state != .stalling {
                        state = .stalling
                        DispatchQueue.main.asyncAfter(deadline: .now().advanced(by: .seconds(5))) { [weak self] in
                            self?.beginForceRelease()
                        }
                    }
                }
                return
            }
        case .finished:
            return
        }
    }
    
    override func panHandler(_ gestureRecognizer: UIPanGestureRecognizer) {
        switch state {
        case .initial:
            return
        case .incubating:
            return
        case .assigning:
            super.panHandler(gestureRecognizer)
        case .evolving:
            return
        case .releasing:
            return
        case .stalling:
            super.panHandler(gestureRecognizer)
        case .finished:
            return
        }
    }
    
    override func popToBeeList(_ bee: Bee? = nil) {
        let beeListView = BeeListView(bees: apiaryView.apiary.bees, frame: apiaryView.frame)
        beeListView.onRelease { [unowned self] in
            GameManager.shared.releaseBees()
            removePointer()
            beeListView.removeFromSuperview()
            state = .finished
        }
        if let bee = bee {
            beeListView.selectBee(bee)
        }
        apiaryView.addSubview(beeListView)
    }
    
    func endTutorial() {
        let avc = ApiaryViewController(frame: apiaryView.frame)
        navigationController?.setViewControllers([avc], animated: false)
    }
}

extension TutorialViewController: GameObserver {
    func gameManager(_ account: Account, _ apiary: Apiary, didUpdateResources resources: Resources) {
        
    }
    
    func gameManager(_ account: Account, _ apiary: Apiary, didReleaseBees bees: [Bee]) {
        
    }
    
    func gameManager(_ account: Account, _ apiary: Apiary, didHatchBee bee: Bee) {
        visitBee(bee)
        removePointer()
        beginAssigningTutorial(bee)
    }
}
