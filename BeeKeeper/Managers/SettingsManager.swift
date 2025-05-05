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
    @UserDefaultsKey(key: .playMusic, defaultValue: false) var shouldPlayMusic
    
    private init() {
        
    }
}
