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
    @StateObject private var inputManager = PokebellInputManager(converter: KanaKanjiConverterService())

    /// Renders the demo layout and binds it to the input manager.
    ///
    /// Example:
    /// ```swift
    /// DemoView().body
    /// ```
    var body: some View {
        // Compose display strings for the output section.
        let previewText = inputManager.currentPreview
        let composingText = inputManager.composingText
        let displayText = inputManager.inputText + composingText + (previewText.isEmpty ? "" : previewText)
        let keyboardHeight: CGFloat = 320

        VStack(spacing: 0) {
            VStack(spacing: 16) {
                DemoOutputView(
                    displayText: displayText,
                    previewText: previewText,
                )
                .padding(.top, 40)
                .padding(.horizontal)

                PredictionBarView(candidates: inputManager.candidates) { candidate in
                    inputManager.selectCandidate(candidate)
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 20)
            .background(RetroTheme.bodyBackground)

            Spacer(minLength: 0)

            PokebellKeyboardView(inputManager: inputManager)
                .frame(height: keyboardHeight)
                .padding(.bottom, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .transaction { transaction in
            transaction.animation = nil
        }
        .background(RetroTheme.bodyBackground)
    }
}
