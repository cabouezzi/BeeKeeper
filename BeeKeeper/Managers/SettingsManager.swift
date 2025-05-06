//
//  SettingsManager.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 2/7/24.
//

import Foundation
import Combine

class SettingsManager {
    enum Key: String {
        case firstLogin = "first-login"
        case musicVolume = "music-volume"
        case soundEffectsVolume = "sound-effects-volume"
        case beeEffectsVolume = "bee-effects-volume"
    }
    
    static let shared = SettingsManager()
    
    @UserDefaultsKey(key: .firstLogin, defaultValue: true) var isFirstLogin
    @UserDefaultsKey(key: .musicVolume, defaultValue: 0.4) var musicVolume: Float
    @UserDefaultsKey(key: .soundEffectsVolume, defaultValue: 0.5) var soundEffectsVolume: Float
    @UserDefaultsKey(key: .beeEffectsVolume, defaultValue: 0.5) var beeEffectsVolume: Float
        
    
    private init() {
        
    }
}
