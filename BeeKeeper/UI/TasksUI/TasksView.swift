//
//  TasksView.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 2/19/24.
//

import UIKit

class TasksView: UITableView {
    init(frame: CGRect) {
        super.init(frame: frame, style: .insetGrouped)
        backgroundColor = .orange
        layer.cornerRadius = 10
        layer.borderColor = UIColor.yellow.cgColor
        layer.borderWidth = 5
        register(TasksViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
