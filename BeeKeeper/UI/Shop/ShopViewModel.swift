//
//  ShopViewModel.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 9/21/23.
//

import SwiftUI

final class ShopViewModel: ObservableObject {
    let items = [
        ShopItemRow.ViewModel(name: "Hive",
                              image: Image(systemName: "photo"),
                              description: "A hive",
                              cost: Resources(honey: 10)),
        ShopItemRow.ViewModel(name: "Honeycomb",
                              image: Image(systemName: "photo"),
                              description: "A honeycomb",
                              cost: Resources(honey: 10, pollen: 100)),
        ShopItemRow.ViewModel(name: "Something Else!",
                              image: Image(systemName: "photo"),
                              description: "This is a long description of something else. Almost like it was purposely made to take up more than 2 (maybe 3) lines.",
                              cost: Resources(honey: 100000, pollen: 10000, beeBread: 1000))
    ]
    
    init() {
        
    }
}
