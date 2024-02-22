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
    func shopView(_ shopView: ShopView, itemsForSection section: ShopView.Section) -> [ShopItem]
}

class ShopView: UIView {
    enum Section: Int {
        case structures, flowers, buy
        
        var symbol: SKSpriteNode? {
            switch self {
            case .structures: return nil
            case .flowers: return SKSpriteNode(texture: SKTexture.shopSymbolFlower)
            case .buy: return nil
            }
        }
    }
    
    private(set) var section: Section = .structures
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
        
        let backButton = UIButton(frame: CGRect(x: 25, y: 25, width: frame.height / 15, height: frame.height / 15))
        backButton.setImage(UIImage(named: "backButton"), for: .normal)
        backButton.addAction { [weak self] in
            SFXManager.shared.playSound(.pop)
            self?.removeFromSuperview()
        }
        addSubview(backButton)
        
        collectionView.frame = frame
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(ShopViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.allowsSelection = true
        collectionView.backgroundColor = .clear
        
        addSubview(collectionView)
        bringSubviewToFront(collectionView)
        backgroundColor = .clear
        
        changeSection(.structures)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func items() -> [ShopItem] {
        return shopDelegate?.shopView(self, itemsForSection: section) ?? []
    }
    
    func changeSection(_ section: Section) {
        self.section = section
        collectionView.reloadData()
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
