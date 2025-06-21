//
//  FlipView.swift
//  BeeKeeper
//
//  Created by Chaniel Abou-Ezzi on 6/21/25.
//

import SwiftUI

struct FlipView<Front: View, Back: View>: View {
    @Binding var isFlipped: Bool
    @State private var rotation: Double = 0

    private let onFlip: () -> Void
    private let duration: Double
    private let perspective: Double
    private let front: Front
    private let back: Back

    init(
        isFlipped: Binding<Bool>,
        duration: Double = 0.5,
        perspective: Double = 0.2,
        onFlip: @escaping () -> Void = {},
        @ViewBuilder front: () -> Front,
        @ViewBuilder back: () -> Back
    ) {
        self._isFlipped = isFlipped
        self.onFlip = onFlip
        self.duration = duration
        self.perspective = perspective
        self.front = front()
        self.back = back()
    }

    var body: some View {
        ZStack {
            front
                .opacity((isFlipped ? 180 : 0) < 90 ? 1.0 : 0.0)
                .onTapGesture {
                    isFlipped = true
                    onFlip()
                }
            back
                .scaleEffect(x: -1)
                .opacity((isFlipped ? 180 : 0) >= 90 ? 1.0 : 0.0)
                .onTapGesture {
                    isFlipped = false
                    onFlip()
                }
        }
        .rotation3DEffect(
            Angle.degrees((isFlipped ? 180 : 0)),
            axis: (0, 1, 0),
            perspective: perspective
        )
        .animation(.bouncy(duration: duration), value: isFlipped)
    }
}
