//
//  DismissableView.swift
//  BeeKeeper
//
//  Created by Chaniel Abou-Ezzi on 5/21/25.
//

import SwiftUI

private struct UniversalDismissKey: EnvironmentKey {
    static let defaultValue: () -> Void = {}
}

extension EnvironmentValues {
    /// Dismisses the view whether or not in a `SwiftUI` or `UIKit` environment
    var universalDismiss: () -> Void {
        get { self[UniversalDismissKey.self] }
        set { self[UniversalDismissKey.self] = newValue }
    }
}

/// Provides functionality for dismissing a `View` regardless of being in SwiftUI or UIKit
/// - Note: For dismissing a `View` hosted in a `UIHostingController`, one must set to the `\.hostingController` environment keypath to the `UIHostingController` used as shown in the example below.
///
///```swift
/// let hostingController = UIHostingController(rootView: MyView())
/// hostingController.rootView = hostingController.rootView.environment(\.hostingController, hostingController)
/// present(hostingController, animated: true)
/// ```
fileprivate struct DismissableViewModifier: ViewModifier {
    @Environment(\.dismiss) private var systemDismiss
    @Environment(\.hostingController) private var hostingController
    
    func body(content: Content) -> some View {
        content.environment(\.universalDismiss, { [weak hostingController] in
            hostingController?.willMove(toParent: nil)
            hostingController?.view.removeFromSuperview()
            hostingController?.removeFromParent()
            systemDismiss()
        })
    }
}

extension View {
    /// Makes the `View` able to dismiss itself using the `univesralDismiss` environment key.
    func dismissable() -> some View {
        return self.modifier(DismissableViewModifier())
    }
}
