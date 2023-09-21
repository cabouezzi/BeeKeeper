//
//  ShopView.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 9/15/23.
//

import SwiftUI

struct ShopView: View {
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
    
    var body: some View {
        VStack {
            Text("Welcome to the shop")
                .frame(maxWidth: .infinity)
            ScrollView {
                ForEach(items, id: \.name) { vm in
                    ShopItemRow(viewModel: vm)
                        .padding(.horizontal)
                        .onTapGesture {
                            
                        }
                }
                .padding(.top)
            }
            .background(Color.orange)
            .refreshable {
                
            }
        }
        .background(Color.yellow)
    }
}

struct ShopView_Previews: PreviewProvider {
    static var previews: some View {
        ShopView()
    }
}
