//
//  KeyboardExtensionView.swift
//  bell-type-keyboard
//
//  Created by miseri.osaka on 2026/01/29.
//

import SwiftUI

/// KeyboardExtensionView renders the numeric keypad and prediction bar.
///
/// Example:
/// ```swift
/// KeyboardExtensionView(inputManager: PokebellInputManager(isKeyboardExtension: true))
/// ```
struct KeyboardExtensionView: View {
    @ObservedObject var inputManager: PokebellInputManager

    let buttons: [[Int]] = [
        [1, 2, 3],
        [4, 5, 6],
        [7, 8, 9]
    ]

    /// Renders the keyboard layout with optional prediction candidates.
    ///
    /// Example:
    /// ```swift
    /// KeyboardExtensionView(inputManager: PokebellInputManager(isKeyboardExtension: true)).body
    /// ```
    var body: some View {
        VStack(spacing: 0) {
            PredictionBarView(candidates: inputManager.candidates) { candidate in
                inputManager.selectCandidate(candidate)
            }
            .background(Color.clear)
            .frame(height: 34)
            .layoutPriority(1)
            .fixedSize(horizontal: false, vertical: true)

            VStack(spacing: 4) {
                ForEach(buttons, id: \.self) { row in
                    HStack(spacing: 4) {
                        ForEach(row, id: \.self) { number in
                            Button(action: {
                                inputManager.pressKey(number)
                            }) {
                                Text("\(number)")
                                    .font(.system(size: 24, weight: .bold, design: .monospaced))
                            }
                            .buttonStyle(CompactRetroButtonStyle())
                        }
                    }
                }

                HStack(spacing: 4) {
                    Button(action: {
                        inputManager.deleteLastCharacter()
                    }) {
                        HStack(spacing: 2) {
                            Image(systemName: "delete.left")
                                .font(.system(size: 14))
                        }
                    }
                    .buttonStyle(CompactRetroButtonStyle())

                    Button(action: {
                        inputManager.pressKey(0)
                    }) {
                        Text("0")
                            .font(.system(size: 24, weight: .bold, design: .monospaced))
                    }
                    .buttonStyle(CompactRetroButtonStyle())

                    Button(action: {
                        inputManager.confirmInput()
                    }) {
                        Text("CLR")
                            .font(.system(size: 14, weight: .bold, design: .monospaced))
                    }
                    .buttonStyle(CompactRetroButtonStyle(isSpecial: true))
                }

            }
            .background(RetroTheme.bodyBackground)
        }
        .background(Color.clear)
        .ignoresSafeArea()
    }
}
