//
//  Notification.swift
//  BeeKeeper
//
//  Created by Chaniel Abou-Ezzi on 6/22/25.
//
import SwiftUI
import Combine

/// Wrap any content in this to get toasts at the *top* of the screen
/// whenever `ErrorReporter.notification` is posted.
struct NotificationToastContainer: View {
//    let content: () -> Content
    
    @State private var toastMessage: String? = nil
    @State private var dismissWorkItem: DispatchWorkItem?
    
    var body: some View {
        ZStack {
            Color.clear
            
            if let message = toastMessage {
                VStack {
                    Text(message)
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.black.opacity(0.5))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .transition(
                            .move(edge: .top)
                            .combined(with: .opacity)
                        )
                        .padding(.top, 16)
                    
                    Spacer()
                }
                .zIndex(1)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .disabled(true)
        .animation(.easeInOut(duration: 0.3), value: toastMessage)
        .onReceive(NotificationCenter.default.publisher(for: ErrorReporter.notification)) { note in
            guard let error = note.object as? Error else { return }
            SFXManager.shared.playSound(.failure)
            showToast(error.localizedDescription)
        }
    }
    
    private func showToast(_ text: String, duration: TimeInterval = 3.0) {
        dismissWorkItem?.cancel()
        toastMessage = text
        
        let task = DispatchWorkItem {
            withAnimation {
                toastMessage = nil
            }
        }
        dismissWorkItem = task
        DispatchQueue.main.asyncAfter(deadline: .now() + duration, execute: task)
    }
}

#Preview {
    NotificationToastContainer()
}
