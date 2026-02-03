//
//  DemoOutputView.swift
//  bell-type-keyboard
//
//  Created by miseri.osaka on 2026/01/29.
//

import SwiftUI

/// DemoOutputView renders the demo output panel.
///
/// Example:
/// ```swift
/// DemoOutputView(displayText: "あい_", previewText: "12", candidateText: "愛")
/// ```
struct DemoOutputView: View {
    let displayText: String
    let previewText: String

    /// Renders the output panel with cursor and preview text.
    ///
    /// Example:
    /// ```swift
    /// DemoOutputView(displayText: "あ_", previewText: "1").body
    /// ```
    var body: some View {
        let showsPreview = !previewText.isEmpty
        let panelHeight: CGFloat = 140

        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("OUTPUT:")
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundColor(RetroTheme.displayTextDim)
                Spacer()
                Text("■")
                    .font(.system(size: 14, design: .monospaced))
                    .foregroundColor(RetroTheme.accentGreen)
                    .opacity(showsPreview ? 0.8 : 0.0)
            }
            .padding(.horizontal, 4)

            Text(displayText)
                .font(.system(size: 20, weight: .medium, design: .monospaced))
                .foregroundColor(RetroTheme.displayText)
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(minHeight: 60)
                .padding(8)
                .lineLimit(2)
                .truncationMode(.tail)

            HStack {
                Text(">> INPUT: [\(previewText)]")
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(RetroTheme.accentGreen)
                Spacer()
            }
            .padding(.horizontal, 4)
            .opacity(showsPreview ? 1.0 : 0.0)
        }
        .retroDisplay()
        .frame(height: panelHeight)
    }
}

#Preview {
    DemoOutputView(displayText: "あ_", previewText: "1")
}
