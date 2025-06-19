//
//  BarButtonStyle.swift
//  BeeKeeper
//
//  Created by Chaniel Abou-Ezzi on 6/18/25.
//

import SwiftUI

struct BarButtonStyle: ButtonStyle {
    let color: Color
    let edges: Edge.Set
    let padding: CGFloat?
    
    init(color: Color, edges: Edge.Set = .all, padding: CGFloat? = nil) {
        self.color = color
        self.edges = edges
        self.padding = padding
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .padding(edges, padding)
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .fill().foregroundColor(color)
            }
    }
}
