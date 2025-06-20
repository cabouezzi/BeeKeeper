//
//  View.swift
//  BeeKeeper
//
//  Created by Chaniel Abou-Ezzi on 6/20/25.
//

import SwiftUI

extension View {
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, @ViewBuilder transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
