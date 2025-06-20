//
//  Untitled.swift
//  BeeKeeper
//
//  Created by Chaniel Abou-Ezzi on 6/19/25.
//

import SwiftUI

struct ViewHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

fileprivate struct BindWidth: ViewModifier {
    @Binding var width: CGFloat

    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geo in
                    Color.clear
                        .onAppear {
                            width = geo.size.width
                        }
                        .onChange(of: geo.frame(in: .local).width) { newWidth in
                            width = newWidth
                        }
                }
            )
    }
}

fileprivate struct BindHeight: ViewModifier {
    @Binding var height: CGFloat

    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geo in
                    Color.clear
                        .onAppear {
                            height = geo.size.height
                        }
                        .onChange(of: geo.frame(in: .local).height) { newHeight in
                            height = newHeight
                        }
                }
            )
    }
}

extension View {
    func bindWidth(to width: Binding<CGFloat>) -> some View {
        self.modifier(BindWidth(width: width))
    }
    
    func bindHeight(to height: Binding<CGFloat>) -> some View {
        self.modifier(BindHeight(height: height))
    }
}
