//
//  DemoView.swift
//  bell-type-keyboard
//
//  Created by miseri.osaka on 2026/01/29.
//

import SwiftUI

/// DemoView renders the demo screen with header, output, and keypad.
///
/// Example:
/// ```swift
/// DemoView()
/// ```
struct DemoView: View {
    @StateObject private var inputManager = PokebellInputManager()

    /// Renders the demo layout and binds it to the input manager.
    ///
    /// Example:
    /// ```swift
    /// DemoView().body
    /// ```
    var body: some View {
        // Compose display strings for the output section.
        let previewText = inputManager.currentPreview
        let displayText = inputManager.inputText + previewText + (previewText.isEmpty ? "" : "_")
        VStack(spacing: 0) {
            VStack(spacing: 16) {
                DemoHeaderView()
                    .padding(.top, 20)

                DemoOutputView(
                    displayText: displayText,
                    previewText: previewText
                )
                .padding(.horizontal)
            }
            .padding(.bottom, 20)
            .background(RetroTheme.bodyBackground)

            Spacer()

            PokebellKeyboardView(inputManager: inputManager)
        }
        .background(RetroTheme.bodyBackground)
    }
}
