//
//  TasksViewCell.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 2/19/24.
//

import UIKit

class TasksViewCell: UITableViewCell {
    let titleLabel = UILabel()
    let bodyLabel = UILabel()
    let button = UIButton()
    
    private let inset: CGFloat = 10
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.numberOfLines = 1
        titleLabel.font = .preferredFont(forTextStyle: .largeTitle)
        titleLabel.textColor = .white
        titleLabel.setShadow()
        
        bodyLabel.translatesAutoresizingMaskIntoConstraints = false
        bodyLabel.numberOfLines = 0
        bodyLabel.font = .preferredFont(forTextStyle: .body)
        bodyLabel.textColor = .white
        bodyLabel.setShadow()
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 10
        contentView.addSubview(titleLabel)
        contentView.addSubview(bodyLabel)
        contentView.addSubview(button)
        
        addConstraints([
            titleLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: inset),
            titleLabel.rightAnchor.constraint(lessThanOrEqualTo: button.leftAnchor, constant: -inset),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: inset),
            titleLabel.bottomAnchor.constraint(lessThanOrEqualTo: bodyLabel.topAnchor),
            
            bodyLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: inset),
            bodyLabel.rightAnchor.constraint(lessThanOrEqualTo: button.leftAnchor, constant: -inset),
            bodyLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 0),
            bodyLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -inset),
            
            button.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -inset),
            button.topAnchor.constraint(equalTo: contentView.topAnchor, constant: inset),
            button.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -inset),
            button.widthAnchor.constraint(equalTo: button.heightAnchor, multiplier: 1),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.insetBy(dx: 10, dy: 5)
    }
}
