//
//  ShopView2.swift
//  BeeKeeper
//
//  Created by Chaniel Abou-Ezzi on 6/20/25.
//

import SwiftUI
import SceneKit

struct ShopView: View {
    @Environment(\.universalDismiss) var universalDismiss
    @ObservedObject var viewModel: ShopViewModel
    @State private var flippedIndex: Int? = nil

    var body: some View {
        GeometryReader { geometry in
            VStack {
                Spacer()
                
                let height = geometry.size.height
                VStack {
                    HStack {
                        Text("Shop")
                            .font(.title)
                            .bold()
                        
                        Spacer()
                        Button(action: universalDismiss) {
                            Image(.closeButton)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.black.opacity(0.2))
                    
                    ScrollView(.horizontal) {
                        ItemCellList(height)
                    }
                    .scrollIndicators(.hidden)
                    .frame(maxWidth: .infinity)
                }
                .frame(height: min(height, 400))
                .background(
                    Image(.backgroundWood)
                        .resizable(resizingMode: .stretch)
                        .ignoresSafeArea()
                )
            }
            .foregroundStyle(Color.white)
            .background(
                Color.black
                    .opacity(0.5)
                    .onTapGesture(perform: universalDismiss)
                    .ignoresSafeArea()
            )
        }
    }

    func getScene(_ item: ShopItem) -> SCNScene {
        let scene = SCNScene(named: "ModelBase.scn")!
        scene.background.contents = UIColor.clear
        scene.rootNode.childNode(withName: "BeeReference", recursively: true)?.isHidden = true

        let model = item.newProduct()
        let height = Float((model.boundingBox.max - model.boundingBox.min).y)
        let scale = min(6 / height, min(4 / Float(model.area.width), 4 / Float(model.area.height)))
        model.scale *= scale
        model.position = .zero

        scene.rootNode.addChildNode(model)
        return scene
    }
    
    @ViewBuilder
    private func ItemCellList(_ height: CGFloat) -> some View {
        HStack(alignment: .center) {
            ForEach(Array(viewModel.items.enumerated()), id: \.offset) { index, item in
                let binded = Binding(get: {
                    flippedIndex == index
                }, set: { newValue in
                    flippedIndex = newValue ? index : nil
                })
                
                FlipView(isFlipped: binded, duration: 0.3, perspective: 0.3) {
                    SFXManager.shared.playSound(.pop)
                } front: {
                    ItemCellFront(item)
                        .if(!viewModel.canSelect(item)) { view in
                            view
                                .overlay {
                                    Color.black.opacity(0.3)
                                        .disabled(true)
                                }
                        }
                        .cornerRadius(10)
                        .padding()
                } back: {
                    ItemCellBack(item)
                        .if(!viewModel.canSelect(item)) { view in
                            view
                                .overlay {
                                    Color.black.opacity(0.3)
                                        .disabled(true)
                                }
                        }
                        .cornerRadius(10)
                        .padding()
                }
                .frame(width: min(height * 0.75, 300))
                .shadow(color: .black.opacity(0.3), radius: 5)
                
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    @ViewBuilder
    private func ItemCellFront(_ item: ShopItem) -> some View {
        VStack(alignment: .leading) {
            Text(item.name)
                .font(.title3)
                .bold()
            
            Color.black
                .opacity(0.1)
                .cornerRadius(10)
            
            AttributedStringView(attributedString: item.cost.attributedString())
                .font(.body)
                .bubbleStyle(color: .black.opacity(0.1))
                .minimumScaleFactor(0.1)
        }
        .padding()
        .foregroundStyle(Color.white)
        .background(
            Image(.backgroundWood)
                .resizable(resizingMode: .stretch)
                .overlay(Color.white.opacity(0.1))
        )
    }
    
    @ViewBuilder
    private func ItemCellBack(_ item: ShopItem) -> some View {
        VStack(alignment: .leading) {
            Text(item.description)
                .font(.body)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .bubbleStyle(color: .black.opacity(0.1))
            
            Button("Buy") {
                if viewModel.canSelect(item) {
                    viewModel.selectItem(item)
                    universalDismiss()
                }
            }
            .buttonStyle(BubbleButtonStyle(color: viewModel.canSelect(item) ? .orange : .gray))
        }
        .padding()
        .foregroundStyle(Color.white)
        .background(
            Image(.backgroundWood)
                .resizable(resizingMode: .stretch)
                .overlay(Color.white.opacity(0.1))
        )
    }
}

#Preview {
    ShopView(viewModel: .init(items: [
        ShopItem(cost: Resources(honey: 100), product: { Hive() }),
        ShopItem(cost: Resources(pollen: 100), product: { Hive() }),
    ]))
}
