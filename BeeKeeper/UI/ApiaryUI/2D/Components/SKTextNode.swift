//
//  SKTextNode.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 12/2/23.
//

import SpriteKit

open class SKTextNode: SKSpriteNode {
    private var label = SKLabelNode()
    
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
    
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        self.label = SKLabelNode(text: "")
        self.label.position = .zero
        self.label.horizontalAlignmentMode = .center
        self.label.verticalAlignmentMode = .baseline
        self.label.color = .red
        super.init(texture: texture, color: color, size: size)
        addChild(label)
        update()
    }
    
    convenience init(text: String?, texture: SKTexture) {
        self.init(texture: texture)
        label.text = text ?? label.text
    }
    
    convenience init(text: String?, color: UIColor) {
        self.init(texture: nil, color: color, size: .zero)
        label.text = text ?? label.text
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func update() {
        guard let text = text, text.count != 0 else { return }
        label.fontSize = label.frame.height
        let inset = UIFont.preferredFont(forTextStyle: .largeTitle).pointSize
        let frame = frame.insetBy(dx: inset, dy: inset)
        let scale = min(frame.width / label.frame.width, frame.height / label.frame.height)
        label.fontSize *= scale
        label.fontSize.clamp(min: UIFont.preferredFont(forTextStyle: .caption1).pointSize, max: UIFont.preferredFont(forTextStyle: .largeTitle).pointSize * 1.5)
        label.horizontalAlignmentMode = .left
        label.position.x = -(anchorPoint.x - 0.5) * size.width - frame.width / 2
        label.position.y = -(anchorPoint.y - 0.5) * size.height - inset / 2
    }
}
