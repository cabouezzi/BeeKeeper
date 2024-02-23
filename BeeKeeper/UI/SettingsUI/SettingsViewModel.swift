//
//  SettingsViewModel.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 2/22/24.
//

import Combine

extension SettingsView {
    class ViewModel: ObservableObject {
        // @Published wrappers for SettingsManager properties
        @Published var maxVolumeSFX: Float = SettingsManager.shared.maxVolumeSFX
        @Published var maxVolumeMusic: Float = SettingsManager.shared.maxVolumeMusic
        
        var bag: Set<AnyCancellable> = []
        
        init() {
            bindToSetting($maxVolumeSFX, key: \.maxVolumeSFX)
            bindToSetting($maxVolumeMusic, key: \.maxVolumeMusic)
        }
        
        func bindToSetting<T: Codable>(_ publisher: Published<T>.Publisher , key: ReferenceWritableKeyPath<SettingsManager, T>) {
            publisher.sink { x in
                SettingsManager.shared[keyPath: key] = x
            }.store(in: &bag)
        }
    }
}
