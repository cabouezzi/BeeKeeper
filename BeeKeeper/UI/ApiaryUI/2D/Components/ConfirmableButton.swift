//
//  ConfirmableButton.swift
//  BeeKeeper
//
//  Created by Chaniel Abou-Ezzi on 6/20/25.
//

import SwiftUI

struct ConfirmableButton<
    Label: View,
    OkLabel: View,
    CancelLabel: View
>: View {
    let action: () -> Void
    let label: () -> Label
    let okLabel: () -> OkLabel
    let cancelLabel: () -> CancelLabel
    
    @State private var isConfirming = false
    
    init(action: @escaping () -> Void,
         @ViewBuilder label: @escaping () -> Label,
         @ViewBuilder okLabel: @escaping () -> OkLabel,
         @ViewBuilder cancelLabel: @escaping () -> CancelLabel) {
        self.action = action
        self.label = label
        self.okLabel = okLabel
        self.cancelLabel = cancelLabel
    }
    
    // Convenience init with title and optional OK/Cancel button text strings
    init(
        _ title: String,
        okText: String = "OK",
        cancelText: String = "Cancel",
        action: @escaping () -> Void
    ) where Label == Text, OkLabel == Text, CancelLabel == Text {
        self.init(
            action: action,
            label: { Text(title) },
            okLabel: { Text(okText) },
            cancelLabel: { Text(cancelText) }
        )
    }
    
    var body: some View {
        if isConfirming {
            HStack(spacing: 12) {
                Button(action: {
                    action()
                    isConfirming = false
                    SFXManager.shared.playSound(.pop)
                }) {
                    okLabel()
                }
                
                Button(action: {
                    isConfirming = false
                    SFXManager.shared.playSound(.pop)
                }) {
                    cancelLabel()
                }
            }
        } else {
            Button(action: {
                isConfirming = true
                SFXManager.shared.playSound(.pop)
            }) {
                label()
            }
        }
    }
}
