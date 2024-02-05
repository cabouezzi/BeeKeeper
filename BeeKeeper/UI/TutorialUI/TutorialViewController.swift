//
//  TutorialViewController.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 1/31/24.
//

import UIKit

class TutorialViewController: ApiaryViewController {
    let tutorialView: TutorialView
    
    override init(frame: CGRect) {
        tutorialView = TutorialView(frame: frame)
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tutorialView.isUserInteractionEnabled = false
        apiaryView.addSubview(tutorialView)
        tutorialView.layer.zPosition = 10
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tutorialView.queueDialogue("Well, well, what do we have here? A surprise visitor in the apiary! I wasn't expecting company today, but I must say, it's a pleasant change from the routine. Have you too sensed the urgency, the responsibility we bear in a world teetering on the brink?")
        tutorialView.queueDialogue("You’re not wrong. Look around – the hives, the emptiness – it's a canvas waiting for us to revive the dance of nature.")
        tutorialView.queueDialogue("I’m ___, and my purpose is crystal clear: breathe life back into the wings that once fluttered so tirelessly, restoring the harmony we've lost. If you want to help, you can start over at my little corner of experimentation. ")
        tutorialView.queueDialogue("See that contraption over there? That's my pride and joy, an incubator I've cooked up to bring our buzzing friends back into this world.")
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
