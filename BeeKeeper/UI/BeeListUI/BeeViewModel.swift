//
//  BeeViewModel.swift
//  BeeKeeper
//
//  Created by Chaniel Abou-Ezzi on 6/20/25.
//

import SwiftUI

final class BeeViewModel: ObservableObject {
    @Published var isPresented = true
    @Published var bees: [Bee]
    @Published var selectedBee: Bee?
    var onRelease: () -> Void
    var onSelect: () -> Void
    var onAssign: () -> Void
    
    init(
        bees: [Bee],
        selectedBee: Bee? = nil,
        onRelease: @escaping () -> Void = {},
        onSelect: @escaping () -> Void = {},
        onAssign: @escaping () -> Void = {}
    ) {
        self.bees = bees
        self.selectedBee = selectedBee ?? nil
        self.onRelease = onRelease
        self.onSelect = onSelect
        self.onAssign = onAssign
    }
}
