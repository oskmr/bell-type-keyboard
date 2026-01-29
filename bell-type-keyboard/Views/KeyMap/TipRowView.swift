//
//  TipRowView.swift
//  bell-type-keyboard
//
//  Created by miseri.osaka on 2026/01/29.
//

import SwiftUI

/// TipRowView renders a single usage tip row.
///
/// Example:
/// ```swift
/// TipRowView(icon: "1.circle.fill", text: "2桁の数字で1文字を入力")
/// ```
struct TipRowView: View {
    let icon: String
    let text: String

    /// Renders the tip row with icon and text.
    ///
    /// Example:
    /// ```swift
    /// TipRowView(icon: "hand.tap.fill", text: "OKで確定").body
    /// ```
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(RetroTheme.accentGreen)
                .frame(width: 30)

            Text(text)
                .font(.system(size: 14, design: .monospaced))
                .foregroundColor(RetroTheme.displayText)
                .fixedSize(horizontal: false, vertical: true)

            Spacer()
        }
    }
}

#Preview {
    TipRowView(icon: "1.circle.fill", text: "2桁の数字で1文字を入力")
}
