//
//  TermsAndConditionsView.swift
//  BeeKeeper
//
//  Created by Chaniel Abou-Ezzi on 6/23/25.
//

import SwiftUI
import MarkdownUI

/// A SwiftUI view displaying the Terms & Conditions from a Markdown file using MarkdownUI for full Markdown support
struct TermsAndConditionsView: View {
    let onAccept: () -> Void
    @State private var agreed = false
    @State private var height: CGFloat = 0
    
    private var markdownContent: String {
        guard let url = Bundle.main.url(forResource: "TermsAndConditions", withExtension: "md"),
              let data = try? Data(contentsOf: url),
              let markdown = String(data: data, encoding: .utf8) else {
            return "Unable to load content."
        }
        return markdown
    }
    
    var body: some View {
        ZStack {
            Color.black
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
                .overlay {
                    Image(.backgroundHexagons)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .ignoresSafeArea()
                }
            
            VStack(spacing: 0) {
                ScrollView {
                    Markdown(markdownContent)
                        .padding()
                }
                
                Divider()
                
                VStack {
                    Button(action: { agreed.toggle() }) {
                        HStack {
                            Image(systemName: agreed ? "checkmark.square" : "square")
                                .font(.title2)
                            Text("I have read and agree to the Terms & Conditions")
                                .font(.footnote)
                            Spacer()
                        }
                        .padding(.horizontal)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.top)
                    
                    Button(action: {
                        onAccept()
                    }) {
                        Text("Continue")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(agreed ? Color.accentColor : Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .disabled(!agreed)
                    .padding()
                }
                .background(Color(UIColor.systemBackground))
            }
            .preferredColorScheme(.light)
            .bindHeight(to: $height)
            .frame(width: height)
            .padding(10)
            .background(Color.white)
            .cornerRadius(10)
            .padding()
        }
    }
}

struct TermsAndConditionsView_Previews: PreviewProvider {
    static var previews: some View {
        TermsAndConditionsView {
            
        }
    }
}
