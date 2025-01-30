//
//  BeeListView.swift
//  BeeKeeper
//
//  Created by Chaniel Abou-Ezzi on 1/30/25.
//


import UIKit
import SceneKit

protocol BeeListViewDelegate: AnyObject {
    func beeListView(_ beeListView: BeeListView, didSelectBee bee: Bee)
    func beeListViewDidDismiss(_ beeListView: BeeListView)
}

class BeeListView: UIView, UITableViewDelegate, UITableViewDataSource {
    weak var beeListViewDelegate: BeeListViewDelegate?
    
    let bees: [Bee]
    let beeListView: UITableView
    let releaseButton: UIButton
    
    private var onSelect: ((Bee) -> Void)?
    /// The block called to release bees in to the wild.
    private var onRelease: (() -> Void)?
    
    init(frame: CGRect, bees: [Bee]) {
        self.bees = bees
        beeListView = UITableView(frame: frame, style: .plain)
        beeListView.register(BeeListViewCell.self, forCellReuseIdentifier: "cell")
        beeListView.backgroundColor = .brown.withAlphaComponent(0.8)
        
        releaseButton = UIButton()
        releaseButton.isHidden = bees.isEmpty
        releaseButton.backgroundColor = .red
        releaseButton.layer.cornerRadius = 10
        releaseButton.setTitle("Release Bees", for: .normal)
        super.init(frame: frame)
        beeListView.delegate = self
        beeListView.dataSource = self
        
        releaseButton.addAction { [weak self] in
            self?.onRelease?()
        }
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapGestureHandler)))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundColor = .clear
        addSubview(beeListView)
        addSubview(releaseButton)
        
        beeListView.translatesAutoresizingMaskIntoConstraints = false
        releaseButton.translatesAutoresizingMaskIntoConstraints = false
        
        addConstraints([
            beeListView.topAnchor.constraint(equalTo: topAnchor),
            beeListView.bottomAnchor.constraint(equalTo: bottomAnchor),
            beeListView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.25),
            beeListView.rightAnchor.constraint(equalTo: rightAnchor),
            
            releaseButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            releaseButton.leftAnchor.constraint(equalTo: beeListView.leftAnchor, constant: 10),
            releaseButton.rightAnchor.constraint(equalTo: beeListView.safeAreaLayoutGuide.rightAnchor, constant: -10),
            releaseButton.heightAnchor.constraint(equalToConstant: 100),
        ])
    }
    
    @objc private func tapGestureHandler(_ gestureRecognizer: UITapGestureRecognizer) {
        gestureRecognizer.cancelsTouchesInView = false
        
        let point = gestureRecognizer.location(in: self)
        if !self.beeListView.frame.contains(point) {
            dismiss()
        }
    }
    
    private func dismiss() {
        beeListViewDelegate?.beeListViewDidDismiss(self)
    }
    
    // MARK: - Callbacks
    
    func onSelect(_ block: @escaping (Bee) -> Void) {
        self.onSelect = block
    }
    
    func onRelease(_ block: @escaping () -> Void) {
        self.onRelease = block
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
        tableView.cellForRow(at: indexPath)?.popAnimation()
        return indexPath
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let bee = bees[indexPath.row]
        beeListViewDelegate?.beeListView(self, didSelectBee: bee)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}
