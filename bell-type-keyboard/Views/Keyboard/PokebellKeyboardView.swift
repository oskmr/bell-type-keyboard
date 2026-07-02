//
//  PokebellKeyboardView.swift
//  bell-type-keyboard
//
//  Created by miseri.osaka on 2026/01/29.
//

import SwiftUI

struct PokebellKeyboardView: View {
    var inputManager: PokebellInputManager

    private var isComposing: Bool {
        !inputManager.composingText.isEmpty
    }

    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                digitKey(1)
                digitKey(2)
                digitKey(3)
                deleteKey
            }
            HStack(spacing: 10) {
                digitKey(4)
                digitKey(5)
                digitKey(6)
                spaceKey
            }
            HStack(spacing: 10) {
                digitKey(7)
                digitKey(8)
                digitKey(9)
                clearKey
            }
            HStack(spacing: 10) {
                smallKanaKey
                digitKey(0)
                symbolKey
                primaryKey
            }
        }
        .padding()
        .background(RetroTheme.bodyBackground)
    }

    private func digitKey(_ key: Int) -> some View {
        Button(action: { inputManager.pressKey(key) }) {
            Text("\(key)").font(.system(size: 32, weight: .bold, design: .monospaced))
        }
        .buttonStyle(RetroButtonStyle())
    }

    private var deleteKey: some View {
        Button(action: { inputManager.deleteLastCharacter() }) {
            Label("削除", systemImage: "delete.left")
                .labelStyle(.iconOnly)
                .font(.system(size: 18))
        }
        .buttonStyle(RetroButtonStyle())
        .buttonRepeatBehavior(.enabled)
    }

    private var spaceKey: some View {
        Button(action: { inputManager.insertSpace() }) {
            if isComposing {
                Text("次候補").font(.system(size: 14, weight: .bold))
            } else {
                Label("空白", systemImage: "space")
                    .labelStyle(.iconOnly)
                    .font(.system(size: 18))
            }
        }
        .buttonStyle(RetroButtonStyle())
    }

    /// Commits the composing text as raw kana without conversion.
    private var clearKey: some View {
        Button(action: { inputManager.confirmRawInput() }) {
            Text("CLR").font(.system(size: 18, weight: .bold, design: .monospaced))
        }
        .buttonStyle(RetroButtonStyle(isSpecial: true))
    }

    private var smallKanaKey: some View {
        Button(action: { inputManager.applySmallKana() }) {
            Text("小").font(.system(size: 24, weight: .bold))
        }
        .buttonStyle(RetroButtonStyle())
    }

    private var symbolKey: some View {
        FlickButton(
            center: "。",
            up: "？",
            left: "、",
            right: "！",
            height: 56,
            cornerRadius: 8,
            borderWidth: 2
        ) { char in
            inputManager.insertSymbol(char)
        }
    }

    /// Confirms the composition while composing; inserts a newline otherwise.
    private var primaryKey: some View {
        Button(action: confirmOrNewline) {
            Text(isComposing ? "確定" : "改行").font(.system(size: 16, weight: .bold))
        }
        .buttonStyle(RetroButtonStyle(isSpecial: true))
    }

    private func confirmOrNewline() {
        if isComposing {
            inputManager.confirmInput()
        } else {
            inputManager.insertNewline()
        }
    }
}
