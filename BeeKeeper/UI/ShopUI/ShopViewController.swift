//
//  ShopViewController.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 10/8/23.
//

import UIKit

protocol ShopDelegate: AnyObject {
    func shopViewController(_ shopViewController: ShopViewController, canSelectItem item: ShopItem) -> Bool
    func shopViewController(_ shopViewController: ShopViewController, didSelectItem item: ShopItem)
}

// TODO: Make ShopView, and use under GameViewController
class ShopViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    weak var delegate: ShopDelegate?
    
    let items: [ShopItem] = [
        ShopItem(name: "Hive", description: nil, cost: Resources(), display: UIImage(named: "world.png")!, newProduct: { Hive() }),
        ShopItem(name: "Incubator", description: nil, cost: Resources(honey: 10), display: UIImage(named: "world"), newProduct: { Incubator() }),
        ShopItem(name: "Honey Jar Rack", description: nil, cost: Resources(honey: 100), display: UIImage(named: "world"), newProduct: { HoneyStorage() }),
        ShopItem(name: "Pollen Jar Rack", description: nil, cost: Resources(honey: 100), display: UIImage(named: "world"), newProduct: { PollenStorage() }),
    ]
    
    var collectionView: UICollectionView?
    
    convenience init() {
        self.init(frame: .zero)
    }
    
    init(frame: CGRect) {
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
        collectionView?.register(ShopViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionView?.allowsSelection = true
        super.init(nibName: nil, bundle: nil)
        
        collectionView?.delegate = self
        collectionView?.dataSource = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        self.view = collectionView
    }
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        super.dismiss(animated: false, completion: completion)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? ShopViewCell else {
            return UICollectionViewCell()
        }
        
        let item = items[indexPath.row]
        cell.setItem(item)
        
        if !(delegate?.shopViewController(self, canSelectItem: item) ?? true) {
            cell.backgroundColor = .gray
        } else {
            cell.backgroundColor = .orange
        }
        
        cell.nameLabel.text = item.name
        cell.modelView.image = item.display
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = items[indexPath.row]
        
        guard delegate?.shopViewController(self, canSelectItem: item) ?? true else { return }
        delegate?.shopViewController(self, didSelectItem: item)
    }
}
