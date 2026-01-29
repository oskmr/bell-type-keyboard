//
//  DemoHeaderView.swift
//  bell-type-keyboard
//
//  Created by miseri.osaka on 2026/01/29.
//

import SwiftUI

/// DemoHeaderView renders the static header section for the demo screen.
///
/// Example:
/// ```swift
/// DemoHeaderView()
/// ```
struct DemoHeaderView: View {
    /// Renders the header labels with retro styling.
    ///
    /// Example:
    /// ```swift
    /// DemoHeaderView().body
    /// ```
    var body: some View {
        VStack(spacing: 16) {
            Text("POKE-BELL")
                .font(.system(size: 24, weight: .bold, design: .monospaced))
                .foregroundColor(RetroTheme.accentGreen)
                .shadow(color: RetroTheme.accentGreen.opacity(0.5), radius: 5)

            Text(">> 2-DIGIT INPUT >>")
                .font(.system(size: 14, design: .monospaced))
                .foregroundColor(RetroTheme.displayText)

            Text("例: 12 = 「い」")
                .font(.system(size: 12, design: .monospaced))
                .foregroundColor(RetroTheme.displayTextDim)
        }
    }
}

#Preview {
    DemoHeaderView()
}
