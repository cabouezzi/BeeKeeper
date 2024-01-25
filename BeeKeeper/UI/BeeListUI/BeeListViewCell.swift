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
