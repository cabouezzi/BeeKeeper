//
//  ApiaryOverlay.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 9/9/23.
//

import SceneKit
import SpriteKit

class ApiaryOverlay: SKScene {
    let resources = ResourceDisplayHud()
    
    private var buttonsCache: Set<SKNode> = []
    
    private weak var currentHud: SKNode?
    let achievementsButton: SKButton = SKButton(texture: Textures.achievements)
    let tasksButton: SKButton = SKButton(texture: Textures.tasks)
    let mapButton: SKButton = SKButton(texture: Textures.map)
    let shopButton: SKButton = SKButton(texture: Textures.build)
    let evolutionButton: SKButton = SKButton(texture: Textures.atom)
    
    convenience override init() {
        self.init(size: .zero)
    }
    
    override init(size: CGSize) {
        super.init(size: size)
        self.isHidden = false
        self.scaleMode = .aspectFit
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        addChild(resources)
        
        resources.layout()
        resources.update(animated: false)
        
        // Achievements, tasks, map
        let section = size.height / 8
        let buttonSize = section * 0.85
        let spacing = section - buttonSize
        let leftButtons = [achievementsButton, tasksButton, mapButton]
        
        for (index, button) in leftButtons.enumerated() {
            button.anchorPoint = CGPoint(x: 0.5, y: 0.5) // top left
            button.size = CGSize(width: buttonSize, height: buttonSize)
            button.position.x = section / 2 + spacing
            button.position.y = size.height - CGFloat(index + 2) * section
            
            addChild(button)
        }
        
        // Shop
        let shopButtonSize = buttonSize * 1.5
        shopButton.anchorPoint = CGPoint(x: 0.5, y: 0.5) // top left
        shopButton.size = CGSize(width: shopButtonSize, height: shopButtonSize)
        shopButton.position.x = shopButtonSize / 2 + spacing * 2
        shopButton.position.y = shopButtonSize / 2 + spacing * 2
        addChild(shopButton)
        
        // Evolution
        evolutionButton.anchorPoint = CGPoint(x: 0.5, y: 0.5) // top left
        evolutionButton.size = CGSize(width: shopButtonSize, height: shopButtonSize)
        evolutionButton.position.x = size.width - shopButtonSize / 2 - spacing * 2
        evolutionButton.position.y = shopButtonSize / 2 + spacing * 2
        addChild(evolutionButton)
    }
    
    func setButtons (title: String? = nil, _ buttons: SKButton...) {
        setButtons(title: title, buttons)
    }
    
    func setButtons (title: String? = nil, _ buttons: [SKButton]) {
        for child in buttonsCache {
            child.fadeDownAndRemove()
            buttonsCache.remove(child)
        }
        
        /// The y-level where the buttons should be displayed
        let yPosition = size.height / 10
        let safeWidth = size.width - yPosition*2
        let center = size.width / 2
        /// The calculated max width of the button
        let maxWidth = safeWidth / 7
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
            
            buttonsCache.insert(button)
            addChild(button)
            button.fadeUp()
        }
        
        if let title = title {
            let label = SKLabelNode(text: title)
            label.fontName = "ArialRoundedMTBold"
            label.fontColor = .white
            
            label.position.x = center
            label.position.y = yPosition + paddedWidth / 2 + label.frame.height / 2
            
            buttonsCache.insert(label)
            addChild(label)
            label.fadeUp()
        }
    }
    
    func closeHud() {
        currentHud?.fadeDownAndRemove()
    }
    
    /// The label for a structure, located above the buttons. Contains the name, level, etc. of the selected entity.
    private func structureDescriptionNode(_ structure: Structure) -> SKNode {
        let node = SKLabelNode(text: (structure.name ?? "Structure") + "Lvl.\(structure.level)")
        return node
    }
    
    /// Creates a new HUD to that displays information for the given incubator.
    private func showIncubatorHud(_ incubator: Incubator) {
        setButtons([])
        let hud = IncubationHud(size: CGSize(width: size.width * 0.95, height: size.height / 2), incubator: incubator)
        hud.position = convertPoint(fromView: self.view?.center ?? .zero)
        currentHud = hud
        addChild(hud)
    }
    
    /// Creates a new HUD to that displays information for the given incubator.
    private func showStructureHud(_ structure: Structure) {
        setButtons([])
        let hud = StructureHud(size: CGSize(width: size.width * 0.95, height: size.height / 2), structure: structure)
        hud.position = convertPoint(fromView: self.view?.center ?? .zero)
        currentHud = hud
        addChild(hud)
    }
}

// MARK: ModelVisitor
extension ApiaryOverlay: ModelVisitor {
    func visitHoneyStorage(_ model: HoneyStorage) -> () {
        setButtons(title: model.name, [])
    }
    
    func visitPollenStorage(_ model: PollenStorage) -> () {
        setButtons(title: model.name, [])
    }
    
    func visitBee(_ model: Bee) -> Void {
        print("Bee was tapped! \(model.production)")
    }
    
    func visitHive(_ model: Hive) -> Void {
        setButtons(title: model.name, [
            SKButton(texture: Textures.blankWhite, title: "Add Honeycomb", onTap: {
                do {
                    try model.addHoneycomb()
                } catch {
                    print(error)
                }
            }),
            SKButton(texture: Textures.check, title: "Collect", onTap: {
                GameManager.shared.collect(from: model)
            }),
            SKButton(texture: Textures.info, title: "Info", onTap: { [unowned self] in
                self.showStructureHud(model)
            })
        ])
    }
    
    func visitIncubator(_ model: Incubator) -> () {
        setButtons(title: model.name, [
            SKButton(texture: Textures.blankWhite, title: "Incubate", onTap: { [unowned self] in
                self.showIncubatorHud(model)
            }),
        ])
    }
    
    func visitFlower(_ model: Flower) -> () {
        setButtons(title: model.name, [
            SKButton(texture: Textures.blankWhite, title: "Add Resources", onTap: {
                var resources = Resources(honey: 100, pollen: 100)
                do {
                    try model.fill(&resources)
                } catch {
                    print(error)
                }
            }),
            SKButton(texture: Textures.check, title: "Collect", onTap: {
                GameManager.shared.collect(from: model)
            })
        ])
    }
}
