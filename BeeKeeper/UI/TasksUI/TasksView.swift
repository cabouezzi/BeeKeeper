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
        backgroundColor = .lightGray.withAlphaComponent(0.9)
        layer.cornerRadius = 10
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
