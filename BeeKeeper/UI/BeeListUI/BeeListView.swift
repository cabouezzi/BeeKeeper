//
//  BeeListView.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 1/22/24.
//

import UIKit
import SceneKit

fileprivate class CancelingScrollView: UIScrollView {
    override func touchesShouldCancel(in view: UIView) -> Bool {
        return true
    }
}

class BeeListView: UIView {
    let beeView: SCNView
    let releaseButton: UIButton
    let scrollView: UIScrollView
    let bees: [Bee]
    
    private var selectedCell: BeeListViewCell?
    private var beeModel: Bee?
    private var beeReference: SCNNode?
    private var onSelect: ((Bee) -> Void)?
    /// The block called to release bees in to the wild.
    private var onRelease: (() -> Void)?
    private let buttonHeight: CGFloat = 100
    
    init(bees: [Bee], frame: CGRect) {
        self.bees = bees
        
        let scrollViewFraction = 0.5
        beeView = SCNView(frame: frame)
        beeView.scene = SCNScene(named: "ModelBase.scn")
        beeView.scene?.background.contents = UIColor.brown
        beeView.frame.size.width *= 1 - scrollViewFraction
        
        beeReference = beeView.scene?.rootNode.childNode(withName: "BeeReference", recursively: true)
        beeReference?.isHidden = true
        
        releaseButton = UIButton(frame: frame)
        releaseButton.isHidden = true
        
        scrollView = CancelingScrollView(frame: frame)
        scrollView.frame.size.width *= scrollViewFraction
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
            SFXManager.shared.playSound(.pop)
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
        
        let inset: CGFloat = 10
        let rowSize: CGFloat = 100
        scrollView.contentSize.height = max(scrollView.frame.size.height + 10, CGFloat(bees.count) * rowSize + releaseButton.frame.height)
        
        let itemHeight: CGFloat = rowSize
        let itemWidth: CGFloat = scrollView.frame.width
        
        let releaseFrame = CGRect(x: 0, y: 0, width: itemWidth, height: itemHeight).insetBy(dx: inset, dy: inset)
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
        guard let cell = scrollView.subviews.compactMap({ $0 as? BeeListViewCell }).first(where: { $0.bee == bee }) else {
            return
        }
        selectedCell?.layer.borderColor = UIColor.clear.cgColor
        selectedCell = cell
        selectedCell?.layer.borderColor = UIColor.white.cgColor
        selectedCell?.layer.borderWidth = 2
        setBeeModel(cell.bee)
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
