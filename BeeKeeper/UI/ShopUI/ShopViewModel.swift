//
//  ShopViewModel.swift
//  BeeKeeper
//
//  Created by Chaniel Abou-Ezzi on 6/21/25.
//

import Combine

class ShopViewModel: ObservableObject {
    @Published var items: [ShopItem]
    var onSelectItem: (ShopItem) -> Void
    
    init(items: [ShopItem]? = nil, onSelectItem: @escaping (ShopItem) -> Void = { _ in }) {
        self.items = items
        ?? [
            ShopItem(cost: Resources(honey: 5_000,   pollen: 2_000),   product: { Hive() }),
            ShopItem(cost: Resources(honey: 50_000,  pollen: 1_500),   product: { Incubator() }),
            ShopItem(cost: Resources(honey: 1_000,   pollen:   200),   product: { HoneyStorage() }),
            ShopItem(cost: Resources(honey: 1_000,   pollen:   500),   product: { PollenStorage() }),
            ShopItem(cost: Resources(honey:   500,   pollen:   300),   product: { Daisy() }),
            ShopItem(cost: Resources(honey: 1_000,   pollen:   500),   product: { Lavender() }),
            ShopItem(cost: Resources(honey: 2_500,   pollen: 1_000),   product: { Rose() })
        ]
        self.onSelectItem = onSelectItem
    }
    
    func canSelect(_ item: ShopItem) -> Bool {
        return GameManager.shared.getAllResources().canAfford(item.cost)
    }
    
    func selectItem(_ item: ShopItem) {
        onSelectItem(item)
    }
}
