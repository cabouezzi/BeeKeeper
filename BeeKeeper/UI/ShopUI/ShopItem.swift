//
//  ShopItem.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 10/8/23.
//

import Foundation

struct ShopItem {
    let name: String
    let description: String
    let cost: Resources
    let newProduct: () -> Structure
    
    init(cost: Resources, product: @escaping () -> Structure) {
        let test = product()
        self.name = test.name ?? "None"
        self.description = test.details
        self.cost = cost
        self.newProduct = product
    }
}
