//
//  EvolutionDetailsView.swift
//  BeeKeeper
//
//  Created by Chaniel Abou-Ezzi on 6/17/25.
//

import SwiftUI

struct EvolutionDetailsView: View {
    @Environment(\.universalDismiss) var universalDismiss
    @ObservedObject var viewModel: EvolutionDetailsViewModel
    
    init(viewModel: EvolutionDetailsViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack() {
            Label(title: {
                Text(viewModel.gene.rawValue)
            }, icon: {
                Image(viewModel.gene.icon).resizable()
            })
            .labelStyle(FontMatchedLabelStyle())
            .font(.system(.body, design: .rounded))
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundColor(.white)
            
            Text(viewModel.gene.details)
                .font(.caption)
            
            TimelineView(.animation) { _ in
                switch EvolutionResearchManager.shared.researchState {
                case .idle:
                    if GameManager.shared.account.unlockedGenes.contains(viewModel.gene) {
                        Text("Owned")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color.black.opacity(0.1))
                            .cornerRadius(10)
                    } else {
                        Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 8) {
                            Text("Cost:")
                                .fontWeight(.semibold)
                            AttributedStringView(attributedString: viewModel.gene.cost.attributedString())
                            
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color.black.opacity(0.1))
                        .cornerRadius(10)
                        
                        Button("Research") {
                            _ = try? EvolutionResearchManager.shared.beginResearch(for: viewModel.gene)
                        }
                        .foregroundColor(.white)
                        .buttonStyle(BubbleButtonStyle(color: .orange))
                    }
                    
                case .researching(let research):
                    SmartCountdownView(timeLeft: research.timeRemaining)
                        .font(.body)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.black.opacity(0.2))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    Button("Speed Up") {
                        try? EvolutionResearchManager.shared.forceComplete()
                    }
                    .foregroundColor(.white)
                    .buttonStyle(BubbleButtonStyle(color: .black))
                    
                case .completed(let research):
                    SmartCountdownView(timeLeft: 0)
                        .font(.body)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.black.opacity(0.2))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    Button("Claim") {
                        try? EvolutionResearchManager.shared.claimResearch()
                        viewModel.unlockedGenes = viewModel.unlockedGenes.union([research.reward])
                    }
                    .foregroundColor(.white)
                    .buttonStyle(BubbleButtonStyle(color: .orange))
                }
            }
        }
        .padding()
        .background(
            Image(.backgroundHexagonsDark)
            .resizable()
            .scaledToFill()
            .opacity(0.8)
        )
        .foregroundColor(Color(uiColor: .white))
        .font(.system(.caption, design: .rounded))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.yellow.opacity(0.3), lineWidth: 2)
        )
        .padding()
    }
}

#Preview {
    ZStack {
        GeometryReader { geometry in
            Color.blue.frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
            HStack {
                Spacer()
                EvolutionDetailsView(viewModel: EvolutionDetailsViewModel())
                    .frame(maxWidth: geometry.size.width / 3)
            }
        }
    }
}
