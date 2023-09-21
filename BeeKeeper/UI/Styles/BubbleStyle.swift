//
//  BubbleStyle.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 8/14/21.
//

import SwiftUI

fileprivate struct BubbleStyle: ViewModifier {
    let color: Color
    let edges: Edge.Set
    let padding: CGFloat?
    
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity)
            .padding(edges, padding)
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .fill().foregroundColor(color)
                    .shadow(color: .secondary, radius: 2)
            }
    }
}

extension View {
    /// - Parameters:
    ///     - color: The background color of the bubble. The default of this parameter is `systemBackground`.
    ///     - edges: The edges where padding will be applied. The default of this parameter is `all`.
    ///     - padding: An amount, given in points, to pad this view on the specified edges. If you set the value to nil, SwiftUI uses a platform-specific default amount. The default value of this parameter is `nil`.
    func bubbleStyle (color: Color = Color(.systemBackground), edges: Edge.Set = .all, padding: CGFloat? = nil) -> some View {
        self.modifier(BubbleStyle(color: color, edges: edges, padding: padding))
    }
}
