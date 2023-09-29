//
//  ShopResourceLabel.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 9/15/23.
//

import SwiftUI

struct ShopResourceLabel: View {
    let resources: Resources
    var body: some View {
        HStack {
            if resources.money > 0 {
                Image(systemName: "photo").foregroundColor(.green)
                Text("\(resources.money, specifier: "%0.2f")")
            }
            if resources.honey > 0 {
                Image(systemName: "photo").foregroundColor(.orange)
                Text("\(resources.honey, specifier: "%d")")
            }
            if resources.pollen > 0 {
                Image(systemName: "photo").foregroundColor(.yellow)
                Text("\(resources.pollen, specifier: "%d")")
            }
            if resources.beeBread > 0 {
                Image(systemName: "photo").foregroundColor(.brown)
                Text("\(resources.beeBread, specifier: "%d")")
            }
        }
    }
}

struct ShopResourceLabel_Previews: PreviewProvider {
    static var previews: some View {
        ShopResourceLabel(resources: Resources(money: 1, honey: 2, pollen: 3, beeBread: 4))
    }
}
