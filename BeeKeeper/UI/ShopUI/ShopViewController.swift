//
//  ShopViewController.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 2/21/24.
//

import UIKit

protocol ShopViewDelegate: AnyObject {
    func shop(_ shopView: ShopViewController, didSelectItem item: ShopItem)
    func shop(_ shopView: ShopViewController, canSelectItem item: ShopItem) -> Bool
    func shop(_ shopView: ShopViewController, itemsForSection section: ShopViewController.Section) -> [ShopItem]
}

class ShopViewController: UIViewController {
    enum Section {
        case structures, flowers, buy
    }
    weak var shopDelegate: ShopViewDelegate?
    
    private(set) var section: Section = .structures
    
    let frontTabImage = UIImage(named: "shop-tab-front")
    let backTabImage = UIImage(named: "shop-tab-back")
    
    let backButton: UIButton
    let background: UIImageView
    let collectionView: UICollectionView
    let bar: UIView
    
    let structuresTab: ShopTab
    let flowersTab: ShopTab
    
    init(frame: CGRect) {
        let inset = frame.height * 0.05
        let itemHeight = frame.height - inset * 2
        let itemWidth = itemHeight / 1.75
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 150, height: 200)
        layout.sectionInset = UIEdgeInsets(top: inset, left: inset, bottom: inset, right: itemWidth / 2)
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        layout.scrollDirection = .horizontal
        collectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
        collectionView.register(ShopViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.allowsSelection = true
        collectionView.backgroundColor = .clear
        
        background = UIImageView(frame: frame)
        background.image = UIImage(named: "background-hexagons")
        background.contentMode = .scaleAspectFill
        background.isUserInteractionEnabled = true
        
        let wood = UIImageView(frame: frame)
        wood.image = UIImage(named: "background-wood")
        wood.contentMode = .scaleAspectFill
        collectionView.backgroundView = wood
        
        backButton = UIButton(frame: CGRect(x: 25, y: 25, width: frame.height / 15, height: frame.height / 15))
        backButton.setImage(UIImage(named: "backButton"), for: .normal)
        backButton.isEnabled = true
        
        bar = UIView()
        bar.backgroundColor = .shopLightBrown
        
        structuresTab = ShopTab()
        structuresTab.foregroundColor = .shopMediumBrown
        
        flowersTab = ShopTab()
        flowersTab.foregroundColor = .shopMediumBrown
        flowersTab.setImage(UIImage(named: "shop-flowers"), for: .normal)
        flowersTab.setImage(UIImage(named: "shop-flowers"), for: .highlighted)
        
        super.init(nibName: nil, bundle: nil)
        collectionView.delegate = self
        collectionView.dataSource = self
        
        backButton.addAction { [weak self] in
            SFXManager.shared.playSound(.pop)
            self?.removeFromParent()
        }
        
        structuresTab.addAction { [weak self] in
            self?.changeSection(.structures)
        }
        
        flowersTab.addAction { [weak self] in
            self?.changeSection(.flowers)
        }
        
        changeSection(.structures)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        parent?.view.addSubview(view)
    }
    
    override func removeFromParent() {
        super.removeFromParent()
        view.removeFromSuperview()
    }
    
    func changeSection(_ newSection: Section) {
        func tabForSection(_ s: Section) -> ShopTab? {
            switch s {
            case .structures: return structuresTab
            case .flowers: return flowersTab
            case .buy: return structuresTab
            }
        }
        tabForSection(newSection)?.popAnimation()
        guard section != newSection else { return }
        tabForSection(section)?.foregroundColor = .shopMediumBrown
        tabForSection(newSection)?.foregroundColor = .shopLightBrown
        section = newSection
        collectionView.reloadData()
    }
    
    override func loadView() {
        super.loadView()
        view = background
        background.addSubview(collectionView)
        background.addSubview(backButton)
        background.addSubview(structuresTab)
        background.addSubview(flowersTab)
        background.addSubview(bar)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        bar.translatesAutoresizingMaskIntoConstraints = false
        structuresTab.translatesAutoresizingMaskIntoConstraints = false
        flowersTab.translatesAutoresizingMaskIntoConstraints = false
        
        background.addConstraints([
            collectionView.leftAnchor.constraint(equalTo: background.leftAnchor),
            collectionView.rightAnchor.constraint(equalTo: background.rightAnchor),
            collectionView.bottomAnchor.constraint(equalTo: background.bottomAnchor),
            collectionView.topAnchor.constraint(equalTo: bar.bottomAnchor, constant: -10),
            
            bar.leftAnchor.constraint(equalTo: background.leftAnchor, constant: -10),
            bar.rightAnchor.constraint(equalTo: background.rightAnchor, constant: 10),
            bar.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: backButton.frame.height),
            bar.heightAnchor.constraint(equalTo: background.heightAnchor, multiplier: 0.1),
            
            structuresTab.leftAnchor.constraint(equalTo: backButton.rightAnchor, constant: backButton.frame.width),
            structuresTab.topAnchor.constraint(equalTo: backButton.centerYAnchor),
            structuresTab.bottomAnchor.constraint(equalTo: bar.topAnchor, constant: 10),
            structuresTab.widthAnchor.constraint(equalTo: structuresTab.heightAnchor, multiplier: 2),
            
            flowersTab.leftAnchor.constraint(equalTo: structuresTab.rightAnchor),
            flowersTab.topAnchor.constraint(equalTo: backButton.centerYAnchor),
            flowersTab.bottomAnchor.constraint(equalTo: bar.topAnchor, constant: 10),
            flowersTab.widthAnchor.constraint(equalTo: flowersTab.heightAnchor, multiplier: 2),
        ])
    }
    
    func items() -> [ShopItem] {
        return shopDelegate?.shop(self, itemsForSection: section) ?? []
    }
}

extension ShopViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items().count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? ShopViewCell else {
            return UICollectionViewCell()
        }
        
        let item = items()[indexPath.row]
        cell.setItem(item)
        cell.backgroundColor = (shopDelegate?.shop(self, canSelectItem: item) ?? true) ? .orange : .gray
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.cellForItem(at: indexPath)?.popAnimation()
        let item = items()[indexPath.row]
        guard shopDelegate?.shop(self, canSelectItem: item) ?? true else { return }
        shopDelegate?.shop(self, didSelectItem: item)
    }
}
