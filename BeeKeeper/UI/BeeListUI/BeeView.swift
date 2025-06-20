//
//  Untitled.swift
//  BeeKeeper
//
//  Created by Chaniel Abou-Ezzi on 6/19/25.
//

import SwiftUI
import SceneKit

class BeeViewModel: ObservableObject {
    @Published var bees: [Bee]
    @Published var selectedBee: Bee?
    
    init(bees: [Bee], selectedBee: Bee? = nil) {
        self.bees = bees
        self.selectedBee = selectedBee ?? bees.first ?? nil
    }
}

struct BeeView: View {
    @Environment(\.universalDismiss) var universalDismiss
    @ObservedObject var viewModel: BeeViewModel
    @State private var gridHeight: CGFloat = 0
    
    init(viewModel: BeeViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        MiniScreenView {
            VStack {
                // Header
                HStack(alignment: .top) {
                    if let selectedBee = viewModel.selectedBee {
                        VStack {
                            Text(selectedBee.nickname)
                                .lineLimit(1)
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 8) {
                                gridRow("Production:", value: selectedBee.production.attributedString(delimiter: " ", verbose: true))
                                gridRow("Consumption:", value: selectedBee.consumption.attributedString(delimiter: " ", verbose: true))
                                gridRow("Intimidation:", value: selectedBee.intimidation)
                                gridRow("Stinger:", value: selectedBee.stingerDamage)
                                gridRow("Venom:", value: selectedBee.venomDamage)
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.black.opacity(0.1))
                            .cornerRadius(10)
                            .bindHeight(to: $gridHeight)
                        }
                        .font(.body)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
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
                        .frame(height: gridHeight)
                        .frame(maxWidth: .infinity)
                        .listStyle(.plain)
                        .listRowSpacing(5)
                        .foregroundStyle(.white)
                    }
                }
                
                // Buttons
                Button("Close", action: universalDismiss)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(uiColor: .darkBrown))
                    .cornerRadius(12)
            }
        }
        .foregroundColor(Color(uiColor: .white))
        .shadow(radius: 1, y: 2)
        .font(.system(.body, design: .rounded))
    }
    
    @ViewBuilder
    private func gridRow(_ text: String, value: Any) -> some View {
        GridRow {
            Text(text)
                .fontWeight(.semibold)
                .frame(alignment: .trailing)
            if let attributedString = value as? NSAttributedString {
                AttributedStringView(attributedString: attributedString)
                    .font(.caption)
                    .frame(alignment: .leading)
            } else if let value = value as? NSNumber {
                Text(String(format: "%.2f", value.floatValue))
                    .font(.caption)
                    .frame(alignment: .leading)
            }
        }
        .fixedSize(horizontal: true, vertical: false)
    }
}

#Preview {
    BeeView(viewModel: .init(bees: GameManager.shared.apiary.bees.sorted(by: { $0.nickname < $1.nickname })))
}
