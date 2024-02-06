//
//  TutorialViewController.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 1/31/24.
//

import UIKit
import SceneKit

class TutorialViewController: ApiaryViewController {
    enum State {
        case initial
        case incubating
        case assigning
    }
    let tutorialView: TutorialView
    private var state = State.initial
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tutorialView.isUserInteractionEnabled = false
        apiaryView.addSubview(tutorialView)
        tutorialView.layer.zPosition = 10
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
            if let bubble = hitResults.compactMap({ $0.node as? Bubble }).first {
                bubble.burst()
            }
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
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tutorialView.nextDialogue()
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
        let dialogue = [
            "Well… um, quite different from your standard bee, wouldn't you say? I know, okay. It’s gonna take a bit of research to see how to get them looking more familiar.",
            "The thing is, research isn’t cheap. It takes a lot of resources to play around and find a genetic match. Pollen is usually the nutritional gold mine for bees, packed with all the amino acids and nutrients they need to thrive. I usually use that as my source of genetic material.",
            "Have our new friend go about pollinating. If you plant some flowers, maybe you can harvest more pollen to help me out with my research.",
        ]
        tutorialView.queueSequence(dialogue: dialogue) { [unowned self] in
            state = .assigning
            apiaryView.camera.follow(nil)
            beginAssigningBee(bee)
        }
    }
}
