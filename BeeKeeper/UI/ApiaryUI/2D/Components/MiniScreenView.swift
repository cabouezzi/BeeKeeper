//
//  Untitled.swift
//  BeeKeeper
//
//  Created by Chaniel Abou-Ezzi on 5/21/25.
//

import SwiftUI
import UIKit

private struct HostingControllerKey: EnvironmentKey {
    static let defaultValue: UIViewController? = nil
}

extension EnvironmentValues {
    /// The hosting `UIViewController` for this SwiftUI view, if available.
    ///
    /// This is injected by UIKit when creating the `UIHostingController`.
    ///
    /// Use this to perform UIKit actions such as dismissing the view or
    /// accessing navigation controllers.
    ///```swift
    /// let hostingController = UIHostingController(rootView: MyView())
    /// hostingController.rootView = hostingController.rootView.environment(\.hostingController, hostingController)
    /// present(hostingController, animated: true)
    /// ```
    var hostingController: UIViewController? {
        get { self[HostingControllerKey.self] }
        set { self[HostingControllerKey.self] = newValue }
    }
}


/// Provides the background and dismiss functionality of an in-game miniscreen (Settings, Achievements, Details, etc.).
struct MiniScreenView<Content: View>: View {
    @Environment(\.universalDismiss) var universalDismiss
    let content: () -> Content
    
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        ZStack {
            content()
                .padding()
                .frame(maxWidth: 400)
                .background(Image(.backgroundWood).resizable().scaledToFill())
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color(uiColor: .darkBrown), lineWidth: 5)
                )
        }
        .ignoresSafeArea()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            Color.black.opacity(0.2)
                .ignoresSafeArea()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .onTapGesture(perform: universalDismiss)
        )
    }
}
