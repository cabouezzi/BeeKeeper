//
//  BeeListViewCell.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 1/24/24.
//

import UIKit

class BeeListViewCell: UIControl {
    var bee: Bee?
    
    var nameLabel: UILabel!
    var productionLabel: UILabel!
    
    var button: UIButton!
    var renameButton: UIButton!
    
    private var nameLabelHeight: CGFloat { return frame.height * 3/10 }
    private var productionLabelHeight: CGFloat { return frame.height * 7/10 }
    
    private var horizontalTextInset: CGFloat { return 10 }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
        setupNameLabel()
        setupCostLabel()
        // setupRenameButton()
        
        backgroundColor = .orange
        layer.cornerRadius = 10
        isExclusiveTouch = true
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
        productionLabel.attributedText = bee.production.attributedString(font: productionLabel.font, verbose: true)
    }
    
    func setupNameLabel () {
        let frame = CGRect(x: 0, y: 0, width: frame.width - button.frame.size.width, height: nameLabelHeight).insetBy(dx: horizontalTextInset, dy: 0)
        nameLabel = UILabel(frame: frame)
        nameLabel.text = "Object"
        nameLabel.font = UIFont(name: "ArialRoundedMTBold", size: UIFont.systemFontSize)
        nameLabel.textColor = .white
        nameLabel.shadowOffset = CGSize(width: nameLabel.font.pointSize * 0.05, height: nameLabel.font.pointSize * 0.05)
        nameLabel.shadowColor = .black
        nameLabel.adjustsFontSizeToFitWidth = true
        nameLabel.numberOfLines = 1
        nameLabel.backgroundColor = .clear
        addSubview(nameLabel)
    }
    
    func setupCostLabel () {
        let frame = CGRect(x: 0, y: nameLabel.frame.maxY, width: frame.width - button.frame.size.width, height: productionLabelHeight).insetBy(dx: horizontalTextInset, dy: 0)
        productionLabel = UILabel(frame: frame)
        productionLabel.text = "999999"
        productionLabel.font = UIFont(name: "ArialRoundedMTBold", size: UIFont.systemFontSize * 1.5)
        productionLabel.textColor = .white
        productionLabel.textAlignment = .left
        productionLabel.shadowOffset = CGSize(width: productionLabel.font.pointSize * 0.05, height: productionLabel.font.pointSize * 0.05)
        productionLabel.shadowColor = .black
        productionLabel.adjustsFontSizeToFitWidth = true
        productionLabel.numberOfLines = 1
        productionLabel.lineBreakMode = .byClipping
        productionLabel.backgroundColor = .clear
        addSubview(productionLabel)
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
