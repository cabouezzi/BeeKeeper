//
//  ShopViewModel.swift
//  BeeKeeper
//
//  Created by Chaniel Abou-Ezzi on 6/21/25.
//

import Observation

@MainActor
@Observable
final class ShopViewModel {
    var items: [ShopItem]
    @ObservationIgnored var onSelectItem: (ShopItem) -> Void
    
    init(items: [ShopItem]? = nil, onSelectItem: @escaping (ShopItem) -> Void = { _ in }) {
        self.items = items
        ?? [
            ShopItem(cost: Resources(honey: 1_000,   pollen: 3_000),   product: { Hive() }),
            ShopItem(cost: Resources(honey: 60_000,  pollen: 42_500),   product: { Incubator() }),
            ShopItem(cost: Resources(honey: 1_250,   pollen:   3_000),   product: { HoneyStorage() }),
            ShopItem(cost: Resources(honey: 3_000,   pollen:   1_250),   product: { PollenStorage() }),
            ShopItem(cost: Resources(honey: 100,   pollen:   100),   product: { Daisy() }),
            ShopItem(cost: Resources(honey: 500,   pollen:   750),   product: { Lavender() }),
            ShopItem(cost: Resources(honey: 1_000,   pollen: 1_500),   product: { Rose() })
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
