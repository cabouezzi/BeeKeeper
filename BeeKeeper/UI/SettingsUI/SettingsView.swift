//
//  SettingsView.swift
//  BeeKeeper
//
//  Created by Chaniel Abou-Ezzi on 5/6/25.
//

import SwiftUI

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}

class SettingsViewModel: ObservableObject {
    var onDismiss: () -> Void = {}
}

struct SettingsView: View {
    @ObservedObject var viewModel = SettingsViewModel()

    var body: some View {
        ZStack {
            // Main Settings Pop-up
            VStack(spacing: 24) {
                // Header
                HStack {
                    Spacer()
                    Text("Settings")
                        .font(.system(.title, design: .rounded))
                    Spacer()
                }
                
                // Music Volume
                VStack(alignment: .leading) {
                    Label("Music Volume", systemImage: "music.note")
                    Slider(value: SettingsManager.shared.$musicVolume.binding)
                        .accentColor(.orange)
                }
                
                // Sound Effects
                VStack(alignment: .leading) {
                    Label("Sound Effects", systemImage: "speaker.wave.2.fill")
                    Slider(value: SettingsManager.shared.$soundEffectsVolume.binding)
                        .accentColor(.orange)
                }
                
                // Sound Effects
                VStack(alignment: .leading) {
                    Label("Buzzing", systemImage: "waveform.path")
                    Slider(value: SettingsManager.shared.$beeEffectsVolume.binding)
                        .accentColor(.orange)
                }
                
                // Buttons
                Button("Close") {
                    viewModel.onDismiss()
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.gray.opacity(0.4))
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .foregroundColor(Color(uiColor: .white))
            .shadow(radius: 1, y: 2)
            .font(.system(.body, design: .rounded))
            .padding()
            .frame(maxWidth: 400)
            .background(Color(UIColor(_colorLiteralRed: 0, green: 0.5, blue: 1, alpha: 1)))
            .cornerRadius(20)
            .padding()
        }
        .ignoresSafeArea()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            Color.black.opacity(0.2)
                .ignoresSafeArea()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .onTapGesture(perform: viewModel.onDismiss)
        )
    }
}
