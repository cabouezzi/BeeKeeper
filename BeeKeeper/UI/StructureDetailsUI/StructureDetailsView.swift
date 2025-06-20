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
                                .font(.system(.title, design: .rounded))
                                .frame(maxWidth: .infinity)
                            
                            Text(viewModel.structure.details)
                                .font(.body)
                        }
                    }
                    
                    // MARK: Containers
                    if let container = viewModel.structure as? Container {
                        Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 8) {
                            GridRow {
                                Text("Containing:").fontWeight(.semibold)
                                if container.containing.isEmpty() {
                                    Text("Empty")
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                } else {
                                    AttributedStringView(attributedString: container.containing.attributedString(roundDecimals: true))
                                        .font(.body)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }
                            GridRow {
                                Text("Capacity:").fontWeight(.semibold)
                                AttributedStringView(attributedString: container.maximum.attributedString())
                                    .font(.body)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color.black.opacity(0.1))
                        .cornerRadius(10)
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
                    .padding()
                    .background(Color.black.opacity(0.1))
                    .cornerRadius(10)
                    
                    // MARK: Incubator
                    if let incubator = viewModel.structure as? Incubator {
                        TimelineView(.animation) { context in
                            VStack {
                                Text("Status").fontWeight(.semibold)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                if let period = incubator.currentIncubation {
                                    SmartCountdownView(timeLeft: period.timeRemaining)
                                        .font(.title)
                                }
                                
                                if incubator.state == .incubating {
                                    
                                    Button("Speed Up") {
                                        do {
                                            try incubator.forceComplete()
                                        } catch {
                                            print(error.localizedDescription)
                                        }
                                    }
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color(uiColor: .baige))
                                    .foregroundColor(Color(uiColor: .darkBrown))
                                    .cornerRadius(12)
                                } else if incubator.state == .idle {
                                    Button("Incubate") {
                                        do {
                                            try incubator.startIncubating(100)
                                        } catch {
                                            print(error.localizedDescription)
                                        }
                                    }
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color(uiColor: .orange))
                                    .foregroundColor(Color(uiColor: .white))
                                    .cornerRadius(12)
                                } else if incubator.state == .finished {
                                    Button("Hatch") {
                                        showNamingScreen = true
                                    }
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color(uiColor: .orange))
                                    .foregroundColor(Color(uiColor: .white))
                                    .cornerRadius(12)
                                }
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.black.opacity(0.1))
                            .cornerRadius(12)
                        }
                    }
                    
                    // Buttons
                    Button("Close", action: universalDismiss)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(uiColor: .darkBrown))
                        .cornerRadius(12)
                }
                .foregroundColor(Color(uiColor: .white))
                .shadow(radius: 1, y: 2)
                .font(.system(.body, design: .rounded))
                .bindHeight(to: $contentHeight)
            }
        }
    }
    
    @ViewBuilder
    private func BeesPopUp() -> some View {
        let beeViewModel = BeeViewModel(bees: GameManager.shared.apiary.bees)
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
                        print(error.localizedDescription)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(uiColor: .orange))
                .foregroundColor(.white)
                .cornerRadius(12)
                .contentShape(RoundedRectangle(cornerRadius: 12))
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
            MiniScreenView {
                VStack(spacing: 16) {
                    Text("A new bee has Hatched!")
                        .font(.headline.bold())
                        .fontDesign(.rounded)
                        .foregroundStyle(Color.white)
                    
                    TextField("Name your new bee", text: $newBeeName)
                        .textFieldStyle(.plain)
                        .background(Color.clear)
                        .foregroundStyle(Color.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.black.opacity(0.1))
                        .cornerRadius(12)
                    
                    Button("OK") {
                        do {
                            showNamingScreen = false
                            universalDismiss()
                            incubator.currentIncubation?.reward.setNickname(newBeeName)
                            try incubator.hatch()
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(uiColor: .orange))
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .contentShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .zIndex(2)
            .background(
                Color.black
                    .opacity(0.7)
                    .ignoresSafeArea()
                    .zIndex(1)
                    .onTapGesture {
                        showNamingScreen = false
                    }
            )
        }
    }
}

#Preview {
//    let viewModel = {
//        let incubator = Incubator()
//        try? incubator.startIncubating(.init(seconds: 10))
//        return StructureDetailsViewModel(structure: incubator)
//    }()
//    StructureDetailsView(viewModel: viewModel)
    
    let hiveModel = {
        let hive = Hive()
        try! Bee().assign(to: hive)
        return StructureDetailsViewModel(structure: hive)
    }()
    StructureDetailsView(viewModel: hiveModel)
}
