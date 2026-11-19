//
//  BeeViewModel.swift
//  BeeKeeper
//
//  Created by Chaniel Abou-Ezzi on 6/20/25.
//

import Observation

@MainActor
@Observable
final class BeeViewModel {
    var isPresented = true
    var bees: [Bee]
    var selectedBee: Bee?
    @ObservationIgnored var onRelease: () -> Void
    @ObservationIgnored var onSelect: () -> Void
    @ObservationIgnored var onAssign: () -> Void
    
    init(
        bees: [Bee],
        selectedBee: Bee? = nil,
        onRelease: @escaping () -> Void = {},
        onSelect: @escaping () -> Void = {},
        onAssign: @escaping () -> Void = {}
    ) {
        self.bees = bees
        self.selectedBee = selectedBee
        self.onRelease = onRelease
        self.onSelect = onSelect
        self.onAssign = onAssign
    }
}
