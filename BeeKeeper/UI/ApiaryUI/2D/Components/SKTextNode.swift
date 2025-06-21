//
//  SKTextNode.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 12/2/23.
//

import SpriteKit

import SpriteKit

open class SKTextNode: SKSpriteNode {
    private var label = SKLabelNode()
    private var shadowLabel = SKLabelNode()

    open override var anchorPoint: CGPoint {
        didSet { update() }
    }

    open override var size: CGSize {
        didSet { update() }
    }

    open var fontColor: UIColor? {
        get { label.fontColor }
        set {
            label.fontColor = newValue
            shadowLabel.fontColor = newValue?.withAlphaComponent(0.25)
        }
    }

    open var fontSize: CGFloat {
        get { label.fontSize }
        set {
            label.fontSize = newValue
            shadowLabel.fontSize = newValue
        }
    }

    open var fontName: String? {
        get { label.fontName }
        set {
            if let name = newValue {
                let boldName = "\(name)-Bold"
                label.fontName = boldName
                shadowLabel.fontName = boldName
            }
        }
    }

    open var text: String? {
        get { label.text }
        set {
            label.text = newValue
            shadowLabel.text = newValue
        }
    }

    init(text: String?, texture: SKTexture?) {
        label = SKLabelNode(text: text ?? "")
        shadowLabel = SKLabelNode(text: text ?? "")

        let defaultBoldFont = UIFont.systemFont(ofSize: UIFont.labelFontSize, weight: .bold).fontName
        label.fontName = defaultBoldFont
        shadowLabel.fontName = defaultBoldFont

        shadowLabel.zPosition = label.zPosition - 1
        shadowLabel.fontColor = UIColor.black.withAlphaComponent(0.25)

        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .baseline

        shadowLabel.horizontalAlignmentMode = .center
        shadowLabel.verticalAlignmentMode = .baseline

        super.init(texture: texture, color: .clear, size: texture?.size() ?? .zero)

        addChild(shadowLabel)
        addChild(label)
        update()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func update() {
        guard let text = text, !text.isEmpty else { return }

        label.fontSize = label.frame.height
        shadowLabel.fontSize = label.fontSize

        let inset = UIFont.preferredFont(forTextStyle: .body).pointSize
        let insetFrame = frame.insetBy(dx: inset, dy: inset)
        let scale = min(insetFrame.width / label.frame.width, insetFrame.height / label.frame.height)

        label.fontSize *= scale
        shadowLabel.fontSize = label.fontSize

        let minFontSize = UIFont.preferredFont(forTextStyle: .caption2).pointSize
        let maxFontSize = UIFont.preferredFont(forTextStyle: .title1).pointSize
        label.fontSize.clamp(min: minFontSize, max: maxFontSize)
        shadowLabel.fontSize = label.fontSize

        label.horizontalAlignmentMode = .left
        shadowLabel.horizontalAlignmentMode = .left

        let offsetX = -(anchorPoint.x - 0.5) * size.width - insetFrame.width / 2
        let offsetY = -(anchorPoint.y - 0.5) * size.height - inset / 2

        label.position = CGPoint(x: offsetX, y: offsetY)
        shadowLabel.position = CGPoint(x: offsetX + 2, y: offsetY - 2)
    }
}
