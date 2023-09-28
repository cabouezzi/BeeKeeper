//
//  ResourceBar.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 9/9/23.
//

import SpriteKit

class ResourceBar: SKSpriteNode {
    /// Represents the total capacity of the given resources. Origin begins in the top right corner.
    private var capacityNode: SKSpriteNode!
    
    private var label: SKLabelNode = AnimatedIntLabel()
    
    /// Represents how much is filled in terms of its capacity.
    private var filledNode: SKSpriteNode!
    
    var barColor: UIColor = .orange {
        didSet { filledNode.color = barColor }
    }
    
    var capacity: Float = 1
    var containing: Float = 0
    
    init(containing: Float, capacity: Float, color: UIColor, size: CGSize) {
        super.init(texture: nil, color: .clear, size: size)
        self.containing = containing
        self.capacity = capacity
        self.barColor = color
        
        setupCapacityNode()
        setupFilledIndicator()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Update the values of the bar.
    func updateValues(containing: Float, capacity: Float) {
        self.containing = containing
        if capacity == .infinity || capacity == 0 {
            self.capacity = containing
        } else {
            self.capacity = capacity
        }
        updateFilledIndicator()
    }
    
    /// Resizes each bar to represent the current values, should be called after changing the vlaues. Animated.
    func updateFilledIndicator() {
        // Calculate the new width
        var width: CGFloat = 1
        if capacity != 0 {
            width = CGFloat(containing / capacity) * capacityNode.frame.width
        }
        
        filledNode.size.width = width
        // Update the value of the label
        label.text = String(format: "%d / %d", containing, capacity)
    }
    
    private func setupCapacityNode() {
        capacityNode = SKSpriteNode(texture: nil, size: frame.size)
        capacityNode.anchorPoint = CGPoint(x: 1, y: 1)
        capacityNode.color = UIColor.lightGray.withAlphaComponent(0.7)
        addChild(capacityNode)
    }
    
    private func setupFilledIndicator() {
        let height = capacityNode.frame.height
        let width = CGFloat(containing / capacity) * capacityNode.frame.width
        
        filledNode = SKSpriteNode(color: barColor, size: CGSize(width: width, height: height))
        filledNode.anchorPoint = CGPoint(x: 1, y: 1)
        filledNode.color = barColor
        
        label.fontName = "ArialRoundedMTBold"
        label.fontColor = .white
        label.fontSize = capacityNode.size.height * 0.5
        label.horizontalAlignmentMode = .left
        label.verticalAlignmentMode = .center
        label.position = CGPoint(x: -capacityNode.size.width * 0.95, y: -capacityNode.size.height / 2)
        
        addChild(filledNode)
        addChild(label)
        
        updateFilledIndicator()
    }
}
