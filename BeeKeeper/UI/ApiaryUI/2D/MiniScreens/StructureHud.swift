//
//  StructureHud.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 1/12/24.
//

import SpriteKit

class StructureHud: SKNode {
    let structure: Structure
    let background: SKShapeNode
    private var updateTimer: Timer?
    
    init(size: CGSize, structure: Structure) {
        self.structure = structure
        self.background = SKShapeNode(rectOf: size, cornerRadius: 20)
        super.init()
        self.isUserInteractionEnabled = true
        
        background.strokeColor = .clear
        background.fillColor = .black
        addChild(background)
        
        let button = SKButton(texture: Textures.check) { [weak self] in
            self?.fadeDownAndRemove()
        }
        let s = max(size.width, size.height)
        button.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        button.size = CGSize(width: s / 20, height: s / 20)
        button.position.x = size.width / 2 - button.size.width
        button.position.y = size.height / 2 - button.size.height
        addChild(button)
        
        let name = SKLabelNode(text: structure.name)
        name.horizontalAlignmentMode = .left
        name.verticalAlignmentMode = .top
        name.position.x = -size.width / 2 + button.size.width
        name.position.y = size.height / 2 - button.size.height
        addChild(name)
        
        // FIXME: Use bindings
        if let container = structure as? Container {
            let containing = SKLabelNode(text: container.containing.description)
            containing.horizontalAlignmentMode = .left
            containing.verticalAlignmentMode = .top
            containing.position.x = -size.width / 2 + button.size.width
            containing.position.y = size.height / 2 - button.size.height * 2
            addChild(containing)
            
            let capacity = SKLabelNode(text: container.containing.description)
            capacity.horizontalAlignmentMode = .left
            capacity.verticalAlignmentMode = .top
            capacity.position.x = -size.width / 2 + button.size.width
            capacity.position.y = size.height / 2 - button.size.height * 3
            addChild(capacity)
            
            updateTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                containing.text = container.containing.description
                capacity.text = container.maximum.description
            }
            updateTimer?.fire()
            
            if let collector = container as? Collector {
                let collect = SKButton(texture: Textures.blankWhite, title: "Collect") {
                    GameManager.shared.collect(from: collector)
                    containing.text = container.containing.description
                    capacity.text = container.maximum.description
                }
                collect.size = CGSize(width: size.width / 2, height: size.width / 8)
                collect.position.x = containing.position.x + containing.frame.width + collect.size.width / 2 + button.size.width / 2
                collect.position.y = containing.position.y - collect.size.height / 2
                addChild(collect)
            }
        }
        
        var offset = size.height / 2 - button.size.height * 4
        for bee in structure.assignedBees.sorted(by: { $0.name < $1.name }) {
            let beeName = bee.name.count > 15 ? bee.name.prefix(12) + "..." : bee.name
            let beeInfo = SKLabelNode(text: beeName + " " + bee.production.description)
            beeInfo.horizontalAlignmentMode = .left
            beeInfo.verticalAlignmentMode = .top
            beeInfo.position.x = -size.width / 2 + button.size.width
            beeInfo.position.y = offset
            addChild(beeInfo)
            
            offset -= button.size.width
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        updateTimer?.invalidate()
    }
}
