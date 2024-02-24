//
//  ButtonWithPopover.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 2/24/24.
//

import SwiftUI

// "Meh" name
struct ButtonWithPopover<Content: View>: View {
    
    @State var isShowing = false
    @State var title: String
    @State private var content: () -> Content
    
    init(title: String, content: @escaping () -> Content) {
        self.title = title
        self.content = content
    }
    
    var body: some View {
        Button(title) {
            $isShowing.wrappedValue = true
        }
        .bubbleStyle(color: Color(uiColor: .lightGray), padding: 10)
        .padding(10)
        .fullScreenCover(isPresented: $isShowing) {
            ZStack {
                VStack {
                    Button("Close") {
                        $isShowing.wrappedValue = false
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding()
                    Spacer()
                }
                content()
            }
        }
    }
}

#Preview {
    ButtonWithPopover(title: "Hello") {
        Button("Hellow again") {}
    }
}
