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

class ShopView: SKView {
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
    
    private lazy var structuresTab = SKSpriteNode(texture: SKTexture.shopTabFront)
    private lazy var flowersTab = SKSpriteNode(texture: SKTexture.shopTabFront)
    private lazy var buyTab = SKSpriteNode(texture: SKTexture.shopTabFront)
    private lazy var bar = SKSpriteNode(texture: SKTexture.shopBar)
    
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
        
        let resources = ResourceDisplayHud()
        scene?.addChild(resources)
        resources.layout()
        resources.update(animated: false)
        resources.zPosition = 3
        
        let height = frame.height / 10
        bar.anchorPoint = CGPoint(x: 0, y: 0)
        bar.position.x = 0
        bar.position.y = frame.height - height * 3
        bar.size.width = frame.width
        bar.size.height = height
        scene?.addChild(bar)
        
        let backButton = UIButton(frame: CGRect(x: 25, y: 25, width: frame.height / 15, height: frame.height / 15))
        backButton.setImage(UIImage(named: "backButton"), for: .normal)
        backButton.addAction { [weak self] in
            SFXManager.shared.playSound(.pop)
            self?.removeFromSuperview()
        }
        addSubview(backButton)
        
        collectionView.frame = CGRect(x: 0, y: height * 3, width: frame.width, height: frame.height - height * 3)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(ShopViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.allowsSelection = true
        collectionView.backgroundColor = .clear
        
        for (index, tab) in [structuresTab, flowersTab, buyTab].enumerated() {
            let background = SKButton(texture: SKTexture.shopTabBack, size: CGSize(width: height * 2, height: height))
            background.anchorPoint = CGPoint(x: 0.5, y: 0)
            background.position.x = CGFloat(index + 1) * height * 2
            background.position.y = frame.height - height * 2
            background.zPosition = 0
            background.onTap {
                guard let section = Section(rawValue: index) else { return }
                self.changeSection(section)
            }
            scene?.addChild(background)
            
            tab.anchorPoint = background.anchorPoint
            tab.size = background.size
            tab.position = background.position
            tab.isHidden = true
            tab.zPosition = 1
            scene?.addChild(tab)
            
            guard let symbol = Section(rawValue: index)?.symbol else { continue }
            symbol.scale(to: CGSize(width: height * 0.75, height: height * 0.75))
            symbol.position = background.position
            symbol.position.y += background.size.height / 2
            symbol.zPosition = 2
            scene?.addChild(symbol)
        }
        
        addSubview(collectionView)
        bringSubviewToFront(collectionView)
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapGestureHandler)))
        
        scene?.backgroundColor = .brown
        backgroundColor = .clear
        
        changeSection(.structures)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func tapGestureHandler(_ gestureRecognizer: UITapGestureRecognizer) {
        gestureRecognizer.cancelsTouchesInView = false
        
        let point = gestureRecognizer.location(in: self)
        guard let converted = scene?.convertPoint(fromView: point) else { return }
        guard let button = scene?.nodes(at: converted).compactMap({ $0 as? SKButton }).first else { return }
        button.activate()
    }
    
    func items() -> [ShopItem] {
        return shopDelegate?.shopView(self, itemsForSection: section) ?? []
    }
    
    private func tabForSection(_ section: Section) -> SKSpriteNode {
        switch section {
        case .structures: return structuresTab
        case .flowers: return flowersTab
        case .buy: return buyTab
        }
    }
    
    func changeSection(_ section: Section) {
        tabForSection(self.section).isHidden = true
        tabForSection(section).isHidden = false
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
