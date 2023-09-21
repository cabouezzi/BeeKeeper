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
    
    public func layoutButton() {
        layoutButtons([
            SKButton(texture: Textures.blankOrange, onTap: { print("orange") }),
            SKButton(texture: Textures.blankWhite, onTap: { print("white") }),
            SKButton(texture: Textures.check, onTap: { print("check") }),
            SKButton(texture: Textures.edit, onTap: { print("edit") }),
            SKButton(texture: Textures.move, onTap: { print("move") }),
            SKButton(texture: Textures.evolution2, onTap: { print("lock") })
        ])
    }
    
    private func layoutButtons (_ buttons: [SKButton]) {
        guard !buttons.isEmpty else { return }
        /// The y-level where the buttons should be displayed
        let inset = size.height / 10
        let safeWidth = size.width - inset*2
        /// The calculated max width of the button
        let maxWidth = safeWidth / 5
        /// The width of the button, plus some empty space
        var paddedWidth = safeWidth / CGFloat(buttons.count)
        if paddedWidth > maxWidth {
            paddedWidth = maxWidth
        }
        let offset = paddedWidth / 2
        /// The width of the button relative to its padded width
        let buttonSize = paddedWidth * 0.8
        
        for index in 0..<buttons.count {
            let button = buttons[index]
            let position = CGFloat(index) * paddedWidth
            
            button.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            button.size = CGSize(width: buttonSize, height: buttonSize)
            button.position.x = offset + inset + position
            button.position.y = inset
            
            addChild(button)
            button.fadeUp()
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
    public func visitBee(_ model: Bee) -> Void {
        print("Overlay for bee")
    }
    
    public func visitHive(_ model: Hive) -> Void {
        print("Overlay for hive")
    }
    
    public func visitHoneycomb(_ model: Honeycomb) -> Void {
        print("Overlay for honeycomb")
    }
}
