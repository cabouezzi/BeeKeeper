//
//  UserDefaults.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 9/8/23.
//  Modified to support both Combine and SwiftUI Binding
//

import Foundation
import SwiftUI
import Combine

@propertyWrapper
struct UserDefaultsKey<T: Codable> {
    let key: String
    let defaultValue: T
    
    // Keep as implicitly unwrapped so we can init in init()
    private var subject: CurrentValueSubject<T, Never>!
    
    init(key: String, defaultValue: T) {
        self.key = key
        self.defaultValue = defaultValue
        
        // Use your instance method to load the initial value
        let initial = loadFromUserDefaults()
        self.subject = CurrentValueSubject(initial)
    }
    
    init(key: SettingsManager.Key, defaultValue: T) {
        self.key = key.rawValue
        self.defaultValue = defaultValue
        
        // Use your instance method to load the initial value
        let initial = loadFromUserDefaults()
        self.subject = CurrentValueSubject(initial)
    }
    
    var wrappedValue: T {
        get { subject.value }
        nonmutating set {
            subject.send(newValue)
            setToUserDefaults(newValue)
        }
    }
    
    var projectedValue: ValueAccess {
        ValueAccess(
            get: { self.wrappedValue },
            set: { self.wrappedValue = $0 },
            publisher: subject.eraseToAnyPublisher()
        )
    }
    
    private func loadFromUserDefaults() -> T {
        guard
            let data = UserDefaults.standard.data(forKey: key),
            let decoded = try? JSONDecoder().decode(T.self, from: data)
        else {
            return defaultValue
        }
        return decoded
    }
    
    private func setToUserDefaults(_ value: T) {
        guard let data = try? JSONEncoder().encode(value) else {
            print("\(Date()): Error encoding '\(value)' for key '\(key)'")
            return
        }
        UserDefaults.standard.set(data, forKey: key)
    }
    
    struct ValueAccess {
        fileprivate let get: () -> T
        fileprivate let set: (T) -> Void
        let publisher: AnyPublisher<T, Never>
        // SwiftUI Binding
        var binding: Binding<T> {
            Binding(get: get, set: set)
        }
        
        init(get: @escaping () -> T, set: @escaping (T) -> Void, publisher: AnyPublisher<T, Never>) {
            self.get = get
            self.set = set
            self.publisher = publisher
        }
    }
}
