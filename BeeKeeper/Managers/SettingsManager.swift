//
//  SettingsManager.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 2/7/24.
//

import Foundation

class SettingsManager {
    static let shared = SettingsManager()
    
    @UserDefaultsKey(key: .firstLogin, defaultValue: true) var isFirstLogin
    @UserDefaultsKey(key: .maxVolumeMusic, defaultValue: 1) var maxVolumeMusic: Float
    @UserDefaultsKey(key: .maxVolumeSFX, defaultValue: 1) var maxVolumeSFX: Float
    
    private init() {
        
    }
}
