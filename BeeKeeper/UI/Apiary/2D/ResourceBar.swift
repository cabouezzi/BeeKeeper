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
    
    private var label: AnimatedIntLabel = AnimatedIntLabel()
    /// Represents how much is filled in terms of its capacity.
    private var filledIndicator: SKSpriteNode!
    
    var barColor: UIColor = .orange {
        didSet { filledIndicator.color = barColor }
    }
    
    var capacity: Float = 1 {
        didSet {
            if capacity == 0 {
                capacity = containing
            }
            updateFilledIndicator(duration: 2)
        }
    }
    var containing: Float = 0 {
        didSet { updateFilledIndicator(duration: 2) }
    }
    
    init (containing: Float, capacity: Float, color: UIColor, size: CGSize) {
        super.init(texture: nil, color: .clear, size: size)
        self.containing = containing
        self.capacity = capacity
        self.barColor = color
        
        setupCapacityNode()
        setupFilledIndicator()
    }
    
    /// Update the values of the bar.
    func updateValues (containing: Float, capacity: Float) {
        self.containing = containing
        if capacity == .infinity || capacity == 0 {
            self.capacity = containing
        } else {
            self.capacity = capacity
        }
    }
    
    /// Resizes each bar to represent the current values, should be called after changing the vlaues. Animated.
    func updateFilledIndicator (duration: TimeInterval) {
        //Calculate the new width
        var width: CGFloat = 1
        if capacity != 0 {
            width = CGFloat(containing / capacity) * capacityNode.frame.width
        }
        //Create an action to resize into that width
        let action = SKAction.resize(toWidth: width, duration: duration)
        action.timingMode = .easeOut
        
        //Run that action
        filledIndicator.run(action)
        //Update the value of the label (see SKIntegerLabelNode.swift)
        label.changeValue(to: Int(containing), duration: duration)
    }
    
    private func setupCapacityNode () {
        capacityNode = SKSpriteNode(texture: nil, size: frame.size)
        capacityNode.anchorPoint = CGPoint(x: 1, y: 1)
        capacityNode.color = UIColor.lightGray.withAlphaComponent(0.7)
        addChild(capacityNode)
    }
    
    private func setupFilledIndicator () {
        let height = capacityNode.frame.height
//        let width = CGFloat(containing / capacity) * capacityNode.frame.width
        let width = CGFloat(0)
        
        filledIndicator = SKSpriteNode(color: barColor, size: CGSize(width: width, height: height))
        filledIndicator.anchorPoint = CGPoint(x: 1, y: 1)
        filledIndicator.color = barColor
        
        label.fontName = "ArialRoundedMTBold"
        label.fontColor = .white
        label.fontSize = capacityNode.size.height * 0.5
        label.horizontalAlignmentMode = .left
        label.verticalAlignmentMode = .center
        label.position = CGPoint(x: -capacityNode.size.width * 0.95, y: -capacityNode.size.height / 2)
        
        addChild(filledIndicator)
        addChild(label)
        
        updateValues(containing: containing, capacity: capacity)
        updateFilledIndicator(duration: 2)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
