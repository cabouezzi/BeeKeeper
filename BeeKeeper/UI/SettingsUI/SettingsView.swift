//
//  SettingsView.swift
//  BeeKeeper
//
//  Created by Chaniel Abou-Ezzi on 5/6/25.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.universalDismiss) var universalDismiss
    
    var body: some View {
        MiniScreenView {
            VStack {
                // Header
                HStack {
                    Spacer()
                    Text("Settings")
                        .font(.system(.body, design: .rounded))
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.white)
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
                Button("Close", action: universalDismiss)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(uiColor: .darkBrown))
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .foregroundColor(Color(uiColor: .white))
            .shadow(radius: 1, y: 2)
            .font(.system(.caption, design: .rounded))
        }
    }
}

#Preview {
    SettingsView()
}
