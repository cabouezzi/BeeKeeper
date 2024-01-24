//
//  BeeListView.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 1/22/24.
//

import UIKit
import SceneKit

class BeeListView: UIView {
    let beeView: SCNView
    let scrollView: UIScrollView
    let bees: [Bee]
    
    private var selectedBee: Bee?
    private var beeModel: Bee?
    private var beeReference: SCNNode?
    private var block: ((Bee) -> Void)?
    private let buttonHeight: CGFloat = 100
    
    init(bees: [Bee], frame: CGRect) {
        self.bees = bees
        
        beeView = SCNView(frame: frame)
        beeView.scene = SCNScene(named: "ModelBase.scn")
        beeView.frame.size.width *= 2 / 3
        
        beeReference = beeView.scene?.rootNode.childNode(withName: "BeeReference", recursively: true)
        beeReference?.isHidden = true
        
        let rowSize = 100
        scrollView = UIScrollView(frame: frame)
        scrollView.frame.size.width *= 1 / 3
        scrollView.frame.origin.x = beeView.frame.maxX
        scrollView.contentSize = scrollView.frame.size
        scrollView.contentSize.height = max(scrollView.frame.size.height + 10, CGFloat(bees.count * rowSize))
        
        super.init(frame: frame)
        addSubview(beeView)
        
        scrollView.backgroundColor = .clear
        scrollView.alwaysBounceVertical = true
        scrollView.isDirectionalLockEnabled = true
        addSubview(scrollView)
        
        let itemHeight: CGFloat = 100
        let itemWidth: CGFloat = scrollView.frame.width
        let inset: CGFloat = 10
        
        for (index, bee) in bees.enumerated() {
            let offset = itemHeight * CGFloat(index)
            let frame = CGRect(x: 0, y: offset, width: itemWidth, height: itemHeight).insetBy(dx: inset, dy: inset)
            let row = BeeListViewCell(frame: frame)
            row.nameLabel.text = bee.nickname
            row.costLabel.text = bee.production.description
            row.button.addAction { [weak self] in
                self?.block?(bee)
            }
            row.addAction { [weak self] in
                self?.selectBee(bee)
                UIView.animate(withDuration: 0.1, animations: {
                    row.transform = CGAffineTransform(scaleX: 0.95, y: 1)
                }) { _ in
                    UIView.animate(withDuration: 0.1) {
                        row.transform = .identity
                    }
                }
            }
            scrollView.addSubview(row)
        }
        
        backgroundColor = .baige
        
        let backButton = UIButton(frame: CGRect(x: 25, y: 25, width: frame.height / 15, height: frame.height / 15))
        backButton.setImage(UIImage(named: "backButton"), for: .normal)
        backButton.addAction { [weak self] in
            self?.removeFromSuperview()
        }
        addSubview(backButton)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func selectBee(_ bee: Bee) {
        selectedBee = bee
        setBeeModel(bee)
    }
    
    private func setBeeModel(_ bee: Bee?) {
        beeModel?.removeFromParentNode()
        beeModel = nil
        guard let bee = bee, let reference = beeReference else { return }
        let model = Bee(bee.genetics)
        let armature = model.childNodes.first ?? model
        armature.position = reference.position
        armature.scale = reference.scale
        armature.eulerAngles = reference.eulerAngles
        model.flapWings(repeatCount: .max).play()
        beeView.scene?.rootNode.addChildNode(model)
        beeModel = model
    }
    
    func onSelect(_ block: @escaping (Bee) -> Void) {
        self.block = block
    }
}

class BeeListViewCell: UIControl {
    var bee: Bee?
    
    var nameLabel: UILabel!
    var costLabel: UILabel!
    
    var button: UIButton!
    var renameButton: UIButton!
    
    private var nameLabelHeight: CGFloat { return frame.height * 3/10 }
    private var costLabelHeight: CGFloat { return frame.height * 7/10 }
    
    private var horizontalTextInset: CGFloat { return 10 }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupNameLabel()
        setupCostLabel()
        setupButton()
        setupRenameButton()
        
        backgroundColor = .orange
        layer.cornerRadius = 10
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return !(gestureRecognizer is UITapGestureRecognizer)
    }
    
    func setBee(_ bee: Bee) {
        self.bee = bee
        nameLabel.text = bee.nickname
        costLabel.text = bee.production.description
    }
    
    func setupNameLabel () {
        nameLabel = UILabel(frame: CGRect(x: horizontalTextInset, y: 0, width: frame.width - horizontalTextInset * 2, height: nameLabelHeight))
        nameLabel.text = "Object"
        nameLabel.font = UIFont(name: "ArialRoundedMTBold", size: UIFont.systemFontSize)
        nameLabel.textColor = .white
        nameLabel.shadowOffset = CGSize(width: nameLabel.font.pointSize * 0.05, height: nameLabel.font.pointSize * 0.05)
        nameLabel.shadowColor = .black
        nameLabel.adjustsFontSizeToFitWidth = true
        nameLabel.backgroundColor = .clear
        addSubview(nameLabel)
    }
    
    func setupCostLabel () {
        costLabel = UILabel(frame: CGRect(x: horizontalTextInset, y: nameLabel.frame.maxY, width: frame.width - horizontalTextInset * 2, height: costLabelHeight))
        costLabel.text = "999999"
        costLabel.font = UIFont(name: "ArialRoundedMTBold", size: UIFont.systemFontSize)
        costLabel.textColor = .white
        costLabel.textAlignment = .left
        costLabel.shadowOffset = CGSize(width: costLabel.font.pointSize * 0.05, height: costLabel.font.pointSize * 0.05)
        costLabel.shadowColor = .black
        costLabel.adjustsFontSizeToFitWidth = true
        costLabel.numberOfLines = 4
        costLabel.lineBreakMode = .byClipping
        costLabel.backgroundColor = .clear
        addSubview(costLabel)
    }
    
    func setupButton() {
        var frame = CGRect(x: frame.width, y: 0, width: frame.height, height: frame.height)
        frame.origin.x -= frame.size.width
        frame = frame.insetBy(dx: 10, dy: 10)
        button = UIButton(frame: frame)
        button.backgroundColor = .clear
        button.setImage(UIImage(named: "editButton"), for: .normal)
        addSubview(button)
    }
    
    func setupRenameButton() {
        var frame = CGRect(x: button.frame.origin.x, y: 0, width: frame.height, height: frame.height)
        frame.origin.x -= frame.size.width
        frame = frame.insetBy(dx: 10, dy: 10)
        renameButton = UIButton(frame: frame)
        renameButton.backgroundColor = .blue
        addSubview(renameButton)
    }
}
