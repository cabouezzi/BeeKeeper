//
//  TasksViewController.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 2/19/24.
//

import UIKit

class TasksViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var tasksView: TasksView
    var background: UIView
    init(frame: CGRect) {
        var f = frame
        f.size.height = min(frame.size.height, 500)
        f.size.width = f.size.height * 1.25
        tasksView = TasksView(frame: f)
        background = UIView(frame: frame)
        background.backgroundColor = .black.withAlphaComponent(0.1)
        super.init(nibName: nil, bundle: nil)
        tasksView.delegate = self
        tasksView.dataSource = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        view = background
        background.addSubview(tasksView)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tasksView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapHandler)))
        background.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(removeFromParent)))
    }
    
    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        parent?.view.addSubview(view)
    }
    
    @objc override func removeFromParent() {
        super.removeFromParent()
        view.removeFromSuperview()
    }
    
    @objc func tapHandler() {
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.height / 2.5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? TasksViewCell else {
            return tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        }
        cell.button.backgroundColor = .red
        cell.backgroundColor = .systemBackground
        return cell
    }
}
