//
//  NumericKeyboardView.swift
//  bell-type-keyboard
//
//  Created by Claude on 2026/03/08.
//

import SwiftUI

/// NumericKeyboardView renders a simple numeric keypad for direct number input.
struct NumericKeyboardView: View {
    var onKeyPress: (String) -> Void
    var onDelete: () -> Void
    var onModeSwitch: () -> Void

    let buttons: [[String]] = [
        ["1", "2", "3"],
        ["4", "5", "6"],
        ["7", "8", "9"]
    ]

    var body: some View {
        VStack(spacing: 4) {
            ForEach(buttons, id: \.self) { row in
                HStack(spacing: 4) {
                    ForEach(row, id: \.self) { number in
                        Button(action: {
                            onKeyPress(number)
                        }) {
                            Text(number)
                                .font(.system(size: 24, weight: .bold, design: .monospaced))
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
                    Text("0")
                        .font(.system(size: 24, weight: .bold, design: .monospaced))
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
}
