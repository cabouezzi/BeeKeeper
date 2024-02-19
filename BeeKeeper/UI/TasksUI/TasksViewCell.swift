//
//  TasksViewCell.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 2/19/24.
//

import UIKit

class TasksViewCell: UITableViewCell {
    let button = UIButton()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 10
        contentView.addSubview(button)
        
        addConstraints([
            button.rightAnchor.constraint(equalTo: rightAnchor, constant: -5),
            button.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            button.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5),
            button.widthAnchor.constraint(equalTo: button.heightAnchor, multiplier: 1),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
