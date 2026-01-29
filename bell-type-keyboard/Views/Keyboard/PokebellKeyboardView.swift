//
//  PokebellKeyboardView.swift
//  bell-type-keyboard
//
//  Created by miseri.osaka on 2026/01/29.
//

import SwiftUI

struct PokebellKeyboardView: View {
    @ObservedObject var inputManager: PokebellInputManager

    private let buttons: [[Int]] = [
        [1, 2, 3],
        [4, 5, 6],
        [7, 8, 9],
        [0]
    ]

    var body: some View {
        VStack(spacing: 10) {
            ForEach(buttons, id: \.self) { row in
                HStack(spacing: 10) {
                    ForEach(row, id: \.self) { number in
                        Button(action: {
                            inputManager.pressKey(number)
                        }) {
                            Text("\(number)")
                                .font(.system(size: 32, weight: .bold, design: .monospaced))
                        }
                        .buttonStyle(RetroButtonStyle())
                    }
                }
            }

            HStack(spacing: 10) {
                Button(action: {
                    inputManager.deleteLastCharacter()
                }) {
                    HStack(spacing: 4) {
                        Text("[")
                        Image(systemName: "delete.left")
                            .font(.system(size: 18))
                        Text("DEL")
                        Text("]")
                    }
                }
                .buttonStyle(RetroButtonStyle())

                Button(action: {
                    inputManager.confirmInput()
                }) {
                    HStack(spacing: 4) {
                        Text("[")
                        Text("CLR")
                        Text("]")
                    }
                }
                .buttonStyle(RetroButtonStyle(isSpecial: true))
            }
        }
        .padding()
        .background(RetroTheme.bodyBackground)
    }
}
