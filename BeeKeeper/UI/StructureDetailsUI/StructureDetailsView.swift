//
//  StructureDetailsView.swift
//  BeeKeeper
//
//  Created by Chaniel Abou-Ezzi on 6/16/25.
//

import SwiftUI

struct StructureDetailsView: View {
    @Environment(\.universalDismiss) var universalDismiss
    @ObservedObject var viewModel: StructureDetailsViewModel
    
    @State private var contentHeight: CGFloat = 0
    @State private var contentWidth: CGFloat = 0
    @State private var showBeeList: Bool = false
    @State private var showNamingScreen: Bool = false
    @State private var newBeeName: String = ""
    
    var body: some View {
        ZStack {
            if showNamingScreen {
                NamePopUp()
            } else if showBeeList {
                BeesPopUp()
            }
            
            MiniScreenView {
                VStack(spacing: 10) {
                    // Header
                    HStack(alignment: .top) {
                        VStack {
                            Text(viewModel.structure.name ?? "Structure")
                                .font(.system(.body, design: .rounded))
                                .frame(maxWidth: .infinity)
                            
                            Text(viewModel.structure.details)
                                .font(.caption)
                        }
                    }
                    
                    // MARK: Containers
                    if let container = viewModel.structure as? Container {
                        Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 8) {
                            GridRow {
                                Text("Containing:").fontWeight(.semibold)
                                TimelineView(.animation) { _ in
                                    if container.containing.isEmpty() {
                                        Text("Empty")
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    } else {
                                        AttributedStringView(attributedString: container.containing.attributedString(roundDecimals: true))
                                            .font(.caption)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                }
                            }
                            GridRow {
                                Text("Capacity:").fontWeight(.semibold)
                                AttributedStringView(attributedString: container.maximum.attributedString())
                                    .font(.caption)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .bubbleStyle(color: .black.opacity(0.1))
                    }
                    
                    // MARK: Basic info
                    Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 8) {
                        GridRow {
                            Text("Area:").fontWeight(.semibold)
                            Text("\(viewModel.structure.area.width) x \(viewModel.structure.area.height)")
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        GridRow {
                            Text("Workers:").fontWeight(.semibold)
                                .fixedSize()
                            Text("\(viewModel.structure.assignedBees.count) / \(viewModel.structure.maximumAssignedBees)")
                        }
                        
                        let columns: [GridItem] = Array(repeating: GridItem(.flexible(), spacing: 10), count: 5)
                        LazyVGrid(columns: columns, alignment: .center, spacing: 10) {
                            ForEach(0..<viewModel.structure.maximumAssignedBees, id: \.self) { i in
                                VStack(spacing: 0) {
                                    Image(.bee)
                                        .renderingMode(.template)
                                        .iconSize(.title1)
                                        .foregroundColor(i < viewModel.structure.assignedBees.count ? .orange : .brown)
                                    
                                    if i < viewModel.structure.assignedBees.count {
                                        Text(Array(viewModel.structure.assignedBees)[i].nickname)
                                            .font(.caption)
                                            .lineLimit(1)
                                    } else {
                                        Text("Assign")
                                            .font(.caption)
                                            .lineLimit(1)
                                            .foregroundColor(Color.brown)
                                    }
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .onTapGesture {
                                    if i >= viewModel.structure.assignedBees.count {
                                        showBeeList = true
                                    }
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .bubbleStyle(color: .black.opacity(0.1))
                    
                    // MARK: Incubator
                    if let incubator = viewModel.structure as? Incubator {
                        TimelineView(.animation) { context in
                            VStack {
                                Text("Status").fontWeight(.semibold)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    SmartCountdownView(timeLeft: incubator.currentIncubation?.timeRemaining ?? 0)
                                        .font(.body)
                                        .if(incubator.currentIncubation == nil) { view in
                                            view
                                                .frame(maxWidth: .infinity)
                                                .hidden()
                                                .overlay {
                                                    let cost = GameManager.shared.getIncubationCost()
                                                    if cost.isEmpty() {
                                                        Text("Free!")
                                                            .bold()
                                                    }
                                                    if !cost.isEmpty() {
                                                        AttributedStringView(attributedString: cost.attributedString(verbose: false))
                                                    }
                                                }
                                        }
                                        .bubbleStyle(color: .black.opacity(0.1))
                                
                                if incubator.state == .incubating {
                                    Button("Hatch") {}
                                    .buttonStyle(BubbleButtonStyle(color: .gray))
                                    
                                } else if incubator.state == .idle {
                                    Button("Incubate") {
                                        do {
                                            let time = GameManager.shared.getIncubationTime()
                                            try incubator.startIncubating(time)
                                        } catch {
                                            ErrorReporter.show(error)
                                        }
                                    }
                                    .buttonStyle(BubbleButtonStyle(color: .orange))
                                } else if incubator.state == .finished {
                                    Button("Hatch") {
                                        showNamingScreen = true
                                    }
                                    .buttonStyle(BubbleButtonStyle(color: .orange))
                                }
                            }
                            .bubbleStyle(color: .black.opacity(0.1))
                        }
                    }
                }
                .foregroundColor(Color(uiColor: .white))
                .shadow(radius: 1, y: 2)
                .font(.system(.caption, design: .rounded))
                .bindHeight(to: $contentHeight)
                .bindWidth(to: $contentWidth)
            }
        }
    }
    
    @ViewBuilder
    private func BeesPopUp() -> some View {
        let beeViewModel = BeeViewModel(bees: GameManager.shared.apiary.bees, selectedBee: nil)
        ZStack {
            Color.black
                .opacity(0.7)
                .ignoresSafeArea()
                .frame(maxWidth: .infinity)
                .onTapGesture {
                    showBeeList = false
                }
            
            VStack {
                BeeSelectorView(viewModel: beeViewModel)
                
                Button("Assign") {
                    do {
                        try beeViewModel.selectedBee?.assign(to: viewModel.structure)
                        showBeeList = false
                    } catch {
                        ErrorReporter.show(error)
                    }
                }
                .foregroundStyle(Color.white)
                .buttonStyle(BubbleButtonStyle(color: .orange))
            }
            .frame(maxWidth: 200, maxHeight: contentHeight - 20)
            .padding()
            .background(
                Image(.backgroundWood)
                    .resizable()
                    .scaledToFill()
            )
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color(uiColor: .darkBrown), lineWidth: 5)
            )
            .padding()
        }
        .zIndex(2)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    @ViewBuilder
    private func NamePopUp() -> some View {
        if let incubator = viewModel.structure as? Incubator {
            ZStack {
                Color.black
                    .opacity(0.7)
                    .ignoresSafeArea()
                    .frame(maxWidth: .infinity)
                    .onTapGesture {
                        showBeeList = false
                    }
                
                VStack(spacing: 16) {
                    Text("A new bee has hatched!")
                        .font(.body.bold())
                        .fontDesign(.rounded)
                        .foregroundStyle(Color.white)
                    
                    TextField("Name your new bee", text: $newBeeName)
                        .textFieldStyle(.plain)
                        .bubbleStyle(color: .black.opacity(0.1))
                    
                    Button("OK") {
                        do {
                            incubator.currentIncubation?.reward.setNickname(newBeeName)
                            try incubator.hatch()
                            showNamingScreen = false
                            universalDismiss()
                        } catch {
                            ErrorReporter.show(error)
                        }
                    }
                    .buttonStyle(BubbleButtonStyle(color: .orange))
                }
                .frame(maxWidth: contentWidth - 40)
                .foregroundStyle(Color.white)
                .padding()
                .background(
                    Image(.backgroundWood)
                        .resizable()
                        .scaledToFill()
                )
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color(uiColor: .darkBrown), lineWidth: 5)
                )
                .padding()
            }
            .zIndex(2)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

#Preview {
    let viewModel = {
        let incubator = Incubator()
        try? incubator.startIncubating(.init(seconds: 10))
        return StructureDetailsViewModel(structure: incubator)
    }()
    StructureDetailsView(viewModel: viewModel)
    
//    let hiveModel = {
//        let hive = Hive()
//        try! Bee().assign(to: hive)
//        return StructureDetailsViewModel(structure: hive)
//    }()
//    StructureDetailsView(viewModel: hiveModel)
}
