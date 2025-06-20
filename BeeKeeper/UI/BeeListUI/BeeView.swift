//
//  Untitled.swift
//  BeeKeeper
//
//  Created by Chaniel Abou-Ezzi on 6/19/25.
//

import SwiftUI
import SceneKit

struct BeeView: View {
    @Environment(\.universalDismiss) var universalDismiss
    @ObservedObject var viewModel: BeeViewModel
    @State private var gridHeight: CGFloat = 0
    
    init(viewModel: BeeViewModel) {
        self.viewModel = viewModel
        self.viewModel.selectedBee = self.viewModel.selectedBee ?? self.viewModel.bees.first
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
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 8) {
                                GridRow {
                                    Text("Assignment:")
                                        .fontWeight(.semibold)
                                    
                                    Label {
                                        Text(selectedBee.producerAssignment?.name ?? "None")
                                    } icon: {
                                        if let structure = selectedBee.producerAssignment {
                                            Image(structure is Flower ? .flower : .hive)
                                                .resizable()
                                                .foregroundStyle(Color(uiColor: .baige))
                                        }
                                    }
                                    .labelStyle(FontMatchedLabelStyle())
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .bubbleStyle(color: .black.opacity(0.1))
                            
                            Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 8) {
                                gridRow("Production:", value: selectedBee.production.attributedString(delimiter: " ", verbose: true))
                                gridRow("Consumption:", value: selectedBee.consumption.attributedString(delimiter: " ", verbose: true))
                                gridRow("Intimidation:", value: selectedBee.intimidation)
                                gridRow("Stinger:", value: selectedBee.stingerDamage)
                                gridRow("Venom:", value: selectedBee.venomDamage)
                            }
                            .bubbleStyle(color: .black.opacity(0.1))
                            
                            HStack {
                                Button(action: viewModel.onSelect, label: {
                                    Image(systemName: "magnifyingglass.circle.fill")
                                        .font(.body)
                                    
                                })
                                .buttonStyle(BubbleButtonStyle(color: Color(uiColor: .black.withAlphaComponent(0.1)), padding: 10))
                                .foregroundStyle(Color(uiColor: .darkBrown))
                                
                                Button(action: viewModel.onAssign, label: {
                                    Image(systemName: "pencil")
                                        .font(.body)
                                    
                                })
                                .buttonStyle(BubbleButtonStyle(color: .black.opacity(0.1), padding: 12))
                                .foregroundStyle(Color(uiColor: .darkBrown))
                            }
                            
                            ConfirmableButton(action: viewModel.onRelease, label: {
                                Text("Release Bees")
                                    .bubbleStyle(color: .orange)
                            }, okLabel: {
                                Text("Confirm")
                                    .bubbleStyle(color: .orange)
                            }, cancelLabel: {
                                Text("Cancel")
                                    .bubbleStyle(color: .black.opacity(0.1))
                            })
                            .font(.caption)
                        }
                        .bindHeight(to: $gridHeight)
                        .font(.body)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    BeeSelectorView(viewModel: viewModel)
                        .frame(height: gridHeight)
                        .if(viewModel.bees.isEmpty) { view in
                            VStack {
                                view
                                    .padding()
                                Text("The apiary is very quiet.\nHead to the incubator to hatch more bees.")
                                    .multilineTextAlignment(.center)
                                    .bold()
                                    .fontDesign(.rounded)
                                    .foregroundStyle(Color(uiColor: .darkBrown))
                                    .bubbleStyle(color: .black.opacity(0.1))
                            }
                        }
                }
            }
        }
        .foregroundColor(Color(uiColor: .white))
        .shadow(radius: 1, y: 2)
        .font(.system(.body, design: .rounded))
        .onChange(of: viewModel.isPresented) { newValue in
            if !newValue {
                universalDismiss()
            }
        }
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
//    BeeView(viewModel: .init(bees: []))
    BeeView(viewModel: .init(bees: GameManager.shared.apiary.bees.sorted(by: { $0.nickname < $1.nickname })))
}
