//
//  ShopItemRow.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 9/15/23.
//

import SwiftUI
import UIKit

struct ShopItemRow: View {
    let viewModel: ViewModel
    
    var body: some View {
        VStack {
            HStack {
                VStack {
                    Text(viewModel.name)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .lineLimit(1)
                    viewModel.image.resizable(resizingMode: .stretch)
                        .frame(width: 150, height: 150)
                }
                .frame(maxWidth: 150, alignment: .leading)
                
                Text(viewModel.description ?? "")
                    .font(.caption)
                    .lineLimit(.none)
                
                Spacer()
            }
            Button(action: {
                
            }, label: {
                Text("Buy!")
                    .foregroundColor(.blue)
                    .font(.body.bold())
                    .bubbleStyle(color: .green)
            })
            
            ShopResourceLabel(resources: viewModel.cost)
                .foregroundColor(.black)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .foregroundColor(.black)
        .background {
            Color(.white).ignoresSafeArea()
        }
        .cornerRadius(10)
    }
}

struct ShopItemRow_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color(.lightGray).ignoresSafeArea()
            ShopItemRow(viewModel: ShopItemRow.ViewModel(name: "Some name", image: Image(systemName: "photo"), description: "A hive", cost: Resources(honey: 100000, pollen: 10000, beeBread: 1000)))
        }
    }
}
