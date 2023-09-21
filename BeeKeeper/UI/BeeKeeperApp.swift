//
//  BeeKeeperApp.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 9/8/23.
//

import SwiftUI

internal enum AppViews {
    case apiary
    case shop
    case evolution
    case map
}

@main
struct BeeKeeperApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State var currentView = AppViews.apiary
    
    var body: some Scene {
        WindowGroup {
            switch currentView {
            case .apiary:
                ApiarySwiftUIView().aspectRatio(contentMode: .fill)
                HStack {
                    Button("Shop") {
                        currentView = .shop
                    }
                    Button("Evolution") {
                        currentView = .evolution
                    }
                    Button("Map") {
                        currentView = .map
                    }
                }
            case .shop:
                VStack {
                    Button("Back") {
                        currentView = .apiary
                    }
                    ShopView()
                }
            case .evolution:
                Button("Back") {
                    currentView = .apiary
                }
            case .map:
                Button("Back") {
                    currentView = .apiary
                }
            }
        }
    }
}

// MARK: - Environment Variable for Current View
private struct DefaultCurrentUserKey: EnvironmentKey {
    static let defaultValue: Binding<AppViews> = .constant(.apiary)
}

extension EnvironmentValues {
    var currentView: Binding<AppViews> {
        get { self[DefaultCurrentUserKey.self] }
        set { self[DefaultCurrentUserKey.self] = newValue }
    }
}

extension View {
    func currentView (_ view: Binding<AppViews>) -> some View {
        environment(\.currentView, view)
    }
}
