//
//  BeeListViewController.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 2/19/24.
//

import UIKit
import SceneKit

class BeeListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    let background: UIView
    let bees: [Bee]
    let beeView: SCNView
    let beeListView: UITableView
    let releaseButton: UIButton
    
    private var beeModel: Bee?
    private var beeReference: SCNNode?
    
    private var onSelect: ((Bee) -> Void)?
    /// The block called to release bees in to the wild.
    private var onRelease: (() -> Void)?
    
    init(frame: CGRect, bees: [Bee]) {
        self.bees = bees
        background = UIView(frame: frame)
        
        beeView = SCNView(frame: frame)
        beeView.scene = SCNScene(named: "ModelBase.scn")
        beeView.scene?.background.contents = UIColor.brown
        beeReference = beeView.scene?.rootNode.childNode(withName: "BeeReference", recursively: true)
        beeReference?.isHidden = true
        
        beeListView = UITableView(frame: frame, style: .plain)
        beeListView.register(BeeListViewCell.self, forCellReuseIdentifier: "cell")
        beeListView.backgroundColor = .clear
        
        releaseButton = UIButton()
        releaseButton.isHidden = bees.isEmpty
        releaseButton.backgroundColor = .red
        releaseButton.layer.cornerRadius = 10
        releaseButton.setTitle("Release Bees", for: .normal)
        super.init(nibName: nil, bundle: nil)
        beeListView.delegate = self
        beeListView.dataSource = self
        
        releaseButton.addAction { [weak self] in
            self?.onRelease?()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        view = background
        background.backgroundColor = .baige
        background.addSubview(beeView)
        background.addSubview(beeListView)
        background.addSubview(releaseButton)
        
        let backButton = UIButton(frame: CGRect(x: 25, y: 25, width: background.frame.height / 15, height: background.frame.height / 15))
        backButton.setImage(UIImage(named: "backButton"), for: .normal)
        backButton.addAction { [weak self] in
            SFXManager.shared.playSound(.pop)
            self?.removeFromParent()
        }
        background.addSubview(backButton)
        
        beeView.translatesAutoresizingMaskIntoConstraints = false
        beeListView.translatesAutoresizingMaskIntoConstraints = false
        releaseButton.translatesAutoresizingMaskIntoConstraints = false
        
        background.addConstraints([
            beeView.topAnchor.constraint(equalTo: background.topAnchor),
            beeView.bottomAnchor.constraint(equalTo: background.bottomAnchor),
            beeView.leftAnchor.constraint(equalTo: background.leftAnchor),
            beeView.widthAnchor.constraint(equalTo: background.widthAnchor, multiplier: 0.6),
            
            beeListView.topAnchor.constraint(equalTo: background.topAnchor),
            beeListView.bottomAnchor.constraint(equalTo: releaseButton.topAnchor, constant: -10),
            beeListView.leftAnchor.constraint(equalTo: beeView.rightAnchor),
            beeListView.rightAnchor.constraint(equalTo: background.rightAnchor),
            
            releaseButton.bottomAnchor.constraint(equalTo: background.bottomAnchor, constant: -10),
            releaseButton.leftAnchor.constraint(equalTo: beeListView.leftAnchor, constant: 10),
            releaseButton.rightAnchor.constraint(equalTo: beeListView.rightAnchor, constant: -10),
            releaseButton.heightAnchor.constraint(equalToConstant: 100),
        ])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let first = bees.first {
            selectBee(first)
        }
    }
    
    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        parent?.view.addSubview(view)
    }
    
    override func removeFromParent() {
        super.removeFromParent()
        view.removeFromSuperview()
    }
    
    // MARK: - Callbacks
    
    func onSelect(_ block: @escaping (Bee) -> Void) {
        self.onSelect = block
    }
    
    func onRelease(_ block: @escaping () -> Void) {
        self.onRelease = block
    }
    
    func selectBee(_ bee: Bee) {
        guard let index = bees.firstIndex(of: bee) else { return }
        tableView(beeListView, didSelectRowAt: IndexPath(row: index, section: 0))
    }
    
    private func setBeeModel(_ bee: Bee?) {
        beeModel?.removeFromParentNode()
        beeModel = nil
        guard let bee = bee, let reference = beeReference else { return }
        let model = Bee(bee.genetics)
        let armature = model.childNodes.first ?? model
        armature.position = reference.position
        armature.scale = reference.scale
        armature.eulerAngles = reference.eulerAngles
        model.flapWings(repeatCount: .max).play()
        beeView.scene?.rootNode.addChildNode(model)
        beeModel = model
    }
    
    // MARK: - TableView Functions
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bees.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dq = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        guard let cell = dq as? BeeListViewCell else { return dq }
        let bee = bees[indexPath.row]
        cell.setBee(bee)
        cell.selectionStyle = .none
        cell.button.addAction { [weak self] in
            self?.onSelect?(bee)
        }
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        SFXManager.shared.playSound(.pop)
        return indexPath
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.popAnimation()
        setBeeModel(bees[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}
