//
//  BeeListViewCell.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 1/24/24.
//

import UIKit

class BeeListViewCell: UITableViewCell {
    var bee: Bee?
    
    var nameLabel: UILabel!
    var productionLabel: UILabel!
    var button: UIButton!
    
    private var horizontalTextInset: CGFloat { return 10 }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupButton()
        setupNameLabel()
        setProductionLabel()
        // setupRenameButton()
        
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        productionLabel.translatesAutoresizingMaskIntoConstraints = false
        button.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(nameLabel)
        contentView.addSubview(productionLabel)
        contentView.addSubview(button)
        
        addConstraints([
            nameLabel.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.3),
            nameLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: horizontalTextInset),
            nameLabel.rightAnchor.constraint(equalTo: button.leftAnchor),
            
            productionLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor),
            productionLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: horizontalTextInset),
            productionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            productionLabel.rightAnchor.constraint(equalTo: button.leftAnchor),
            
            button.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            button.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            button.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -10),
            button.widthAnchor.constraint(equalTo: button.heightAnchor),
        ])
        
        backgroundColor = .clear
        contentView.backgroundColor = .orange
        contentView.layer.cornerRadius = 10
        isExclusiveTouch = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.insetBy(dx: 10, dy: 5)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        contentView.layer.borderColor = selected ? UIColor.yellow.cgColor : UIColor.clear.cgColor
        contentView.layer.borderWidth = 2
    }
    
    func setBee(_ bee: Bee) {
        self.bee = bee
        nameLabel.text = bee.nickname
        productionLabel.attributedText = bee.production.attributedString(font: productionLabel.font, verbose: true)
    }
    
    func setupNameLabel () {
        nameLabel = UILabel()
        nameLabel.text = "Object"
        nameLabel.font = UIFont(name: "ArialRoundedMTBold", size: UIFont.systemFontSize)
        nameLabel.textColor = .white
        nameLabel.setShadow()
        nameLabel.adjustsFontSizeToFitWidth = true
        nameLabel.numberOfLines = 1
        nameLabel.backgroundColor = .clear
    }
    
    func setProductionLabel () {
        productionLabel = UILabel()
        productionLabel.text = "999999"
        productionLabel.font = UIFont(name: "ArialRoundedMTBold", size: UIFont.systemFontSize * 1.5)
        productionLabel.textColor = .white
        productionLabel.setShadow()
        productionLabel.adjustsFontSizeToFitWidth = true
        productionLabel.numberOfLines = 0
        productionLabel.lineBreakMode = .byClipping
        productionLabel.backgroundColor = .clear
    }
    
    func setupButton() {
        button = UIButton()
        button.backgroundColor = .clear
        button.setImage(UIImage(named: "editButton"), for: .normal)
    }
}
