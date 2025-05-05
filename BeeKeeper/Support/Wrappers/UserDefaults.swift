//
//  UserDefaults.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 9/8/23.
//

import Foundation

@propertyWrapper
struct UserDefaultsKey<T: Codable> {
    enum Key: String {
        case firstLogin = "first-login"
        case playMusic = "play-music"
        case playSoundEffects = "play-sound-effects"
    }
    
    let key: Key
    let defaultValue: T
    
    var wrappedValue: T {
        get {
            guard let data = UserDefaults.standard.object(forKey: key.rawValue) as? Data, let result = try? JSONDecoder().decode(T.self, from: data) else {
                return defaultValue
            }
            return result
        }
        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                print("\(Date.now): Error encoding '\(newValue)' in \(self)")
                return
            }
            UserDefaults.standard.set(data, forKey: key.rawValue)
        }
    }
}
