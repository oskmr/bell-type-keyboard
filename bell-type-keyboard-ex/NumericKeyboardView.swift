//
//  NumericKeyboardView.swift
//  bell-type-keyboard
//
//  Created by Claude on 2026/03/08.
//

import SwiftUI

/// NumericKeyboardView renders a simple numeric keypad for direct number input.
/// Each digit key also shows the corresponding kana row hint (あ・か・さ…).
struct NumericKeyboardView: View {
    var onKeyPress: (String) -> Void
    var onDelete: () -> Void
    var onModeSwitch: () -> Void

    let buttons: [[String]] = [
        ["1", "2", "3"],
        ["4", "5", "6"],
        ["7", "8", "9"]
    ]

    /// Kana row leader shown as a hint under each digit, like a phone keypad.
    static let kanaHints: [String: String] = [
        "1": "あ", "2": "か", "3": "さ",
        "4": "た", "5": "な", "6": "は",
        "7": "ま", "8": "や", "9": "ら",
        "0": "わ"
    ]

    var body: some View {
        VStack(spacing: 4) {
            ForEach(buttons, id: \.self) { row in
                HStack(spacing: 4) {
                    ForEach(row, id: \.self) { number in
                        Button(action: {
                            onKeyPress(number)
                        }) {
                            digitLabel(number)
                        }
                        .buttonStyle(CompactRetroButtonStyle())
                    }
                }
            }

            HStack(spacing: 4) {
                Button(action: {
                    onDelete()
                }) {
                    HStack(spacing: 2) {
                        Image(systemName: "delete.left")
                            .font(.system(size: 14))
                    }
                }
                .buttonStyle(CompactRetroButtonStyle())

                Button(action: {
                    onKeyPress("0")
                }) {
                    digitLabel("0")
                }
                .buttonStyle(CompactRetroButtonStyle())

                Button(action: {
                    onModeSwitch()
                }) {
                    Text("あ")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                }
                .buttonStyle(CompactRetroButtonStyle(isSpecial: true))
            }
        }
        .background(RetroTheme.bodyBackground)
    }

    /// Builds a digit label with the kana row hint beneath it.
    private func digitLabel(_ number: String) -> some View {
        VStack(spacing: 1) {
            Text(number)
                .font(.system(size: 20, weight: .bold, design: .monospaced))
            if let hint = NumericKeyboardView.kanaHints[number] {
                Text(hint)
                    .font(.system(size: 10, weight: .regular, design: .rounded))
                    .opacity(0.6)
            }
        }
    }
}
