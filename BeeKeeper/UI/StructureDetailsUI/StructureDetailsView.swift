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
    
    var body: some View {
        MiniScreenView {
            VStack(spacing: 24) {
                // Header
                HStack(alignment: .top) {
                    VStack {
                        Text(viewModel.structure.name ?? "Structure")
                            .font(.system(.title, design: .rounded))
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.white)
                        
                        Text(viewModel.structure.details)
                            .font(.body)
                    }
                }
                
                // MARK: Containers
                Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 8) {
                    if let container = viewModel.structure as? Container {
                        GridRow {
                            Text("Containing:").fontWeight(.semibold)
                            if container.containing.isEmpty() {
                                Text("Empty")
                            } else {
                                AttributedStringView(attributedString: container.containing.attributedString(roundDecimals: true))
                                    .font(.body)
                            }
                        }
                        GridRow {
                            Text("Capacity:").fontWeight(.semibold)
                            AttributedStringView(attributedString: container.maximum.attributedString())
                                .font(.body)
                        }
                    }
                    
                    // Basic info
                    GridRow {
                        Text("Area:").fontWeight(.semibold)
                        Text("\(viewModel.structure.area.width) x \(viewModel.structure.area.height)")
                    }
                    
                    GridRow {
                        Text("Maximum Bees:").fontWeight(.semibold)
                        Text(viewModel.structure.maximumAssignedBees == 0 ? "-" : viewModel.structure.maximumAssignedBees.description)
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
                            if let period = incubator.currentPeriod {
                                SmartCountdownView(timeLeft: period.timeLeft)
                                    .font(.title)
                            }
                            
                            if incubator.state == .incubating {
                                
                                Button("Speed Up") {
                                    do {
                                        try incubator.forceFinish()
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
                                    do {
                                        try incubator.hatch()
                                        universalDismiss()
                                    } catch {
                                        print(error.localizedDescription)
                                    }
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
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                }
                
                // Buttons
                Button("Close", action: universalDismiss)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(uiColor: .darkBrown))
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .foregroundColor(Color(uiColor: .white))
            .shadow(radius: 1, y: 2)
            .font(.system(.body, design: .rounded))
        }
    }
}

#Preview {
    StructureDetailsView(viewModel: StructureDetailsViewModel())
}
