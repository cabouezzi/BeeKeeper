//
//  ShopViewCell.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 10/8/23.
//

import UIKit
import SceneKit
import SpriteKit

class ShopViewCell: UICollectionViewCell {
    var item: ShopItem?
    
    var nameLabel: UILabel!
    var modelView: SCNView!
    private(set) var model: SCNNode?
    var costLabel: UILabel!
    
    private var nameLabelHeight: CGFloat { return frame.height * 3 / 10 }
    private var costLabelHeight: CGFloat { return frame.height * 3 / 10 }
    
    private var inset: CGFloat { return 10 }
    
    private var scene: SCNScene = SCNScene(named: "ModelBase.scn")!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let background = UIView(frame: CGRect(origin: .zero, size: frame.size))
        background.frame.size.height *= 0.6
        background.backgroundColor = .white
        background.layer.cornerRadius = frame.width / 10
        background.layer.opacity = 0.1
        addSubview(background)
        
        setupModelView()
        setupNameLabel()
        setupCostLabel()
        
        backgroundColor = .orange
        layer.cornerRadius = frame.width / 10
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupNameLabel () {
        let frame = CGRect(x: 0, y: 0, width: frame.width, height: nameLabelHeight).insetBy(dx: inset, dy: inset)
        nameLabel = UILabel(frame: frame)
        nameLabel.text = "Object"
        nameLabel.font = UIFont(name: "ArialRoundedMTBold", size: UIFont.preferredFont(forTextStyle: .headline).pointSize)
        nameLabel.textColor = .white
        nameLabel.shadowOffset = CGSize(width: nameLabel.font.pointSize * 0.05, height: nameLabel.font.pointSize * 0.05)
        nameLabel.shadowColor = .black
        nameLabel.adjustsFontSizeToFitWidth = true
        nameLabel.numberOfLines = 1
        nameLabel.backgroundColor = .clear
        
        addSubview(nameLabel)
    }
    
    func setupModelView () {
        let frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        modelView = SCNView(frame: frame)
        modelView.scene = scene
        modelView.scene?.background.contents = UIColor.clear
        modelView.backgroundColor = .clear
        scene.rootNode.childNode(withName: "BeeReference", recursively: true)?.isHidden = true
        addSubview(modelView)
    }
    
    func setupCostLabel () {
        let frame = CGRect(x: 0, y: frame.height - costLabelHeight, width: frame.width, height: costLabelHeight).insetBy(dx: inset, dy: inset)
        costLabel = UILabel(frame: frame)
        costLabel.text = "999999"
        costLabel.font = UIFont(name: "ArialRoundedMTBold", size: UIFont.preferredFont(forTextStyle: .headline).pointSize)
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
    
    func setItem (_ item: ShopItem) {
        self.item = item
        
        nameLabel.text = item.name
        costLabel.attributedText = item.cost.attributedString(font: costLabel.font)
        model?.removeFromParentNode()
        
        let model = item.newProduct()
        model.pivot = SCNMatrix4MakeTranslation(0, 0, 0)
        let height = Float((model.boundingBox.max - model.boundingBox.min).y)
        let scale = min(6 / height, min(4 / Float(model.area.width), 4 / Float(model.area.height)))
        model.scale *= scale
        model.position = .zero
        scene.rootNode.addChildNode(model)
        self.model = model
        
        if item.cost.isEmpty() {
            costLabel.text = "FREE!"
        }
    }
}

extension ShopViewCell {
    func pop (completion: (() -> Void)?) {
        UIView.animate(withDuration: 0.075,
        animations: {
            self.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
        },
        completion: { _ in
            UIView.animate(withDuration: 0.075) {
                self.transform = CGAffineTransform.identity
                (completion ?? {})()
            }
        })
    }
}

