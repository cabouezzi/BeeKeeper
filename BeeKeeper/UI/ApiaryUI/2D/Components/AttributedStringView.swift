//
//  AttributedStringView.swift
//  BeeKeeper
//
//  Created by Chaniel Abou-Ezzi on 6/16/25.
//

import SwiftUI

struct AttributedStringView: View {
    let attributedString: NSAttributedString

    @State private var textHeight: CGFloat = 0

    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            ForEach(components(), id: \.id) { component in
                switch component {
                case .text(let string, let attributes):
                    textView(string: string, attributes: attributes)
                        .lineLimit(1)
                        .background(
                            GeometryReader { geo in
                                Color.clear.preference(key: TextHeightKey.self, value: geo.size.height)
                            }
                        )
                case .image(let image, _):
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(height: textHeight)
                        .padding(.horizontal, 2)
                        .alignmentGuide(VerticalAlignment.center) { d in d.height / 2 }
                }
            }
        }
        .onPreferenceChange(TextHeightKey.self) { value in
            if value > 0 {
                textHeight = value
            }
        }
    }

    private func textView(string: String, attributes: Attributes) -> some View {
        let baseText = Text(string)
        let textWithFont = attributes.font.map { baseText.font($0) } ?? baseText
        let textWithColor = attributes.color.map { textWithFont.foregroundColor($0) } ?? textWithFont
        return textWithColor
    }

    enum Component: Identifiable {
        case text(String, Attributes)
        case image(Image, CGSize)

        var id: UUID { UUID() }
    }

    struct Attributes {
        var font: Font?
        var color: Color?
    }

    func components() -> [Component] {
        var results: [Component] = []

        attributedString.enumerateAttributes(in: NSRange(location: 0, length: attributedString.length)) { attrs, range, _ in
            if let attachment = attrs[.attachment] as? NSTextAttachment {
                // Ignore attachment.bounds completely
                if let uiImage = attachment.image
                    ?? (attachment.fileWrapper != nil ? UIImage(data: attachment.fileWrapper!.regularFileContents!) : nil) {
                    let image = Image(uiImage: uiImage)
                    results.append(.image(image, .zero)) // pass zero size, unused
                }
            } else {
                let substring = attributedString.attributedSubstring(from: range).string

                let font: Font? = {
                    if let nsFont = attrs[.font] as? UIFont {
                        return Font(nsFont)
                    }
                    return nil
                }()

                let color: Color? = {
                    if let nsColor = attrs[.foregroundColor] as? UIColor {
                        return Color(nsColor)
                    }
                    return nil
                }()

                results.append(.text(substring, Attributes(font: font, color: color)))
            }
        }

        return results
    }

    struct TextHeightKey: PreferenceKey {
        static var defaultValue: CGFloat = 0
        static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
            value = max(value, nextValue())
        }
    }
}
