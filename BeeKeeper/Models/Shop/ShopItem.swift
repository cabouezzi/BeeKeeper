//
//  ShopItem.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 10/8/23.
//

import UIKit

struct ShopItem {
    let name: String
    let description: String?
    let cost: Resources
    let display: UIImage?
    let newProduct: () -> Structure
}
