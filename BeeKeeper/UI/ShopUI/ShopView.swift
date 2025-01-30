//
//  ShopView.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 1/16/24.
//

import UIKit
import SpriteKit

protocol ShopViewDelegate: AnyObject {
    func shopView(_ shopView: ShopView, didSelectItem item: ShopItem)
    func shopView(_ shopView: ShopView, canSelectItem item: ShopItem) -> Bool
    func shopViewItems(_ shopView: ShopView) -> [ShopItem]
    func shopViewDidDismiss(_ shopView: ShopView)
}

class ShopView: SKView {
    private var collectionView: UICollectionView
    
    weak var shopDelegate: ShopViewDelegate?
    
    override init(frame: CGRect) {
        let verticalInset = frame.height * 0.05
        let itemHeight = frame.height - verticalInset * 2
        let itemWidth = itemHeight / 1.75
        let horizontalInset = itemWidth * 0.1
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 150, height: 200)
        layout.sectionInset = UIEdgeInsets(top: verticalInset, left: horizontalInset, bottom: verticalInset, right: itemWidth / 2)
        layout.minimumInteritemSpacing = horizontalInset
        layout.minimumLineSpacing = verticalInset
        layout.scrollDirection = .horizontal
        collectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
        
        super.init(frame: frame)
        
        presentScene(SKScene(size: frame.size))
        backgroundColor = .clear
        scene?.backgroundColor = .clear
        
        let backButton = UIButton(frame: CGRect(x: 25, y: 25, width: frame.height / 15, height: frame.height / 15))
        backButton.setImage(UIImage(named: "backButton"), for: .normal)
        backButton.addAction { [weak self] in
            SFXManager.shared.playSound(.pop)
            self?.dismiss()
        }
        addSubview(backButton)
        
        let height = max(self.frame.height / 3.5, 100)
        collectionView.frame = CGRect(x: 0, y: self.frame.maxY - height, width: frame.width, height: height)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(ShopViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.allowsSelection = true
        collectionView.backgroundColor = .brown.withAlphaComponent(0.8)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        
        addSubview(collectionView)
        bringSubviewToFront(collectionView)
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapGestureHandler)))
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func tapGestureHandler(_ gestureRecognizer: UITapGestureRecognizer) {
        gestureRecognizer.cancelsTouchesInView = false
        
        let point = gestureRecognizer.location(in: self)
        guard let converted = scene?.convertPoint(fromView: point) else { return }
        
        if let button = scene?.nodes(at: converted).compactMap({ $0 as? SKButton }).first {
            button.activate()
            return
        } else if !self.collectionView.frame.contains(point) {
            dismiss()
        }
    }
    
    private func dismiss() {
        shopDelegate?.shopViewDidDismiss(self)
    }
    
    func items() -> [ShopItem] {
        return shopDelegate?.shopViewItems(self) ?? []
    }
}

extension ShopView: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items().count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? ShopViewCell else {
            return UICollectionViewCell()
        }
        
        let item = items()[indexPath.row]
        cell.setItem(item)
        cell.backgroundColor = (shopDelegate?.shopView(self, canSelectItem: item) ?? true) ? .orange : .gray
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = items()[indexPath.row]
        guard shopDelegate?.shopView(self, canSelectItem: item) ?? true else { return }
        shopDelegate?.shopView(self, didSelectItem: item)
    }
}
