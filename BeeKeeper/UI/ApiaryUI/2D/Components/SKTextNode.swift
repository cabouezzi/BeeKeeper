//
//  SKTextNode.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 12/2/23.
//

import SpriteKit

open class SKTextNode: SKSpriteNode {
    private var label: SKLabelNode
    
    open override var anchorPoint: CGPoint {
        didSet { update() }
    }
    
    open override var size: CGSize {
        didSet { update() }
    }
    
    open var fontColor: UIColor? {
        get { label.fontColor }
        set { label.fontColor = newValue }
    }
    
    open var fontSize: CGFloat {
        get { label.fontSize }
        set { label.fontSize = newValue }
    }
    
    open var fontName: String? {
        get { label.fontName }
        set { label.fontName = newValue }
    }
    
    open var text: String? {
        get { label.text }
        set { label.text = newValue }
    }
    
    init(text: String?, texture: SKTexture? = nil, color: UIColor = .clear, size: CGSize = .zero) {
        self.label = SKLabelNode(text: text)
        self.label.position = .zero
        self.label.horizontalAlignmentMode = .center
        self.label.verticalAlignmentMode = .baseline
        self.label.color = .red
        super.init(texture: texture, color: color, size: size)
        addChild(label)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func update() {
        label.position.x = -(anchorPoint.x - 0.5) * size.width
        label.position.y = -(anchorPoint.y - 0.5) * size.height
    }
}
