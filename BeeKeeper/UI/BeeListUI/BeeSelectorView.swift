//
//  BeeSelectorView.swift
//  BeeKeeper
//
//  Created by Chaniel Abou-Ezzi on 6/20/25.
//

import SwiftUI

struct BeeSelectorView: View {
    @ObservedObject var viewModel: BeeViewModel
    
    init(viewModel: BeeViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack {
            HStack {
                Label {
                    Text("Bees")
                        .font(.headline)
                } icon: {
                    Image(.bee)
                        .resizable()
                        .foregroundColor(.brown)
                }
                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .labelStyle(FontMatchedLabelStyle())

            List(viewModel.bees, id: \.self) { bee in
                Button(action: {
                    viewModel.selectedBee = bee
                    SFXManager.shared.playSound(.pop)
                }) {
                    Text(bee.nickname)
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .font(.caption)
                }
                .contentShape(RoundedRectangle(cornerRadius: 12))
                .listRowBackground(
                    (bee == viewModel.selectedBee ? Color.orange : Color.black.opacity(0.1))
                        .cornerRadius(10)
                )
            }
            .frame(maxWidth: .infinity)
            .listStyle(.plain)
            .listRowSpacing(5)
            .foregroundStyle(.white)
        }
    }
}
