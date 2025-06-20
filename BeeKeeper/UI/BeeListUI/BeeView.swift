//
//  Untitled.swift
//  BeeKeeper
//
//  Created by Chaniel Abou-Ezzi on 6/19/25.
//

import SwiftUI
import SceneKit

final class BeeViewModel: ObservableObject {
    @Published var bees: [Bee]
    @Published var selectedBee: Bee?
    var onRelease: () -> Void
    
    init(bees: [Bee], selectedBee: Bee? = nil, onRelease: @escaping () -> Void = {}) {
        self.bees = bees
        self.selectedBee = selectedBee ?? bees.first ?? nil
        self.onRelease = onRelease
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
                        }
                        .bindHeight(to: $gridHeight)
                        .font(.body)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    BeeSelectorView(viewModel: viewModel)
                        .frame(height: gridHeight)
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
                    .frame(alignment: .leading)
            } else if let value = value as? NSNumber {
                Text(String(format: "%.2f", value.floatValue))
                    .frame(alignment: .leading)
            }
        }
        .font(.body)
        .fixedSize(horizontal: true, vertical: false)
    }
}

#Preview {
    BeeView(viewModel: .init(bees: GameManager.shared.apiary.bees.sorted(by: { $0.nickname < $1.nickname })))
}
