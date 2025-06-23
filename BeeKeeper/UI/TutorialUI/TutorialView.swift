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
    
    let bar: UIImageView
    private let topBorder = CALayer()
    let titleLabel: UILabel
    let textLabel: UILabel
    let avatarView: UIImageView
    
    override init(frame: CGRect) {
        // Setup bar as background image view with black semi-transparent top border
        bar = UIImageView(image: UIImage(resource: .backgroundWood))
        bar.contentMode = .scaleToFill
        bar.translatesAutoresizingMaskIntoConstraints = false
        
        topBorder.backgroundColor = UIColor.black.withAlphaComponent(0.3).cgColor
        bar.layer.addSublayer(topBorder)
        
        // Title label (bold)
        titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.boldSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .title3).pointSize)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .left
        titleLabel.numberOfLines = 1
        titleLabel.setShadow(.black)
        titleLabel.text = "The Keeper"
        
        // Dialogue text label
        textLabel = UILabel()
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        textLabel.backgroundColor = .clear
        textLabel.textColor = .white
        textLabel.font = UIFont.preferredFont(forTextStyle: .body)
        textLabel.textAlignment = .left
        textLabel.numberOfLines = 0
        textLabel.setShadow(.black)
        textLabel.text = "Whats up homie"
        
        // Avatar
        avatarView = UIImageView()
        avatarView.translatesAutoresizingMaskIntoConstraints = false
        avatarView.image = UIImage(resource: .beekeeper)
        avatarView.contentMode = .scaleAspectFit
        
        super.init(frame: frame)
        
        // Add subviews
        addSubview(bar)
        bar.addSubview(titleLabel)
        bar.addSubview(textLabel)
        addSubview(avatarView)
        
        // Constraints
        NSLayoutConstraint.activate([
            // Bar constraints
            bar.bottomAnchor.constraint(equalTo: bottomAnchor),
            bar.leftAnchor.constraint(equalTo: leftAnchor),
            bar.rightAnchor.constraint(equalTo: rightAnchor),
            bar.heightAnchor.constraint(equalToConstant: 200),
            
            // Title label at top of bar
            titleLabel.leftAnchor.constraint(equalTo: avatarView.rightAnchor, constant: 10),
            titleLabel.rightAnchor.constraint(equalTo: bar.rightAnchor, constant: -10),
            titleLabel.topAnchor.constraint(equalTo: bar.topAnchor, constant: 10),
            
            // Text label below title
            textLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            textLabel.leftAnchor.constraint(equalTo: titleLabel.leftAnchor),
            textLabel.rightAnchor.constraint(equalTo: bar.rightAnchor),
            textLabel.bottomAnchor.constraint(equalTo: bar.bottomAnchor, constant: -8),
            
            // Avatar constraints
            avatarView.leftAnchor.constraint(equalTo: leftAnchor),
            avatarView.bottomAnchor.constraint(equalTo: bottomAnchor),
            avatarView.heightAnchor.constraint(equalTo: bar.heightAnchor, constant: 50),
            avatarView.widthAnchor.constraint(equalTo: avatarView.heightAnchor),
        ])
        
        hideDialogue(duration: 0)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(nextDialogue))
        addGestureRecognizer(tap)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        topBorder.frame = CGRect(x: 0, y: 0, width: bar.bounds.width, height: 5)
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
        titleLabel.fadeOut(duration: duration)
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
            titleLabel.fadeIn(duration: dur)
            textLabel.fadeIn(duration: dur)
        }
        
        textLabel.text = text
        
        backgroundColor = .black.withAlphaComponent(0.15)
        superview?.bringSubviewToFront(self)
        
        isDialogueShown = true
        isUserInteractionEnabled = true
    }
}

