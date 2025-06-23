//
//  SettingsManager.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 2/7/24.
//

import Foundation
import Combine

class SettingsManager {
    static let shared = SettingsManager()
    
    @UserDefaultsKey(key: .firstLogin, defaultValue: true) var isFirstLogin
    @UserDefaultsKey(key: .musicVolume, defaultValue: 0.4) var musicVolume: Float
    @UserDefaultsKey(key: .soundEffectsVolume, defaultValue: 0.5) var soundEffectsVolume: Float
    @UserDefaultsKey(key: .beeEffectsVolume, defaultValue: 0.5) var beeEffectsVolume: Float
    @UserDefaultsKey(key: .hasAcceptedTerms, defaultValue: false) var hasAcceptedTerms: Bool
    
    private init() {
        
    }
}
