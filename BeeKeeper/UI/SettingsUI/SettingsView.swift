//
//  SettingsView.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 2/22/24.
//

import SwiftUI
import Combine

struct SettingsView: View {
    @ObservedObject var model = ViewModel()
    
    var body: some View {
        ZStack {
            // Background
            Color(uiColor: .darkGray)
                .ignoresSafeArea()
            // Contents
            VStack(spacing: 10) {
                // Header
                Text("Settings")
                    .font(.largeTitle)
                    .shadow(color: .black, radius: 1, x: 2, y: 1)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundStyle(.white)
                    .padding()
                    .background(Color(uiColor: .lightGray))
                
                // Sections
                HStack(spacing: 10) {
                    SliderSection(title: "Music", parameter: Binding(projectedValue: $model.maxVolumeMusic), range: 0...1)
                        .font(.headline)
                    
                    SliderSection(title: "Sound Effects", parameter: Binding(projectedValue: $model.maxVolumeSFX), range: 0...1)
                        .font(.headline)
                }
                .padding(.horizontal, 10)
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .clipShape(.rect(cornerRadius: 10))
        .padding(5)
        .shadow(color: .black, radius: 10)
    }
    
    @ViewBuilder
    func SliderSection(title: String, parameter: Binding<Float>, range: ClosedRange<Float>, color: Color = Color(uiColor: .white)) -> some View {
        VStack {
            HStack {
                Text(title)
                    .shadow(color: .black, radius: 1, x: 1, y: 1)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundStyle(.white)
                Spacer()
                Text(parameter.wrappedValue.formatted(.percent.precision(.fractionLength(0))).description)
                    .shadow(color: .black, radius: 1, x: 1, y: 1)
                    .foregroundStyle(.white)
            }
            Slider(value: parameter, in: range)
                .shadow(color: .black, radius: 1, x: 1, y: 1)
                .tint(color)
        }
        .bubbleStyle(color: Color(uiColor: .orange), padding: 10)
    }
}

#Preview {
    SettingsView()
}
