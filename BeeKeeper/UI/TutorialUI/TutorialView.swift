//
//  TutorialView.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 2/5/24.
//

import UIKit
import SpriteKit

class TutorialView: UIControl {
    fileprivate class Sequence {
        var dialogue: [String]
        let completion: (() -> Void)?
        
        init(dialogue: [String], completion: (() -> Void)? = nil) {
            self.dialogue = dialogue
            self.completion = completion
        }
    }
    
    private(set) var isDialogueShown = false
    private var queue: [Sequence] = []
    private var currentSequence: Sequence?
    
    let bar: UIView
    let textLabel: UILabel
    let avatarView: UIImageView
    
    override init(frame: CGRect) {
        bar = UIView()
        bar.translatesAutoresizingMaskIntoConstraints = false
        bar.backgroundColor = .black.withAlphaComponent(0.75)
        
        textLabel = UILabel()
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        textLabel.backgroundColor = .clear
        textLabel.text = "Whats up homie"
        
        avatarView = UIImageView()
        avatarView.translatesAutoresizingMaskIntoConstraints = false
        avatarView.image = UIImage(named: "mannequin")
        avatarView.contentMode = .scaleAspectFit
        super.init(frame: frame)
        
        for subview in [bar, textLabel, avatarView] {
            addSubview(subview)
        }
        
        addConstraints([
            avatarView.leftAnchor.constraint(equalTo: leftAnchor),
            avatarView.bottomAnchor.constraint(equalTo: bottomAnchor),
            avatarView.heightAnchor.constraint(equalTo: bar.heightAnchor, constant: 50),
            avatarView.widthAnchor.constraint(equalTo: avatarView.heightAnchor),
            
            textLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            textLabel.leftAnchor.constraint(equalTo: avatarView.rightAnchor),
            textLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -10),
            textLabel.heightAnchor.constraint(lessThanOrEqualToConstant: 200),
            
            bar.bottomAnchor.constraint(equalTo: bottomAnchor),
            bar.topAnchor.constraint(equalTo: textLabel.topAnchor),
            bar.leftAnchor.constraint(equalTo: leftAnchor),
            bar.rightAnchor.constraint(equalTo: rightAnchor),
        ])
        
        hideDialogue(duration: 0)
        let tap = UITapGestureRecognizer(target: self, action: #selector(nextDialogue))
        addGestureRecognizer(tap)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func queueSequence(dialogue: [String], completion: (() -> Void)? = nil) {
        let shouldFire = queue.isEmpty
        queue.append(Sequence(dialogue: dialogue, completion: completion))
        if shouldFire {
            nextDialogue()
        }
    }
    
    @objc
    func nextDialogue() {
        if let seq = currentSequence {
            guard let dialogue = seq.dialogue.first else {
                hideDialogue()
                seq.completion?()
                currentSequence = nil
                return
            }
            setDialogue(dialogue)
            seq.dialogue.removeFirst()
        } else if let next = queue.first {
            queue.removeFirst()
            currentSequence = next
            nextDialogue()
        }
    }
    
    private func hideDialogue(duration: TimeInterval = 0.5) {
        bar.fadeOut(duration: duration)
        avatarView.fadeOut(duration: duration)
        textLabel.fadeOut(duration: duration)
        isDialogueShown = false
        isUserInteractionEnabled = false
        backgroundColor = .clear
    }
    
    private func setDialogue(_ text: String) {
        if !isDialogueShown {
            let dur = 0.5
            bar.fadeIn(duration: dur)
            avatarView.fadeIn(duration: dur)
            textLabel.fadeIn(duration: dur)
        }
        defer {
            isDialogueShown = true
            isUserInteractionEnabled = true
        }
        textLabel.text = text
        textLabel.font = .preferredFont(forTextStyle: .body)
        textLabel.textAlignment = .left
        textLabel.contentMode = .topLeft
        textLabel.numberOfLines = 0
        textLabel.setShadow(.black)
        textLabel.sizeToFit()
        backgroundColor = .black.withAlphaComponent(0.15)
        superview?.bringSubviewToFront(self)
    }
}
