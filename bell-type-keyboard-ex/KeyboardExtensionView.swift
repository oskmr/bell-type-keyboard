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
    var inputManager: PokebellInputManager

    private var isComposing: Bool {
        !inputManager.composingText.isEmpty
    }

    /// Renders the keyboard layout with optional prediction candidates.
    var body: some View {
        VStack(spacing: 0) {
            statusBar
                .frame(height: 34)
                .layoutPriority(1)
                .fixedSize(horizontal: false, vertical: true)

            VStack(spacing: 4) {
                HStack(spacing: 4) {
                    digitKey(1)
                    digitKey(2)
                    digitKey(3)
                    deleteKey
                }
                HStack(spacing: 4) {
                    digitKey(4)
                    digitKey(5)
                    digitKey(6)
                    spaceKey
                }
                HStack(spacing: 4) {
                    digitKey(7)
                    digitKey(8)
                    digitKey(9)
                    clearKey
                }
                HStack(spacing: 4) {
                    smallKanaKey
                    digitKey(0)
                    symbolKey
                    primaryKey
                }
            }
            .background(RetroTheme.keyboardBackground)
        }
        .background(Color.clear)
        .ignoresSafeArea()
    }

    /// Shows the pending digit preview alongside the prediction candidates.
    private var statusBar: some View {
        HStack(spacing: 4) {
            if !inputManager.currentPreview.isEmpty {
                Text(inputManager.currentPreview)
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundColor(RetroTheme.accentGreen)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .background(RetroTheme.displayBackground)
                    .cornerRadius(8)
                    .padding(.leading, 6)
            }
            PredictionBarView(
                candidates: inputManager.candidates,
                selectedIndex: inputManager.selectedCandidateIndex
            ) { candidate in
                selectCandidate(candidate)
            }
        }
        .background(Color.clear)
    }

    private func digitKey(_ key: Int) -> some View {
        Button(action: { pressKey(key) }) {
            Text("\(key)").font(.system(size: 24, weight: .bold, design: .monospaced))
        }
        .buttonStyle(CompactRetroButtonStyle())
    }

    private var deleteKey: some View {
        Button(action: deleteLastCharacter) {
            Label("削除", systemImage: "delete.left")
                .labelStyle(.iconOnly)
                .font(.system(size: 14))
        }
        .buttonStyle(CompactRetroButtonStyle())
        .buttonRepeatBehavior(.enabled)
    }

    private var spaceKey: some View {
        Button(action: insertSpace) {
            if isComposing {
                Text("次候補").font(.system(size: 12, weight: .bold))
            } else {
                Label("空白", systemImage: "space")
                    .labelStyle(.iconOnly)
                    .font(.system(size: 14))
            }
        }
        .buttonStyle(CompactRetroButtonStyle())
    }

    private var clearKey: some View {
        Button(action: clearComposing) {
            Text("CLR").font(.system(size: 14, weight: .bold, design: .monospaced))
        }
        .buttonStyle(CompactRetroButtonStyle(isSpecial: true))
    }

    private var smallKanaKey: some View {
        Button(action: applySmallKana) {
            Text("小").font(.system(size: 18, weight: .bold))
        }
        .buttonStyle(CompactRetroButtonStyle())
    }

    private var symbolKey: some View {
        FlickButton(
            center: "。",
            up: "？",
            left: "、",
            right: "！",
            height: 42
        ) { char in
            insertSymbol(char)
        }
    }

    /// Confirms the composition while composing; inserts a newline otherwise.
    private var primaryKey: some View {
        Button(action: confirmOrNewline) {
            Text(isComposing ? "確定" : "改行").font(.system(size: 13, weight: .bold))
        }
        .buttonStyle(CompactRetroButtonStyle(isSpecial: true))
    }

    private func pressKey(_ key: Int) {
        UIDevice.current.playInputClick()
        inputManager.pressKey(key)
    }

    private func deleteLastCharacter() {
        UIDevice.current.playInputClick()
        inputManager.deleteLastCharacter()
    }

    private func insertSpace() {
        UIDevice.current.playInputClick()
        inputManager.insertSpace()
    }

    private func clearComposing() {
        UIDevice.current.playInputClick()
        inputManager.clearComposing()
    }

    private func applySmallKana() {
        UIDevice.current.playInputClick()
        inputManager.applySmallKana()
    }

    private func insertSymbol(_ char: String) {
        UIDevice.current.playInputClick()
        inputManager.insertSymbol(char)
    }

    private func confirmOrNewline() {
        UIDevice.current.playInputClick()
        if isComposing {
            inputManager.confirmInput()
        } else {
            inputManager.insertNewline()
        }
    }

    private func selectCandidate(_ candidate: String) {
        UIDevice.current.playInputClick()
        inputManager.selectCandidate(candidate)
    }
}
