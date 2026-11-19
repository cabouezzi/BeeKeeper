//
//  NamePrompt.swift
//  BeeKeeper
//
//  Created by Chaniel Abou-Ezzi on 6/22/25.
//

import SwiftUI

struct NamePromptView: View {
    @Environment(\.universalDismiss) private var universalDismiss
    @State private var name = GameManager.shared.account.name
    @State private var contentWidth: CGFloat = 0
    
    var onDismiss: () -> Void
    
    var body: some View {
        ZStack {
            Color.black
                .opacity(0.7)
                .ignoresSafeArea()
                .frame(maxWidth: .infinity)
                .frame(maxHeight: .infinity)
                .bindWidth(to: $contentWidth)
            
            VStack(spacing: 16) {
                Text("What's your name?")
                    .font(.body.bold())
                    .fontDesign(.rounded)
                    .foregroundStyle(Color.white)
                
                TextField("Type in your name", text: $name)
                    .textFieldStyle(.plain)
                    .bubbleStyle(color: .black.opacity(0.1))
                
                Button("OK") {
                    do {
                        guard !name.isEmpty else {
                            throw GenericError.custom(message: "Your name cannot be empty.")
                        }
                        GameManager.shared.account.name = name
                        GameManager.shared.recordChange()
                        universalDismiss()
                        onDismiss()
                    } catch {
                        ErrorReporter.show(error)
                    }
                }
                .buttonStyle(BubbleButtonStyle(color: .orange))
            }
            .foregroundStyle(Color.white)
            .padding()
            .background(
                Image(.backgroundWood)
                    .resizable()
                    .scaledToFill()
            )
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color(uiColor: .darkBrown), lineWidth: 5)
            )
            .padding()
            .frame(width: contentWidth / 2)
        }
        .zIndex(2)
    }
}
