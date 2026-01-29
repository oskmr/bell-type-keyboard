//
//  KeyMapRowView.swift
//  bell-type-keyboard
//
//  Created by miseri.osaka on 2026/01/29.
//

import SwiftUI

/// KeyMapRowView renders a single row in the character map.
///
/// Example:
/// ```swift
/// KeyMapRowView(row: 1, characters: [(code: "11", char: "あ")])
/// ```
struct KeyMapRowView: View {
    let row: Int
    let characters: [(code: String, char: String)]

    private let rowButtonSize = CGSize(width: 50, height: 50)
    private let rowCornerRadius: CGFloat = 6
    private let cardCornerRadius: CGFloat = 12
    private let itemCornerRadius: CGFloat = 4
    private let itemSpacing: CGFloat = 6
    private let itemSize = CGSize(width: 50, height: 50)

    /// Renders the row header and horizontal character list.
    ///
    /// Example:
    /// ```swift
    /// KeyMapRowView(row: 1, characters: [(code: "11", char: "あ")]).body
    /// ```
    var body: some View {
        // Extracted layout values to keep the body readable.
        let rowLabel = "ROW \(row)"
        let rowText = "\(row)"

        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: rowCornerRadius)
                        .fill(RetroTheme.buttonBackground)
                        .overlay(
                            RoundedRectangle(cornerRadius: rowCornerRadius)
                                .stroke(RetroTheme.borderColor, lineWidth: 2)
                        )
                        .shadow(color: Color.black.opacity(0.3), radius: 3, x: 0, y: 2)
                        .frame(width: rowButtonSize.width, height: rowButtonSize.height)

                    Text(rowText)
                        .font(.system(size: 28, weight: .bold, design: .monospaced))
                        .foregroundColor(RetroTheme.displayText)
                }

                Image(systemName: "arrow.right")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(RetroTheme.accentGreen)

                Text(rowLabel)
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundColor(RetroTheme.accentGreen)

                Spacer()
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: itemSpacing) {
                    ForEach(characters, id: \.code) { item in
                        VStack(spacing: 4) {
                            ZStack {
                                RoundedRectangle(cornerRadius: itemCornerRadius)
                                    .fill(RetroTheme.displayBackground)
                                    .frame(width: itemSize.width, height: itemSize.height)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: itemCornerRadius)
                                            .stroke(RetroTheme.accentGreen.opacity(0.3), lineWidth: 1)
                                    )

                                Text(item.char)
                                    .font(.system(size: 22, weight: .medium, design: .monospaced))
                                    .foregroundColor(RetroTheme.displayText)
                            }

                            Text(item.code)
                                .font(.system(size: 11, weight: .bold, design: .monospaced))
                                .foregroundColor(RetroTheme.displayTextDim)
                        }
                    }
                }
            }
        }
        .padding()
        .background(RetroTheme.buttonBackground)
        .overlay(
            RoundedRectangle(cornerRadius: cardCornerRadius)
                .stroke(RetroTheme.borderColor, lineWidth: 3)
        )
        .overlay(
            RoundedRectangle(cornerRadius: cardCornerRadius)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.05),
                            Color.clear
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .cornerRadius(cardCornerRadius)
    }
}

#Preview {
    KeyMapRowView(row: 1, characters: [(code: "11", char: "あ")])
}
