//
//  BeeSelectorView.swift
//  BeeKeeper
//
//  Created by Chaniel Abou-Ezzi on 6/20/25.
//

import SwiftUI

struct BeeSelectorView: View {
    let viewModel: BeeViewModel
    
    init(viewModel: BeeViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack {
            HStack {
                Label {
                    Text("Bees")
                        .font(.body)
                } icon: {
                    Image(.bee)
                        .resizable()
                        .foregroundColor(Color(uiColor: .darkBrown))
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
                    Label {
                        Text(bee.nickname)
                            .lineLimit(1)
                            .truncationMode(.tail)
                            .font(.caption)
                    } icon: {
                        Image(bee.producerAssignment is Flower ? .flower : .hive)
                            .resizable()
                            .foregroundStyle(Color(uiColor: .baige))
                            .opacity(bee.producerAssignment == nil ? 0 : 1)
                    }
                    .labelStyle(FontMatchedLabelStyle())
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
        }
        .foregroundStyle(.white)
    }
}

#Preview {
    BeeSelectorView(viewModel: .init(bees: GameManager.shared.apiary.bees.sorted(by: { $0.nickname < $1.nickname })))
        .background(Color.blue)
}
