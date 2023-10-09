//
//  ShopViewCell.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 10/8/23.
//

import UIKit

class ShopViewCell: UICollectionViewCell {
    var item: ShopItem?
    
    var nameLabel: UILabel!
    var modelView: UIImageView!
    var costLabel: UILabel!
    
    private var nameLabelHeight: CGFloat { return frame.height * 2/10 }
    private var modelViewHeight: CGFloat { return frame.height * 5/10 }
    private var costLabelHeight: CGFloat { return frame.height * 3/10 }
    
    private var horizontalTextInset: CGFloat { return frame.width * 0.1 }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupNameLabel()
        setupModelView()
        setupCostLabel()
        
        backgroundColor = .orange
        layer.cornerRadius = frame.width / 10
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupNameLabel () {
        nameLabel = UILabel(frame: CGRect(x: horizontalTextInset, y: 0, width: frame.width - horizontalTextInset * 2, height: nameLabelHeight))
        nameLabel.text = "Object"
        nameLabel.font = UIFont(name: "ArialRoundedMTBold", size: nameLabel.frame.height / 2)
        nameLabel.textColor = .white
        nameLabel.shadowOffset = CGSize(width: nameLabel.font.pointSize * 0.05, height: nameLabel.font.pointSize * 0.05)
        nameLabel.shadowColor = .black
        nameLabel.adjustsFontSizeToFitWidth = true
        nameLabel.backgroundColor = .clear
        
        addSubview(nameLabel)
    }
    
    func setupModelView () {
        modelView = UIImageView(frame: CGRect(x: 0, y: nameLabel.frame.maxY, width: frame.width, height: frame.height - nameLabelHeight - costLabelHeight))
        
        addSubview(modelView)
    }
    
    func setupCostLabel () {
        costLabel = UILabel(frame: CGRect(x: horizontalTextInset, y: nameLabel.frame.maxY + modelViewHeight, width: frame.width - horizontalTextInset * 2, height: costLabelHeight))
        costLabel.text = "999999"
        costLabel.font = UIFont(name: "ArialRoundedMTBold", size: costLabel.frame.height/2)
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
        costLabel.text = ""
        
        if item.cost.honey != 0 {
            costLabel.text?.append("\(Int(item.cost.honey))H\n")
        }
        if item.cost.pollen != 0 {
            costLabel.text?.append("\(Int(item.cost.pollen))P\n")
        }
        if item.cost.beeBread != 0 {
            costLabel.text?.append("\(Int(item.cost.beeBread))B\n")
        }
        
        if item.cost.honey == 0, item.cost.pollen == 0, item.cost.beeBread == 0 {
            costLabel.text = "FREE!\n"
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

