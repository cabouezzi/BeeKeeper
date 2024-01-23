//
//  BeeListView.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 1/22/24.
//

import UIKit

// TODO: Not a fan of the concept
class BeeListView: UIView {
    let tableView: UITableView
    let bees: [Bee]
    
    private var block: ((Bee) -> Void)?
    private let buttonHeight: CGFloat = 100
    
    init(bees: [Bee], frame: CGRect) {
        self.bees = bees
        
        tableView = UITableView(frame: frame)
        tableView.contentSize.width = frame.width
        tableView.contentSize.height = buttonHeight * CGFloat(bees.count)
        tableView.backgroundColor = .clear
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        super.init(frame: frame)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isUserInteractionEnabled = true
        tableView.bounds = tableView.frame.insetBy(dx: 10.0, dy: 10.0)
        addSubview(tableView)
        
        backgroundColor = UIColor(white: 1, alpha: 0.3)
        layer.cornerRadius = 10
        layer.borderColor = CGColor(red: 1, green: 1, blue: 1, alpha: 1)
        layer.borderWidth = 5
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func onSelect(_ block: @escaping (Bee) -> Void) {
        self.block = block
    }
}

extension BeeListView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        block?(bees[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bees.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell") else {
            return UITableViewCell()
        }
        let bee = bees[indexPath.row]
        let label = UILabel(frame: cell.frame)
        label.text = bee.nickname.prefix(12) + " \(bee.production)"
        label.bounds = label.frame.insetBy(dx: 10.0, dy: 0)
        cell.contentView.addSubview(label)
        cell.layer.cornerRadius = 10
        cell.backgroundColor = .orange
        return cell
    }
}
