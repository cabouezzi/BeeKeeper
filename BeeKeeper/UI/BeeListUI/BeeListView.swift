//
//  BeeListView.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 1/22/24.
//

import UIKit
import SceneKit

class BeeListView: UIView {
    let beeView: SCNView
    let releaseButton: UIButton
    let scrollView: UIScrollView
    let bees: [Bee]
    
    private var selectedBee: Bee?
    private var beeModel: Bee?
    private var beeReference: SCNNode?
    private var onSelect: ((Bee) -> Void)?
    /// The block called to release bees in to the wild.
    private var onRelease: (() -> Void)?
    private let buttonHeight: CGFloat = 100
    
    init(bees: [Bee], frame: CGRect) {
        self.bees = bees
        
        beeView = SCNView(frame: frame)
        beeView.scene = SCNScene(named: "ModelBase.scn")
        beeView.scene?.background.contents = UIColor.brown
        beeView.frame.size.width *= 2 / 3
        
        beeReference = beeView.scene?.rootNode.childNode(withName: "BeeReference", recursively: true)
        beeReference?.isHidden = true
        
        releaseButton = UIButton(frame: frame)
        releaseButton.isHidden = true
        
        scrollView = UIScrollView(frame: frame)
        scrollView.frame.size.width *= 1 / 3
        scrollView.frame.origin.x = beeView.frame.maxX
        scrollView.contentSize = scrollView.frame.size
        scrollView.contentSize.height = scrollView.frame.size.height + 10
        
        super.init(frame: frame)
        addSubview(beeView)
        
        releaseButton.backgroundColor = .red
        releaseButton.setTitle("Release Bees", for: .normal)
        releaseButton.addAction { [weak self] in
            self?.onRelease?()
        }
        scrollView.addSubview(releaseButton)
        
        scrollView.backgroundColor = .clear
        scrollView.alwaysBounceVertical = true
        scrollView.isDirectionalLockEnabled = true
        scrollView.canCancelContentTouches = true
        addSubview(scrollView)
        
        layoutBeeRows(bees)
        backgroundColor = .baige
        
        let backButton = UIButton(frame: CGRect(x: 25, y: 25, width: frame.height / 15, height: frame.height / 15))
        backButton.setImage(UIImage(named: "backButton"), for: .normal)
        backButton.addAction { [weak self] in
            self?.removeFromSuperview()
        }
        addSubview(backButton)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func layoutBeeRows(_ bees: [Bee]) {
        for view in subviews where view is BeeListViewCell {
            view.removeFromSuperview()
        }
        
        let rowSize = 100
        scrollView.contentSize.height = max(scrollView.frame.size.height + 10, CGFloat(bees.count * rowSize))
        
        let itemHeight: CGFloat = 100
        let itemWidth: CGFloat = scrollView.frame.width
        let inset: CGFloat = 10
        
        let releaseFrame = CGRect(x: 0, y: 0, width: itemWidth, height: itemHeight).insetBy(dx: 10, dy: 10)
        releaseButton.frame = releaseFrame
        releaseButton.layer.cornerRadius = releaseFrame.height / 10
        releaseButton.isHidden = bees.isEmpty
        
        for (index, bee) in bees.enumerated() {
            let offset = releaseButton.frame.maxY + releaseButton.frame.height / 2 + itemHeight * CGFloat(index)
            let frame = CGRect(x: 0, y: offset, width: itemWidth, height: itemHeight).insetBy(dx: inset, dy: inset)
            
            let row = BeeListViewCell(frame: frame)
            row.setBee(bee)
            row.button.addAction { [weak self] in
                self?.onSelect?(bee)
            }
            row.addAction { [weak self] in
                self?.selectBee(bee)
                UIView.animate(withDuration: 0.1, animations: {
                    row.transform = CGAffineTransform(scaleX: 0.95, y: 1)
                }) { _ in
                    UIView.animate(withDuration: 0.1) {
                        row.transform = .identity
                    }
                }
            }
            scrollView.addSubview(row)
        }
        
        if let first = bees.first {
            selectBee(first)
        }
    }
    
    func selectBee(_ bee: Bee) {
        selectedBee = bee
        setBeeModel(bee)
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
    
    func onSelect(_ block: @escaping (Bee) -> Void) {
        self.onSelect = block
    }
    
    func onRelease(_ block: @escaping () -> Void) {
        self.onRelease = block
    }
}
