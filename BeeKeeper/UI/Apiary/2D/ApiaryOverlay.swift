//
//  ApiaryOverlay.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 9/9/23.
//

import SceneKit
import SpriteKit

public class ApiaryOverlay: SKScene {
    convenience override init() {
        self.init(size: .zero)
    }
    
    override init(size: CGSize) {
        super.init(size: size)
        self.isHidden = false
        self.scaleMode = .aspectFit
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func layoutButtons() {
        layoutButtons([
            SKButton(texture: Textures.blankOrange, onTap: { print("orange") }),
            SKButton(texture: Textures.blankWhite, onTap: { print("white") }),
            SKButton(texture: Textures.check, onTap: { print("check") }),
            SKButton(texture: Textures.edit, onTap: { print("edit") }),
            SKButton(texture: Textures.move, onTap: { print("move") }),
            SKButton(texture: Textures.evolution2, onTap: { print("lock") })
        ])
    }
    
    private func layoutButtons (title: String? = nil, _ buttons: [SKButton]) {
        for child in children {
            child.fadeDownAndRemove()
        }
        guard !buttons.isEmpty else { return }
        /// The y-level where the buttons should be displayed
        let yPosition = size.height / 10
        let safeWidth = size.width - yPosition*2
        let center = size.width / 2
        /// The calculated max width of the button
        let maxWidth = safeWidth / 5
        /// The width of the button, plus some empty space
        var paddedWidth = safeWidth / CGFloat(buttons.count)
        paddedWidth = min(paddedWidth, maxWidth)
        
        /// The width of the button relative to its padded width
        let buttonSize = paddedWidth * 0.8
        
        for index in 0..<buttons.count {
            let button = buttons[index]
            let inset = CGFloat(index) * paddedWidth
            let offset = paddedWidth * CGFloat(buttons.count-1) / 2
            
            button.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            button.size = CGSize(width: buttonSize, height: buttonSize)
            button.position.x = center - offset + inset
            button.position.y = yPosition
            
            addChild(button)
            button.fadeUp()
        }
        
        if let title = title {
            let label = SKLabelNode(text: title)
            label.position.x = center
            label.position.y = yPosition + paddedWidth / 2 + label.frame.height / 2
            addChild(label)
            label.fadeUp()
        }
    }
    
    /// The label for a structure, located above the buttons. Contains the name, level, etc. of the selected entity.
    private func structureDescriptionNode(_ structure: Structure) -> SKNode {
        let node = SKLabelNode(text: structure.name + "Lvl.\(structure.level)")
        return node
    }
}

// MARK: ModelVisitor
extension ApiaryOverlay: ModelVisitor {
    
    public func visitHoneyStorage(_ model: HoneyStorage) -> () {
        layoutButtons(title: model.name, [
            SKButton(texture: Textures.check, onTap: { [weak self] in
                self?.layoutButtons()
            }),
            SKButton(texture: Textures.move, onTap: { [weak self] in
                self?.layoutButtons()
            })
        ])
    }
    
    public func visitBee(_ model: Bee) -> Void {
        
    }
    
    public func visitHive(_ model: Hive) -> Void {
        layoutButtons(title: model.name, [
            SKButton(texture: Textures.check, onTap: { [weak self] in
                _ = try? model.fill(Resources(honey: 50))
                self?.layoutButtons()
            }),
            SKButton(texture: Textures.move, onTap: { [weak self] in
                GameManager.shared.collect(from: model)
                self?.layoutButtons()
            })
        ])
    }
}
