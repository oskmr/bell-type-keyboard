//
//  KeyboardExtensionView.swift
//  bell-type-keyboard
//
//  Created by miseri.osaka on 2026/01/29.
//

import SwiftUI

struct KeyboardExtensionView: View {
    @ObservedObject var inputManager: PokebellInputManager

    let buttons: [[Int]] = [
        [1, 2, 3],
        [4, 5, 6],
        [7, 8, 9],
        [0]
    ]

    var body: some View {
        VStack(spacing: 0) {
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
                        inputManager.confirmInput()
                    }) {
                        Text("CLR")
                            .font(.system(size: 14, weight: .bold, design: .monospaced))
                    }
                    .buttonStyle(CompactRetroButtonStyle(isSpecial: true))
                }
            }
            .padding(6)
            .background(RetroTheme.bodyBackground)
        }
    }
}
