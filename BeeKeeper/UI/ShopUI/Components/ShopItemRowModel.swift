//
//  ShopItemRowModel.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 9/21/23.
//

import SwiftUI

extension ShopItemRow {
    struct ViewModel {
        let name: String
        let image: Image
        let description: String?
        let cost: Resources
        
        init(name: String, image: Image, description: String?, cost: Resources) {
            self.name = name
            self.image = image
            self.description = description
            self.cost = cost
        }
    }
}
