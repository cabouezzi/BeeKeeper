//
//  IncubationHud.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 12/2/23.
//

import SpriteKit

class IncubationHud: SKNode {
    let incubator: Incubator
    let background: SKShapeNode
    let timeLabel: SKTextNode
    
    private var updateTimer: Timer?
    
    var incubateButton: SKButton!
    var hatchButton: SKButton!
    var speedUpButton: SKButton!
    
    init(size: CGSize, incubator: Incubator) {
        self.incubator = incubator
        self.background = SKShapeNode(rectOf: size, cornerRadius: 20)
        self.timeLabel = SKTextNode(text: nil, color: .orange)
        super.init()
        self.isUserInteractionEnabled = true
        
        background.strokeColor = .clear
        background.fillColor = .black
        addChild(background)
        
        let button = SKButton(texture: SKTexture.check) { [weak self] in
            self?.fadeDownAndRemove()
        }
        let s = max(size.width, size.height)
        button.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        button.size = CGSize(width: s / 20, height: s / 20)
        button.position.x = -size.width / 2 + button.size.width
        button.position.y = size.height / 2 - button.size.height
        addChild(button)
        
        self.incubateButton = SKButton(texture: SKTexture.blankOrange, title: "Incubate", onTap: { [weak self] in
            do {
                try self?.incubator.startIncubating(100)
                self?.updateHud()
            } catch {
                print(error.localizedDescription)
            }
        })
        self.hatchButton = SKButton(texture: SKTexture.blankWhite, title: "Hatch", onTap: { [weak self] in
            do {
                try self?.incubator.hatch()
                self?.updateHud()
            } catch {
                print(error.localizedDescription)
            }
        })
        self.speedUpButton = SKButton(texture: SKTexture.blankOrange, title: "Speed Up", onTap: { [weak self] in
            do {
                try self?.incubator.forceFinish()
                self?.updateHud()
            } catch {
                print(error.localizedDescription)
            }
        })
        
        timeLabel.anchorPoint = CGPoint(x: 0.5, y: 1)
        timeLabel.size = CGSize(width: size.width, height: size.width / 8)
        timeLabel.position.y = size.height / 2 - button.size.height * 2
        addChild(timeLabel)
        
        updateTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.updateHud()
        }
        updateTimer?.fire()
        
        incubateButton.size = CGSize(width: size.width / 2, height: size.width / 8)
        incubateButton.position.x = 0
        incubateButton.position.y = -size.height / 4
        addChild(incubateButton)
        
        hatchButton.size = CGSize(width: size.width / 4, height: size.width / 8)
        hatchButton.position.x = -size.width / 8 - 10
        hatchButton.position.y = -size.height / 4
        addChild(hatchButton)
        
        speedUpButton.size = CGSize(width: size.width / 4, height: size.width / 8)
        speedUpButton.position.x = size.width / 8 + 10
        speedUpButton.position.y = -size.height / 4
        addChild(speedUpButton)
    }
    
    deinit {
        self.updateTimer?.invalidate()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateHud() {
        switch incubator.state {
        case .idle:
            timeLabel.text = ""
            incubateButton.isHidden = false
            hatchButton.isHidden = true
            speedUpButton.isHidden = true
        case .incubating:
            guard let period = incubator.currentPeriod else { break }
            timeLabel.text = "Time Left: " + Date.now.distance(to: period.finishTime).formattedString()
            incubateButton.isHidden = true
            hatchButton.isHidden = false
            speedUpButton.isHidden = false
        case .finished:
            timeLabel.text = "Done"
            incubateButton.isHidden = true
            hatchButton.isHidden = false
            speedUpButton.isHidden = true
        }
    }
}
