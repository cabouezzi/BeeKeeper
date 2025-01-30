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
    let nameNode = SKTextNode(text: "Chaniel's Bees", texture: .plank)
    
    let achievementsButton = SKButton(texture: SKTexture.achievements)
    let tasksButton = SKButton(texture: SKTexture.tasks)
    let mapButton = SKButton(texture: SKTexture.map)
    let shopButton = SKButton(texture: SKTexture.build)
    
    let beesButton: SKButton = SKButton(texture: SKTexture.bees)
    let evolutionButton: SKButton = SKButton(texture: SKTexture.atom)
    
    private var buttonsCache: Set<SKNode> = []
    private weak var currentHud: SKNode?
    private let sharedHud = SKNode()
    
    convenience override init() {
        self.init(size: .zero)
    }
    
    override init(size: CGSize) {
        super.init(size: size)
        self.isHidden = false
        self.scaleMode = .aspectFit
        setup()
        
        let camera = SKCameraNode()
        camera.position.x = size.width / 2
        camera.position.y = size.height / 2
        self.camera = camera
        addChild(camera)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        addChild(resources)
        resources.layout()
        resources.update(animated: false)
        
        // Achievements, tasks, map
        let section = min(size.height / 6, size.width / 10)
        let buttonSize = section * 0.85
        let spacing = section - buttonSize
        let leftButtons = [achievementsButton, tasksButton, mapButton]
        
#if DEBUG
        for (index, button) in leftButtons.enumerated() {
            button.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            button.size = CGSize(width: buttonSize, height: buttonSize)
            button.position.x = section / 2 + spacing
            button.position.y = size.height - CGFloat(index + 2) * section
            sharedHud.addChild(button)
        }
#endif
        
        // Bee list
        beesButton.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        beesButton.size = CGSize(width: buttonSize, height: buttonSize)
        beesButton.position.x = size.width - section / 2 - spacing
        beesButton.position.y = resources.calculateAccumulatedFrame().minY - buttonSize / 2 - spacing
        sharedHud.addChild(beesButton)
        
        // Shop
        let shopButtonSize = buttonSize * 1.5
        shopButton.anchorPoint = CGPoint(x: 0.5, y: 0.5) // top left
        shopButton.size = CGSize(width: shopButtonSize, height: shopButtonSize)
        shopButton.position.x = shopButtonSize / 2 + spacing * 2
        shopButton.position.y = shopButtonSize / 2 + spacing * 2
        sharedHud.addChild(shopButton)
        
        // Evolution
        evolutionButton.anchorPoint = CGPoint(x: 0.5, y: 0.5) // top left
        evolutionButton.size = CGSize(width: shopButtonSize, height: shopButtonSize)
        evolutionButton.position.x = size.width - shopButtonSize / 2 - spacing * 2
        evolutionButton.position.y = shopButtonSize / 2 + spacing * 2
        sharedHud.addChild(evolutionButton)
        
        // Name
        let scale = min((size.width * 0.5) / nameNode.size.width, buttonSize / nameNode.size.height)
        nameNode.anchorPoint = CGPoint(x: 0, y: 1)
        nameNode.xScale = scale
        nameNode.yScale = scale
        nameNode.position.x = spacing
        nameNode.position.y = resources.calculateAccumulatedFrame().maxY
        addChild(nameNode)
        
        addChild(sharedHud)
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
        let safeWidth = size.width - yPosition * 2
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
            label.fontSize = buttonSize / 4
            
            label.position.x = center
            label.position.y = yPosition + paddedWidth / 2 + label.frame.height / 2
            
            buttonsCache.insert(label)
            addChild(label)
            label.fadeUp()
        }
    }
    
    func showSharedHud() {
        sharedHud.fadeUp()
    }
    
    func hideSharedHud() {
        sharedHud.fadeDown()
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
    func showIncubatorHud(_ incubator: Incubator) {
        setButtons([])
        let hud = IncubationHud(size: CGSize(width: size.width * 0.95, height: size.height / 2), incubator: incubator)
        hud.position = convertPoint(fromView: self.view?.center ?? .zero)
        currentHud = hud
        addChild(hud)
    }
    
    /// Creates a new HUD to that displays information for the given incubator.
    func showStructureHud(_ structure: Structure) {
        setButtons([])
        let hud = StructureHud(size: CGSize(width: size.width * 0.95, height: size.height / 2), structure: structure)
        hud.position = convertPoint(fromView: self.view?.center ?? .zero)
        currentHud = hud
        addChild(hud)
    }
}
