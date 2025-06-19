//
//  FontMatchedLabelStyle.swift
//  BeeKeeper
//
//  Created by Chaniel Abou-Ezzi on 6/18/25.
//

import SwiftUI

struct FontMatchedLabelStyle: LabelStyle {
    @State private var labelHeight: CGFloat = 0

    func makeBody(configuration: Configuration) -> some View {
        HStack(alignment: .center, spacing: 8) {
            configuration.icon
                .scaledToFit()
                .frame(height: labelHeight)

            configuration.title
                .overlay(
                    GeometryReader { geo in
                        Color.clear
                            .onAppear {
                                self.labelHeight = geo.size.height
                            }
                            .onChange(of: geo.size.height) { newValue in
                                self.labelHeight = newValue
                            }
                    }
                )
        }
    }
}
