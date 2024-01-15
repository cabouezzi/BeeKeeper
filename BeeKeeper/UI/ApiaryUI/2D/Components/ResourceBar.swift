//
//  ResourceBar.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 9/9/23.
//

import SpriteKit

class ResourceBar: SKSpriteNode {
    // Crops the filler node
    private var cropNode: SKCropNode!
    // Background
    private var capacityNode: SKShapeNode!
    // Shows fill progress
    private var filledNode: SKSpriteNode!
    
    private var outlineNode: SKShapeNode!
    private var tintNode: SKShapeNode!
    private var label: SKLabelNode!

    
    private var symbolNode: SKSpriteNode!
    
    var barColor: UIColor = .orange {
        didSet { filledNode.color = barColor }
    }
    
    var capacity: Float = 1
    var containing: Float = 0.5
    
    init(containing: Float, capacity: Float, color: UIColor, size: CGSize, symbolImageName imageName: String = "honeySymbol") {
        super.init(texture: nil, color: .clear, size: size)
        self.containing = containing
        self.capacity = capacity
        self.barColor = color
        
        setupCropNode()
        setupCapacityNode()
        setupTintNode()
        setupFilledIndicator()
        setupSymbolNode(imageName)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Update the values of the bar.
    func updateValues(containing: Float, capacity: Float, animated: Bool = true) {
        self.containing = containing
        if capacity == .infinity || capacity == 0 {
            self.capacity = containing
        } else {
            self.capacity = capacity
        }
        
        updateFilledIndicator(animated: animated)
    }
    
    /// Resizes each bar to represent the current values, should be called after changing the vlaues.
    func updateFilledIndicator(animated: Bool = true) {
        // Calculate the new width
        var width: CGFloat = 1
        if capacity != 0 {
            width = CGFloat(containing / capacity) * size.width
        }
        let action = SKAction.resize(toWidth: width, duration: animated ? 1 : 0)
        action.timingMode = .easeOut
        filledNode.run(action)
        // TODO: Animate number as well
        label.text = String(format: "%.0f / %.0f", floor(containing), floor(capacity))
    }
    
    private func setupCropNode() {
        var transform = CGAffineTransform(translationX: -size.width, y: -size.height / 2)
        let path = CGPath(roundedRect: CGRect(x: 0, y: 0, width: size.width, height: size.height), cornerWidth: 12, cornerHeight: 12, transform: &transform)
        let maskNode = SKShapeNode(path: path)
        maskNode.fillColor = .black
        maskNode.strokeColor = .black
        maskNode.lineWidth = 2
        cropNode = SKCropNode()
        cropNode.maskNode = maskNode
        cropNode.zPosition = 0
        addChild(cropNode)
    }
    
    private func setupCapacityNode() {
        var transform = CGAffineTransform(translationX: -size.width, y: -size.height / 2)
        let path = CGPath(roundedRect: CGRect(x: 0, y: 0, width: size.width, height: size.height), cornerWidth: 12, cornerHeight: 12, transform: &transform)
        capacityNode = SKShapeNode(path: path)
        capacityNode.fillColor = UIColor(white: 0.98, alpha: 0.5)
        capacityNode.strokeColor = .clear
        capacityNode.zPosition = 0
        cropNode.addChild(capacityNode)
        
        outlineNode = SKShapeNode(path: path)
        outlineNode.fillColor = .clear
        outlineNode.strokeColor = .white
        outlineNode.lineWidth = 2
        outlineNode.zPosition = 2
        addChild(outlineNode)
        
    }
    
    private func setupTintNode() {
        let inset: CGFloat = 5
        let width: CGFloat = size.width - inset * 2
        let height: CGFloat = size.height / 3
        
        var transform = CGAffineTransform(translationX: -width / 2, y: -height)
        let path = CGPath(roundedRect: CGRect(x: 0, y: 0, width: width, height: height), cornerWidth: 6, cornerHeight: 6, transform: &transform)
        tintNode = SKShapeNode(path: path)
        tintNode.position.x = capacityNode.position.x - size.width / 2
        tintNode.position.y = size.height / 2 - inset
        tintNode.fillColor = UIColor(white: 1, alpha: 0.5)
        tintNode.strokeColor = .clear
        tintNode.zPosition = 2
        cropNode.addChild(tintNode)
    }
    
    private func setupFilledIndicator() {
        let width = CGFloat(containing / capacity) * capacityNode.frame.width
        
        filledNode = SKSpriteNode(color: barColor, size: CGSize(width: width, height: size.height - capacityNode.lineWidth))
        filledNode.anchorPoint = CGPoint(x: 1, y: 0.5)
        filledNode.color = barColor
        filledNode.position.x = capacityNode.position.x
        filledNode.zPosition = 1
        cropNode.addChild(filledNode)
        
        label = SKLabelNode()
        label.fontName = "ArialRoundedMTBold"
        label.fontColor = .white
        label.fontSize = size.height * 0.5
        label.horizontalAlignmentMode = .left
        label.verticalAlignmentMode = .center
        label.position.x = capacityNode.position.x - size.width + label.fontSize
        label.zPosition = 4
        addChild(label)
        
        updateFilledIndicator(animated: false)
    }
    
    private func setupSymbolNode(_ imageName: String) {
        symbolNode = SKSpriteNode(imageNamed: imageName)
        symbolNode.anchorPoint = CGPoint(x: 0.4, y: 0.5)
        symbolNode.position.x = capacityNode.position.x
        symbolNode.zPosition = 3
        
        let scale = size.height / symbolNode.size.height * 1.05
        symbolNode.size.width *= scale
        symbolNode.size.height *= scale
        addChild(symbolNode)
    }
}
